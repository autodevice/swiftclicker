import XCTest
@testable import SwiftClicker

final class SwiftClickerTests: XCTestCase {
    func testDeviceInitialization() {
        let device = Device(host: "localhost", port: 9008)
        XCTAssertFalse(device.isConnected)
    }
    
    func testTouchEventsChaining() async {
        let device = Device(host: "localhost", port: 9008)
        
        // Test that touch events can be chained (even without connection)
        let touchChain = device.touch
        XCTAssertNotNil(touchChain)
        
        // Test sleep method doesn't throw
        await touchChain.sleep(0.1)
    }
    
    func testHTTPClientInitialization() {
        let client = HTTPClient(host: "localhost", port: 9008)
        XCTAssertNotNil(client)
    }
}