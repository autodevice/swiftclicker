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
    private(set) var isConnected: Bool = false
    
    public lazy var touch: TouchEvents = TouchEvents(device: self)
    
    public init(host: String = "127.0.0.1", port: Int = 9008) {
        self.httpClient = HTTPClient(host: host, port: port)
    }
    
    public func connect() async throws {
        let pingSuccess = try await httpClient.ping()
        guard pingSuccess else {
            throw DeviceError.connectionFailed
        }
        isConnected = true
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
}