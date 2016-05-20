//  File.swift
//  SwiftSVG
//
//  Created by Kevin Meaney on 08/10/2015.
//  Copyright © 2015 No. All rights reserved.

import Foundation

import XCTest
@testable import SwiftSVG
import SwiftUtilities


func jsonFromNamedFile(namedFile: String) throws -> String {
    let textDrawingURL = try makeURLFromNamedFile(namedFile, fileExtension: "json")
    var encoding = NSStringEncoding()
    guard let source = try? String(contentsOfURL: textDrawingURL, usedEncoding: &encoding) else {
        throw TestError.noContentInFile(textDrawingURL.path!)
    }
    return source
}

class MovingImagesSVGTests: XCTestCase {
    
    static let saveJSON = false
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func convertSVGToJSON(baseFileName: String) throws -> String {
        let optionalSVGDocument: SVGDocument?
        do {
            let xmlDocument = try xmlDocumentFromNamedSVGFile(baseFileName)
            let processor = SVGProcessor()
            optionalSVGDocument = try processor.processXMLDocument(xmlDocument)
        }
        catch let error {
            XCTAssert(false, "Failed to create SVGDocument: \(error)")
            throw error
        }
        
        guard let svgDocument = optionalSVGDocument else {
            XCTAssert(false, "optionalSVGDocument should not be .None")
            throw TestError.invalidXML
        }
        
        let renderer = MovingImagesRenderer()
        let svgRenderer = SVGRenderer()
        let _ = try? svgRenderer.renderDocument(svgDocument, renderer: renderer)
        let jsonObject = renderer.generateJSONDict()
        
        guard let jsonString = jsonObjectToString(jsonObject) else {
            throw TestError.invalidJSONObject
        }
        if MovingImagesSVGTests.saveJSON {
            let basePath = SwiftUtilities.Path("~/github/swiftsvg2/SwiftSVG Demo/Samples").normalizedPath
            let url = NSURL(fileURLWithPath: basePath).URLByAppendingPathComponent(baseFileName).URLByAppendingPathExtension("json")
            do {
                try (jsonString as NSString).writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding)
            }
            catch {
                print("Failed to save: \(url.path)")
            }
            
        }
        return jsonString
    }

/*
    func convertOptimisedSVGToJSON(baseFileName: String) throws -> String {
        let optionalSVGDocument: SVGDocument?
        do {
            let xmlDocument = try xmlDocumentFromNamedSVGFile(baseFileName)
            let processor = SVGProcessor()
            optionalSVGDocument = try processor.processXMLDocument(xmlDocument)
        }
        catch let error {
            XCTAssert(false, "Failed to create SVGDocument: \(error)")
            throw error
        }
        
        guard let svgDocument = optionalSVGDocument else {
            XCTAssert(false, "optionalSVGDocument should not be .None")
            throw TestError.invalidXML
        }
        
        svgDocument.optimise()
        let renderer = MovingImagesRenderer()
        let svgRenderer = SVGRenderer()
        let _ = try? svgRenderer.renderDocument(svgDocument, renderer: renderer)
        let jsonObject = renderer.generateJSONDict()
        
        guard let jsonString = jsonObjectToString(jsonObject) else {
            throw TestError.invalidJSONObject
        }
        return jsonString
    }
*/
    func test6th_Day() {
        let jsonString: String
        let originalJSONString: String
        do {
            jsonString = try convertSVGToJSON("6th-day")
            originalJSONString = try jsonFromNamedFile("6th-day")
            XCTAssert(originalJSONString == jsonString,
                "MovingImages JSON Text rendering representation changed: \(jsonString)")
        } catch { }
    }

    func testAnti_Normal() {
        let jsonString: String
        let originalJSONString: String
        do {
            jsonString = try convertSVGToJSON("Anti-normal")
            originalJSONString = try jsonFromNamedFile("Anti-normal")
            XCTAssert(originalJSONString == jsonString,
                "MovingImages JSON Text rendering representation changed")
        } catch { }
    }

    func testAppleSwiftLogo() {
        let jsonString: String
        let originalJSONString: String
        do {
            jsonString = try convertSVGToJSON("Apple_Swift_Logo")
            originalJSONString = try jsonFromNamedFile("Apple_Swift_Logo")
            XCTAssert(originalJSONString == jsonString,
                "MovingImages JSON Text rendering representation changed")
        } catch { }
    }

    func testGhostscriptTiger() {
        let jsonString: String
        let originalJSONString: String
        do {
            jsonString = try convertSVGToJSON("Ghostscript_Tiger")
            originalJSONString = try jsonFromNamedFile("Ghostscript_Tiger")
            XCTAssert(originalJSONString == jsonString,
                "MovingImages JSON Text rendering representation changed")
        } catch { }
    }
/*
    func testGhostscriptTiger_optimized() {
        let jsonString: String
        let originalJSONString: String
        do {
            jsonString = try convertOptimisedSVGToJSON("Ghostscript_Tiger")
            originalJSONString = try jsonFromNamedFile("Ghostscript_Tiger_optimized")
            XCTAssert(originalJSONString == jsonString,
                "MovingImages JSON Text rendering representation changed")
        } catch { }
    }
*/
    func testJWBezier() {
        let jsonString: String
        let originalJSONString: String
        do {
            jsonString = try convertSVGToJSON("JW_Bezier_1")
            originalJSONString = try jsonFromNamedFile("JW_Bezier_1")
            XCTAssert(originalJSONString == jsonString,
                "MovingImages JSON Text rendering representation changed")
        } catch { }
    }

    func testMarker() {
        let jsonString: String
        let originalJSONString: String
        do {
            jsonString = try convertSVGToJSON("Markers")
            originalJSONString = try jsonFromNamedFile("Markers")
            XCTAssert(originalJSONString == jsonString,
                "MovingImages JSON Text rendering representation changed")
        } catch { }
    }
    
    func testRPM_NavBall_Overlay() {
        let jsonString: String
        let originalJSONString: String
        do {
            jsonString = try convertSVGToJSON("RPM_NavBall_Overlay")
            originalJSONString = try jsonFromNamedFile("RPM_NavBall_Overlay")
            XCTAssert(originalJSONString == jsonString,
                "MovingImages JSON Text rendering representation changed")
        } catch { }
    }

    func testSwiftOutline() {
        let jsonString: String
        let originalJSONString: String
        do {
            jsonString = try convertSVGToJSON("SwiftOutline")
            originalJSONString = try jsonFromNamedFile("SwiftOutline")
            XCTAssert(originalJSONString == jsonString,
                "MovingImages JSON Text rendering representation changed")
        } catch { }
    }

    func testImage2() {
        let jsonString: String
        let originalJSONString: String
        do {
            jsonString = try convertSVGToJSON("test_image2")
            originalJSONString = try jsonFromNamedFile("test_image2")
            XCTAssert(originalJSONString == jsonString,
                "MovingImages JSON Text rendering representation changed")
        } catch { }
    }
    
    func testTextDrawing() {
        let jsonString: String
        let originalJSONString: String
        do {
            jsonString = try convertSVGToJSON("TextDrawing")
            originalJSONString = try jsonFromNamedFile("TextDrawing")
            XCTAssert(originalJSONString == jsonString,
                "MovingImages JSON Text rendering representation changed: \(jsonString)")
        } catch { }
    }
}
