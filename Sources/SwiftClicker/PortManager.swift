import Foundation

public class PortManager {
    private static let shared = PortManager()
    private var allocatedPorts: Set<Int> = []
    private let lock = NSLock()
    private let basePort = 9008
    
    private init() {}
    
    public static func allocatePort() -> Int {
        return shared.allocateNextPort()
    }
    
    public static func releasePort(_ port: Int) {
        shared.releasePortInternal(port)
    }
    
    private func allocateNextPort() -> Int {
        lock.lock()
        defer { lock.unlock() }
        
        var port = basePort
        while allocatedPorts.contains(port) {
            port += 1
        }
        
        allocatedPorts.insert(port)
        return port
    }
    
    private func releasePortInternal(_ port: Int) {
        lock.lock()
        defer { lock.unlock() }
        
        allocatedPorts.remove(port)
    }
    
    public static func isPortAvailable(_ port: Int) -> Bool {
        return !shared.allocatedPorts.contains(port)
    }
}