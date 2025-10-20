import Foundation
import CommonCrypto

public enum ServerError: Error {
    case adbNotFound
    case deviceNotConnected
    case jarDeploymentFailed
    case serverStartFailed(String)
    case serverNotReady
}

public class ServerManager {
    private let deviceSerial: String?
    private var serverProcess: Process?
    private let jarURL = "https://public.uiauto.devsleep.com/u2jar/0.2.0/u2.jar"
    private let port: Int
    
    public init(deviceSerial: String? = nil, port: Int = 9008) {
        self.deviceSerial = deviceSerial
        self.port = port
    }
    
    public func setupAndStartServer() async throws {
        print("🔧 Setting up uiautomator2 server...")
        
        // 1. Check ADB connectivity
        try await checkAdbConnection()
        
        // 2. Download and deploy JAR
        try await deployJar()
        
        // 3. Start server
        try await startServer()
        
        // 4. Setup port forwarding
        try await setupPortForwarding()
        
        // 5. Verify server is ready
        try await verifyServerReady()
        
        print("✅ uiautomator2 server is ready!")
    }
    
    private func checkAdbConnection() async throws {
        print("   Checking ADB connection...")
        
        let result = try await runCommand("adb", arguments: ["devices"])
        guard result.contains("device") && !result.contains("offline") else {
            throw ServerError.deviceNotConnected
        }
        print("   ✅ Device connected")
    }
    
    private func deployJar() async throws {
        print("   Deploying uiautomator2 JAR...")
        
        let targetPath = "/data/local/tmp/u2.jar"
        
        // Download JAR locally first
        let jarPath = try await downloadJar()
        
        // Check if device file matches local file hash
        if try await checkDeviceFileHash(localPath: jarPath, remotePath: targetPath) {
            print("   JAR already deployed with correct hash")
            try? FileManager.default.removeItem(atPath: jarPath)
            return
        }
        
        // Push JAR to device
        print("   Pushing JAR to device...")
        let pushResult = try await runAdbCommand(["push", jarPath, targetPath])
        
        if !pushResult.contains("1 file pushed") && !pushResult.isEmpty {
            throw ServerError.jarDeploymentFailed
        }
        
        // Clean up local JAR
        try? FileManager.default.removeItem(atPath: jarPath)
        
        print("   ✅ JAR deployed")
    }
    
    private func downloadJar() async throws -> String {
        print("   Downloading uiautomator2 JAR...")
        
        let tempDir = NSTemporaryDirectory()
        let jarPath = tempDir + "u2.jar"
        
        // Use curl to download the JAR
        _ = try await runCommand("curl", arguments: [
            "-L", "-o", jarPath, jarURL
        ])
        
        guard FileManager.default.fileExists(atPath: jarPath) else {
            throw ServerError.jarDeploymentFailed
        }
        
        return jarPath
    }
    
    private func checkDeviceFileHash(localPath: String, remotePath: String) async throws -> Bool {
        guard FileManager.default.fileExists(atPath: localPath) else {
            return false
        }
        
        // Calculate local file MD5
        guard let localData = FileManager.default.contents(atPath: localPath) else {
            return false
        }
        
        let localMD5 = md5Hash(data: localData)
        
        // Get remote file MD5 using toybox md5sum
        do {
            let output = try await runAdbCommand(["shell", "toybox", "md5sum", remotePath])
            return output.contains(localMD5)
        } catch {
            // If md5sum fails, file probably doesn't exist
            return false
        }
    }
    
    private func md5Hash(data: Data) -> String {
        let digest = data.withUnsafeBytes { bytes in
            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
            return digest
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    private func startServer() async throws {
        print("   Starting uiautomator2 server...")
        
        // Kill any existing uiautomator processes
        _ = try? await runAdbCommand(["shell", "pkill", "-f", "uiautomator"])
        
        // Start the server process
        let serverCommand = "CLASSPATH=/data/local/tmp/u2.jar app_process / com.wetest.uia2.Main"
        
        // Start server in background using nohup
        _ = try await runAdbCommand([
            "shell", "nohup", "sh", "-c", 
            "'\(serverCommand) > /dev/null 2>&1 &'"
        ])
        
        // Give server time to start
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        print("   ✅ Server started")
    }
    
    private func setupPortForwarding() async throws {
        print("   Setting up port forwarding...")
        
        _ = try await runAdbCommand(["forward", "tcp:\(port)", "tcp:9008"])
        
        print("   ✅ Port forwarding active (localhost:\(port) -> device:9008)")
    }
    
    private func verifyServerReady() async throws {
        print("   Verifying server connectivity...")
        
        var attempts = 0
        let maxAttempts = 10
        
        while attempts < maxAttempts {
            do {
                let result = try await runCommand("curl", arguments: [
                    "-s", "-m", "2", "http://127.0.0.1:\(port)/ping"
                ])
                
                if result.trimmingCharacters(in: .whitespacesAndNewlines) == "pong" {
                    print("   ✅ Server responding to ping")
                    return
                }
            } catch {
                // Ignore curl errors and retry
            }
            
            attempts += 1
            print("   Attempt \(attempts)/\(maxAttempts)...")
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        throw ServerError.serverNotReady
    }
    
    private func runAdbCommand(_ arguments: [String]) async throws -> String {
        var adbArgs = ["adb"]
        
        if let serial = deviceSerial {
            adbArgs.append(contentsOf: ["-s", serial])
        }
        
        adbArgs.append(contentsOf: arguments)
        
        return try await runCommand("", arguments: adbArgs)
    }
    
    private func runCommand(_ command: String, arguments: [String]) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            let pipe = Pipe()
            
            if command.isEmpty {
                process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
                process.arguments = arguments
            } else {
                process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
                process.arguments = [command] + arguments
            }
            
            process.standardOutput = pipe
            process.standardError = pipe
            
            do {
                try process.run()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
                process.waitUntilExit()
                
                if process.terminationStatus == 0 {
                    continuation.resume(returning: output)
                } else {
                    continuation.resume(throwing: ServerError.serverStartFailed(output))
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func stopServer() async {
        print("🛑 Stopping uiautomator2 server...")
        
        // Kill server process on device
        _ = try? await runAdbCommand(["shell", "pkill", "-f", "uiautomator"])
        
        // Remove port forwarding
        _ = try? await runAdbCommand(["forward", "--remove", "tcp:\(port)"])
        
        print("✅ Server stopped")
    }
    
    deinit {
        // Note: Can't use async in deinit, so this is just a note
        // Users should call stopServer() explicitly when done
    }
}