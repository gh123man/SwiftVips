import XCTest
@testable import SwiftVips


final class SwiftVipsTests: XCTestCase {
    override class func setUp() {
        Vips.initialize()
        Vips.leakCheck = true
    }
    
    override class func tearDown() {
        Vips.shutdown()
    }
    
    func testVips() throws {
        let png = try! VImage(from: testPng)
        try! png.resize(scale: 0.5)

        XCTAssertEqual(png.width, 960)
        XCTAssertEqual(png.height, 540)
        
        let jpgData = try! png.toJpeg(quality: 50)
        
        let jpg = try! VImage(from: jpgData)
        try! jpg.resize(scale: 0.5)

        XCTAssertEqual(jpg.width, 480)
        XCTAssertEqual(jpg.height, 270)
        
        let pngData = try! jpg.toPng(compression: 4)
        
        let png2 = try! VImage(from: pngData)
        try! png2.resize(scale: 0.5)

        XCTAssertEqual(png2.width, 240)
        XCTAssertEqual(png2.height, 135)
    }
}
