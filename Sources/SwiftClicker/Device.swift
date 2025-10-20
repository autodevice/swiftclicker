import Foundation

public enum DeviceError: Error {
    case connectionFailed
    case notConnected
    case invalidCoordinates
    case serverError(String)
}

public class TouchEvents {
    private let device: Device
    
    init(device: Device) {
        self.device = device
    }
    
    @discardableResult
    public func down(x: Int, y: Int) async throws -> TouchEvents {
        try await device.injectInputEvent(action: 0, x: x, y: y)
        return self
    }
    
    @discardableResult
    public func move(x: Int, y: Int) async throws -> TouchEvents {
        try await device.injectInputEvent(action: 2, x: x, y: y)
        return self
    }
    
    @discardableResult
    public func up(x: Int, y: Int) async throws -> TouchEvents {
        try await device.injectInputEvent(action: 1, x: x, y: y)
        return self
    }
    
    @discardableResult
    public func sleep(_ seconds: Double) async -> TouchEvents {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        return self
    }
}

public class Device {
    private let httpClient: HTTPClient
    private let serverManager: ServerManager
    private(set) var isConnected: Bool = false
    private let allocatedPort: Int?
    
    public lazy var touch: TouchEvents = TouchEvents(device: self)
    
    public init(host: String = "127.0.0.1", port: Int? = nil, deviceSerial: String? = nil) {
        // Allocate port automatically if not specified and deviceSerial is provided
        let finalPort: Int
        if let port = port {
            finalPort = port
            self.allocatedPort = nil
        } else if deviceSerial != nil {
            finalPort = PortManager.allocatePort()
            self.allocatedPort = finalPort
        } else {
            finalPort = 9008 // Default port for default device
            self.allocatedPort = nil
        }
        
        self.httpClient = HTTPClient(host: host, port: finalPort)
        self.serverManager = ServerManager(deviceSerial: deviceSerial, port: finalPort)
    }
    
    public func connect(autoSetupServer: Bool = true) async throws {
        print("🔄 Connecting to uiautomator2 server...")
        
        // First, try to connect to existing server
        if try await quickConnectTest() {
            print("✅ Connected to existing server!")
            isConnected = true
            return
        }
        
        if autoSetupServer {
            print("   No existing server found, setting up new server...")
            try await serverManager.setupAndStartServer()
            
            // Try connecting again after setup
            if try await quickConnectTest() {
                print("✅ Connected to newly started server!")
                isConnected = true
                return
            }
        }
        
        print("❌ Failed to connect to uiautomator2 server")
        throw DeviceError.connectionFailed
    }
    
    private func quickConnectTest() async throws -> Bool {
        do {
            let pingSuccess = try await httpClient.ping()
            if pingSuccess {
                // Double-check with a lightweight JSON-RPC call
                _ = try await httpClient.jsonrpcCall(method: "deviceInfo")
                return true
            }
        } catch {
            // Ignore errors for quick test
        }
        return false
    }
    
    private func ensureConnected() throws {
        guard isConnected else {
            throw DeviceError.notConnected
        }
    }
    
    internal func injectInputEvent(action: Int, x: Int, y: Int) async throws {
        try ensureConnected()
        
        do {
            _ = try await httpClient.jsonrpcCall(
                method: "injectInputEvent",
                params: [action, x, y, 0]
            )
        } catch let HTTPClientError.jsonrpcError(message) {
            throw DeviceError.serverError(message)
        }
    }
    
    public func press(_ key: String) async throws {
        try ensureConnected()
        
        do {
            _ = try await httpClient.jsonrpcCall(
                method: "pressKey",
                params: [key]
            )
        } catch let HTTPClientError.jsonrpcError(message) {
            throw DeviceError.serverError(message)
        }
    }
    
    public func press(keyCode: Int, meta: Int? = nil) async throws {
        try ensureConnected()
        
        do {
            if let meta = meta {
                _ = try await httpClient.jsonrpcCall(
                    method: "pressKeyCode",
                    params: [keyCode, meta]
                )
            } else {
                _ = try await httpClient.jsonrpcCall(
                    method: "pressKeyCode",
                    params: [keyCode]
                )
            }
        } catch let HTTPClientError.jsonrpcError(message) {
            throw DeviceError.serverError(message)
        }
    }
    
    public func click(x: Int, y: Int) async throws {
        try await touch.down(x: x, y: y)
            .sleep(0.1)
            .up(x: x, y: y)
    }
    
    public func longPress(x: Int, y: Int, duration: Double = 1.0) async throws {
        try await touch.down(x: x, y: y)
            .sleep(duration)
            .up(x: x, y: y)
    }
    
    public func swipe(fromX: Int, fromY: Int, toX: Int, toY: Int, duration: Double = 0.5) async throws {
        let steps = Int(duration * 10)
        let stepX = Double(toX - fromX) / Double(steps)
        let stepY = Double(toY - fromY) / Double(steps)
        
        try await touch.down(x: fromX, y: fromY)
        
        for i in 1...steps {
            let currentX = fromX + Int(stepX * Double(i))
            let currentY = fromY + Int(stepY * Double(i))
            try await touch.move(x: currentX, y: currentY)
                .sleep(duration / Double(steps))
        }
        
        try await touch.up(x: toX, y: toY)
    }
    
    public func checkServerStatus() async -> Bool {
        do {
            let pingSuccess = try await httpClient.ping()
            if pingSuccess {
                // Also test JSON-RPC functionality
                _ = try await httpClient.jsonrpcCall(method: "dumpWindowHierarchy", params: [false])
                return true
            }
        } catch {
            print("Server check failed: \(error.localizedDescription)")
        }
        return false
    }
    
    public static func setupInstructions() {
        print("")
        print("📋 uiautomator2 Server Setup Instructions")
        print(String(repeating: "=", count: 50))
        print("")
        print("1. Install uiautomator2 Python package:")
        print("   pip install uiautomator2")
        print("")
        print("2. Connect Android device or start emulator:")
        print("   adb devices  # Should show your device")
        print("")
        print("3. Initialize uiautomator2 server:")
        print("   python -c \"import uiautomator2 as u2; d = u2.connect(); print('Server started!')\"")
        print("")
        print("4. Set up port forwarding (if needed):")
        print("   adb forward tcp:9008 tcp:9008")
        print("")
        print("5. Test server connection:")
        print("   curl http://127.0.0.1:9008/ping")
        print("   # Should return 'pong'")
        print("")
        print("6. Keep the Python session alive or run in background")
        print("")
    }
    
    public func disconnect() async {
        await serverManager.stopServer()
        isConnected = false
        
        // Release allocated port if we allocated one
        if let port = allocatedPort {
            PortManager.releasePort(port)
        }
    }
    
    deinit {
        // Release port in case disconnect wasn't called
        if let port = allocatedPort {
            PortManager.releasePort(port)
        }
    }
}