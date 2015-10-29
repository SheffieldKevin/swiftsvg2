//  MISVGColorsTests.swift
//  SwiftSVG
//
//  Created by Kevin Meaney on 22/10/2015.

import Foundation

import XCTest
@testable import SwiftSVG

class MISVGColorsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMakeColorHexString() {
        let test1 = SVGColors.makeHexColor(red: 0.002, green: 0.499, blue: 0.999)
        XCTAssert(test1 == "#017FFF", "hexString should be #017FFF and is \(test1)")
        
        let test2 = SVGColors.makeHexColor(red: 0.0, green: 0.001, blue: 0.002)
        XCTAssert(test2 == "#000001", "hexString should be #000001 and is \(test2)")

        let test3 = SVGColors.makeHexColor(red: 0.497, green: 0.5, blue: 0.51)
        XCTAssert(test3 == "#7F7F82", "hexString should be #7F7F82 and is \(test3)")

        let test4 = SVGColors.makeHexColor(red: 0.997, green: 0.999, blue: 1.0)
        XCTAssert(test4 == "#FEFFFF", "hexString should be #FEFFFF and is \(test4)")

        let test5 = SVGColors.makeHexColor(red: 0.999, green: 0.496, blue: 0.0)
        XCTAssert(test5 == "#FF7E00", "hexString should be #FF7E00 and is \(test5)")
    }
}