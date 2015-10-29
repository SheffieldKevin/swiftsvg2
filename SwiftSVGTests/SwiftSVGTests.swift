//
//  SwiftSVGTests.swift
//  SwiftSVGTests
//
//  Created by Kevin Meaney on 02/10/2015.
//  Copyright © 2015 No. All rights reserved.
//

import XCTest
@testable import SwiftSVG

public enum TestError: ErrorType {
    case invalidFilePath
    case noContentInFile(String)
    case invalidXML
    case invalidSVG
    case invalidJSONObject
}

func makeURLFromNamedFile(namedFile: String, fileExtension: String) throws -> NSURL {
    let testBundle = NSBundle(forClass: SwiftSVGTests.self)
    guard let url = testBundle.URLForResource(namedFile, withExtension:fileExtension) else {
        throw TestError.invalidFilePath
    }
    
    return url
}

func svgSourceFromNamedFile(namedFile: String) throws -> String {
    let textDrawingURL = try makeURLFromNamedFile(namedFile, fileExtension: "svg")
    var encoding = NSStringEncoding()
    guard let source = try? String(contentsOfURL: textDrawingURL, usedEncoding: &encoding) else {
        throw TestError.noContentInFile(textDrawingURL.path!)
    }
    return source
}

func xmlDocumentFromNamedSVGFile(namedFile: String) throws -> NSXMLDocument {
    let source = try svgSourceFromNamedFile(namedFile)
    guard let xmlDocument = try? NSXMLDocument(XMLString: source, options: 0) else {
        throw TestError.invalidXML
    }
    return xmlDocument
}

class SwiftSVGTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleText() {
        let optionalSVGDocument: SVGDocument?
        do {
            let xmlDocument = try xmlDocumentFromNamedSVGFile("TextDrawing")
            let processor = SVGProcessor()
            optionalSVGDocument = try processor.processXMLDocument(xmlDocument)
        }
        catch let error {
            XCTAssert(false, "Failed to create SVGDocument: \(error)")
            return
        }

        guard let svgDocument = optionalSVGDocument else {
            XCTAssert(false, "optionalSVGDocument should not be .None")
            return
        }
        
        XCTAssert(svgDocument.id == "Layer_1", "The document should have id Layer_1")
        XCTAssert(svgDocument.viewBox! == CGRect(x: 0, y: 0, width: 300, height: 200), "viewBox should be 300x200 at 0,0")
        XCTAssert(svgDocument.version!.majorVersion == 1, "SVG majorVersion should be 1")
        XCTAssert(svgDocument.version!.minorVersion == 1, "SVG minorVersion should be 1")
        XCTAssert(svgDocument.drawFill == true, "Draw fill should be true")
        XCTAssert(svgDocument.display == true, "Display should be true")
        XCTAssert(svgDocument.children.count == 1, "TextDrawing should have 1 child.")
        XCTAssert(svgDocument.children[0] is SVGSimpleText, "Only document child element should be a SVGSimpleText")
        
        guard svgDocument.children.count == 1, let simpleText = svgDocument.children[0] as? SVGSimpleText else {
            return
        }
        XCTAssert(simpleText.style!.lineWidth == 4, "Text stroke width should be 4")
        XCTAssert(simpleText.fontFamily == "Arial", "Font family should be Arial")
        XCTAssert(simpleText.fontSize == 40, "Font size should be 40")
        XCTAssert(simpleText.spans.count == 1, "Number of text spans should be 1")
        
        guard simpleText.spans.count == 1 else {
            return
        }
        let span = simpleText.spans[0]
        XCTAssert(span.string == "Fill and stroke", "Text drawn should be Fill and stroke and is: \(span.string)")
        XCTAssert(span.textOrigin == CGPoint(x: 20, y: 200), "Text origin should be 0,0")
        let attributedString: CFAttributedString = span.cttext
        XCTAssert(CFAttributedStringGetString(attributedString) == "Fill and stroke", "Text in attributed string should be Fill and stroke")
        XCTAssert(span.strokeWidth == -4, "Span stroke width should return -4")
    }

    func testSwiftLogo() {
        let optionalSVGDocument: SVGDocument?
        do {
            let xmlDocument = try xmlDocumentFromNamedSVGFile("Apple_Swift_Logo")
            let processor = SVGProcessor()
            optionalSVGDocument = try processor.processXMLDocument(xmlDocument)
        }
        catch let error {
            XCTAssert(false, "Failed to create SVGDocument: \(error)")
            return
        }
        
        guard let svgDocument = optionalSVGDocument else {
            XCTAssert(false, "optionalSVGDocument should not be .None")
            return
        }
        
        XCTAssert(svgDocument.children.count == 27, "TextDrawing should have 1 child.")
        XCTAssert(svgDocument.viewBox == CGRect(x: 0, y: 0, width: 256, height: 256), "View box should be a square 256x256")
        svgDocument.children.forEach {
            guard let svgPath = $0 as? SVGPath else {
                XCTAssert(false, "All items should be SVGPaths")
                return
            }
            guard let _ = svgPath.fillColor else {
                XCTAssert(false, "Fill color should be defined")
                return
            }
            
            if let _ = svgPath.strokeColor {
                XCTAssert(false, "Stroke color should not be defined")
            }
        }
    }

    func testRPM_NavBall_Overlay() {
        let optionalSVGDocument: SVGDocument?
        do {
            let xmlDocument = try xmlDocumentFromNamedSVGFile("RPM_NavBall_Overlay")
            let processor = SVGProcessor()
            optionalSVGDocument = try processor.processXMLDocument(xmlDocument)
        }
        catch let error {
            XCTAssert(false, "Failed to create SVGDocument: \(error)")
            return
        }
        
        guard let svgDocument = optionalSVGDocument else {
            XCTAssert(false, "optionalSVGDocument should not be .None")
            return
        }
        
        print("Num children: \(svgDocument.children.count)")
        
        let child0 = svgDocument.children[0]
        let child1 = svgDocument.children[1]
        
        
        guard let group0 = child0 as? SVGGroup else {
            XCTAssert(false, "svgDocument.children[0] should be of type SVGGroup.")
            return
        }
        
        guard let group1 = child1 as? SVGGroup else {
            XCTAssert(false, "svgDocument.children[1] should be of type SVGGroup.")
            return
        }
        
        XCTAssert(group0.children.count == 2, "SVGGroup0 object should have 2 children.")
        XCTAssert(group1.children.count == 24, "SVGGroup1 object should have 24 children.")
        
    }
}
