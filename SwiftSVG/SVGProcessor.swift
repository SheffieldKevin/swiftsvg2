//
//  SVGProcessor.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 2/25/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Foundation

import SwiftGraphics
import SwiftParsing

private extension CGLineJoin {
    static func valueFromSVG(string string: String) -> CGLineJoin? {
        switch(string) {
        case "bevel":
            return CGLineJoin.Bevel
        case "miter":
            return CGLineJoin.Miter
        case "round":
            return CGLineJoin.Round
        default:
            return .None
        }
    }
}

private extension CGLineCap {
    static func valueFromSVG(string string: String) -> CGLineCap? {
        switch(string) {
        case "butt":
            return CGLineCap.Butt
        case "round":
            return CGLineCap.Round
        case "square":
            return CGLineCap.Square
        default:
            return .None
        }
    }
}

public class SVGProcessor {

    public class State {
        var document: SVGDocument?
        var elementsByID: [String:SVGElement] = [: ]
        var events: [Event] = []
        var fillOpacity: CGFloat?
        var strokeOpacity: CGFloat?
    }

    public struct Event {
        enum Severity {
            case debug
            case info
            case warning
            case error
        }

        let severity: Severity
        let message: String
    }

    public enum Error: ErrorType {
        case corruptXML(String, String, Int)
        case invalidSVG(String, String, Int)
        case expectedSVGElementNotFound(String, String, Int)
        case missingRequiredSVGProperty(String, String, Int)
        case invalidFunctionParameters(String, String, Int)
    }

    public init() {
    }

    private func isElementRendereable(svgElement: SVGElement?) -> Bool {
        if let _ = svgElement as? SVGLinearGradient {
            return false
        }
        return true
    }
    
    public func processXMLDocument(xmlDocument: NSXMLDocument) throws -> SVGDocument? {
        let rootElement = xmlDocument.rootElement()!
        let state = State()
        let document = try self.processSVGElement(rootElement, state: state) as? SVGDocument
        if state.events.count > 0 {
            for event in state.events {
                print(event)
            }
        }
        return document
    }

    public func processSVGDocument(xmlElement: NSXMLElement, state: State) throws -> SVGDocument {
        let document = SVGDocument()
        state.document = document

        // Version.
        if let version = xmlElement["version"]?.stringValue {
            switch version {
                case "1.1":
                    document.profile = .full
                    document.version = SVGDocument.Version(majorVersion: 1, minorVersion: 1)
                default:
                    break
            }
            xmlElement["version"] = nil
        }

        // Viewbox.
        if let viewbox = xmlElement["viewBox"]?.stringValue {
            let OPT_COMMA = zeroOrOne(COMMA).makeStripped()
            let VALUE_LIST = RangeOf(min: 4, max: 4, subelement: (cgFloatValue + OPT_COMMA).makeStripped().makeFlattened())

            // TODO: ! can and will crash with bad data.
            let values: [CGFloat] = (try! VALUE_LIST.parse(viewbox).value as? [Any])!.map() {
                return $0 as! CGFloat
            }

            let (x, y, width, height) = (values[0], values[1], values[2], values[3])
            document.viewBox = CGRect(x: x, y: y, width: width, height: height)

            xmlElement["viewBox"] = nil
        }
        
        if let _ = xmlElement["width"]?.stringValue, let _ = xmlElement["height"]?.stringValue {
            let width = try SVGProcessor.stringToCGFloat(xmlElement["width"]?.stringValue)
            let height = try SVGProcessor.stringToCGFloat(xmlElement["height"]?.stringValue)
            let x = try SVGProcessor.stringToCGFloat(xmlElement["x"]?.stringValue, defaultVal: 0.0)
            let y = try SVGProcessor.stringToCGFloat(xmlElement["y"]?.stringValue, defaultVal: 0.0)
            document.viewPort = CGRect(x: x, y: y, width: width, height: height)
        }

        if let _ = document.viewBox { }
        else {
            document.viewBox = document.viewPort
        }
        xmlElement["width"] = nil
        xmlElement["height"] = nil
        xmlElement["x"] = nil
        xmlElement["y"] = nil
        
        guard let nodes = xmlElement.children else {
            return document
        }

        for node in nodes where node is NSXMLElement {
            if let svgElement = try self.processSVGElement(node as! NSXMLElement, state: state) {
                svgElement.parent = document
                document.children.append(svgElement)
            }
        }
        xmlElement.setChildren(nil)
        return document
    }

    public func processSVGElement(xmlElement: NSXMLElement, state: State) throws -> SVGElement? {
        var svgElement: SVGElement? = nil

        let oldFillOpacity = state.fillOpacity
        defer {
            state.fillOpacity = oldFillOpacity
        }
        let oldStrokeOpacity = state.strokeOpacity
        defer {
            state.strokeOpacity = oldStrokeOpacity
        }
        
        guard let name = xmlElement.name else {
            throw Error.corruptXML(#file, #function, #line)
        }

        switch name {
            case "defs":
                svgElement = try processDEFS(xmlElement, state: state)
            case "svg":
                svgElement = try processSVGDocument(xmlElement, state: state)
            case "g":
                svgElement = try processSVGGroup(xmlElement, state: state)
            // The "symbol" element being equated to a group element here is a pure hack.
            // TODO: create a SVGSymbol class and a processSVGSymbol method.
            case "symbol":
                svgElement = try processSVGGroup(xmlElement, state: state)
            case "path":
                svgElement = try processSVGPath(xmlElement, state: state)
            case "line":
                svgElement = try processSVGLine(xmlElement, state: state)
            case "circle":
                svgElement = try processSVGCircle(xmlElement, state: state)
            case "rect":
                svgElement = try processSVGRect(xmlElement, state: state)
            case "ellipse":
                svgElement = try processSVGEllipse(xmlElement, state: state)
            case "polygon":
                svgElement = try processSVGPolygon(xmlElement, state:state)
            case "polyline":
                svgElement = try processSVGPolyline(xmlElement, state:state)
            case "text":
                svgElement = try processSVGText(xmlElement, state:state)
            case "use":
                svgElement = try processUSEElement(xmlElement, state:state)
            case "linearGradient":
                svgElement = try processGradientDefs(xmlElement, state:state)
            case "title":
                state.document!.title = xmlElement.stringValue as String?
            case "desc":
                state.document!.documentDescription = xmlElement.stringValue as String?
            default:
                state.events.append(Event(severity: .warning, message: "Unhandled element \(xmlElement.name)"))
                return nil
        }

        if let svgElement = svgElement {
            svgElement.textStyle = try processTextStyle(xmlElement)
            svgElement.style = try processStyle(xmlElement, state: state, svgElement: svgElement)
            if let theTransform = svgElement.transform {
                if let newTransform = try processTransform(xmlElement, elementKey: "transform") {
                    // svgElement.transform = theTransform + newTransform
                    svgElement.transform = newTransform + theTransform
                }
            }
            else {
                svgElement.transform = try processTransform(xmlElement, elementKey: "transform")
            }

            if let id = xmlElement["id"]?.stringValue {
                svgElement.id = id
                if state.elementsByID[id] != nil {
                    state.events.append(Event(severity: .warning, message: "Duplicate elements with id \"\(id)\"."))
                }
                state.elementsByID[id] = svgElement
                xmlElement["id"] = nil
            }

            if xmlElement.attributes?.count > 0 {
                state.events.append(Event(severity: .warning, message: "Unhandled attributes: \(xmlElement))"))
                svgElement.xmlElement = xmlElement
            }
        }
        
        // All elements added to the svg element tree hierarchy should be renderable or their children should be.
        // If the element isn't then stop it from being added to the tree of elements.
        if !self.isElementRendereable(svgElement) {
            svgElement = .None
        }

        return svgElement
    }

    public func processDEFS(xmlElement: NSXMLElement, state: State) throws -> SVGElement? {
        // A def element can be children of documents and groups.
        // Any member of def elements should be accessible anywhere within the SVGDocument.
        guard let nodes = xmlElement.children else {
            return .None
        }
        
        // I suspect that we might need a seperate processor for members of the defs element.
        var defElements = [SVGElement]()
        for node in nodes where node is NSXMLElement {
            if let svgElement = try self.processSVGElement(node as! NSXMLElement, state: state) {
                defElements.append(svgElement)
            }
        }
        return nil
    }

    public func processUSEElement(xmlElement: NSXMLElement, state: State) throws -> SVGElement? {
        guard let string = xmlElement["xlink:href"]?.stringValue where string.characters.count > 1 else {
            throw Error.corruptXML(#file, #function, #line)
        }
        
        guard string.hasPrefix("#") else {
            throw Error.corruptXML(#file, #function, #line)
        }
        
        let subString = string.substringFromIndex(string.startIndex.successor())
        guard let element = state.elementsByID[subString] else {
            // print("We don't have a use element for id: \(subString)")
            state.events.append(Event(severity: .warning, message: "Could not find element with id: \(subString)"))
            return .None
        }
        // print("We have a use element for id: \(subString)")
        // print("Element is: \(element)")
        xmlElement["xlink:href"] = nil
        let ox = try SVGProcessor.stringToOptionalCGFloat(xmlElement["x"]?.stringValue)
        let oy = try SVGProcessor.stringToOptionalCGFloat(xmlElement["y"]?.stringValue)
        if let x = ox, let y = oy {
            let group = SVGGroup(children: [element])
            group.transform = Translate(tx: x, ty: y)
            xmlElement["x"] = nil
            xmlElement["y"] = nil
            return group
        }
        return element
    }

    public func processSVGGroup(xmlElement: NSXMLElement, state: State) throws -> SVGGroup? {
        guard let nodes = xmlElement.children else {
            return .None
        }
        var children = [SVGElement]()
        // A commented out <!--  --> node comes in as a NSXMLNode which causes crashes here.
        for node in nodes where node is NSXMLElement {
            if let svgElement = try self.processSVGElement(node as! NSXMLElement, state: state) {
                children.append(svgElement)
            }
        }

        let group = SVGGroup(children: children)
        xmlElement.setChildren(nil)
        return group
    }

    public func processSVGPath(xmlElement: NSXMLElement, state: State) throws -> SVGPath? {
        guard let string = xmlElement["d"]?.stringValue else {
            throw Error.expectedSVGElementNotFound(#file, #function, #line)
        }

        var pathArray = NSMutableArray(capacity: 0)
        let path = MICGPathCreateFromSVGPath(string, pathArray: &pathArray)
        xmlElement["d"] = nil
        let svgElement = SVGPath(path: path, svgPath: string)
        return svgElement
    }

    public func processSVGPolygon(xmlElement: NSXMLElement, state: State) throws -> SVGPolygon? {
        guard let pointsString = xmlElement["points"]?.stringValue else {
            throw Error.expectedSVGElementNotFound(#file, #function, #line)
        }
        let points = try SVGProcessor.parseListOfPoints(pointsString)
        
        xmlElement["points"] = nil
        let svgElement = SVGPolygon(points: points)
        return svgElement
    }

    public func processSVGPolyline(xmlElement: NSXMLElement, state: State) throws -> SVGPolyline? {
        guard let pointsString = xmlElement["points"]?.stringValue else {
            throw Error.expectedSVGElementNotFound(#file, #function, #line)
        }
        let points = try SVGProcessor.parseListOfPoints(pointsString)
        
        xmlElement["points"] = nil
        let svgElement = SVGPolyline(points: points)
        return svgElement
    }

    public func processSVGLine(xmlElement: NSXMLElement, state: State) throws -> SVGLine? {
        let x1 = try SVGProcessor.stringToCGFloat(xmlElement["x1"]?.stringValue)
        let y1 = try SVGProcessor.stringToCGFloat(xmlElement["y1"]?.stringValue)
        let x2 = try SVGProcessor.stringToCGFloat(xmlElement["x2"]?.stringValue)
        let y2 = try SVGProcessor.stringToCGFloat(xmlElement["y2"]?.stringValue)

        xmlElement["x1"] = nil
        xmlElement["y1"] = nil
        xmlElement["x2"] = nil
        xmlElement["y2"] = nil
        
        let startPoint = CGPoint(x: x1, y: y1)
        let endPoint = CGPoint(x: x2, y: y2)
        
        let svgElement = SVGLine(startPoint: startPoint, endPoint: endPoint)
        return svgElement
    }

    public func processSVGCircle(xmlElement: NSXMLElement, state: State) throws -> SVGCircle? {
        let cx = try SVGProcessor.stringToCGFloat(xmlElement["cx"]?.stringValue)
        let cy = try SVGProcessor.stringToCGFloat(xmlElement["cy"]?.stringValue)
        let r = try SVGProcessor.stringToCGFloat(xmlElement["r"]?.stringValue)

        xmlElement["cx"] = nil
        xmlElement["cy"] = nil
        xmlElement["r"] = nil
        
        let svgElement = SVGCircle(center: CGPoint(x: cx, y: cy), radius: r)
        return svgElement
    }

    public func processSVGEllipse(xmlElement: NSXMLElement, state: State) throws -> SVGEllipse? {
        let cx = try SVGProcessor.stringToCGFloat(xmlElement["cx"]?.stringValue, defaultVal: 0.0)
        let cy = try SVGProcessor.stringToCGFloat(xmlElement["cy"]?.stringValue, defaultVal: 0.0)
        let rx = try SVGProcessor.stringToCGFloat(xmlElement["rx"]?.stringValue)
        let ry = try SVGProcessor.stringToCGFloat(xmlElement["ry"]?.stringValue)
        
        xmlElement["cx"] = nil
        xmlElement["cy"] = nil
        xmlElement["rx"] = nil
        xmlElement["ry"] = nil

        let rect = CGRect(x: cx - rx, y: cy - ry, width: 2 * rx, height: 2 * ry)
        let svgElement = SVGEllipse(rect: rect)
        return svgElement
    }
    
    public func processSVGRect(xmlElement: NSXMLElement, state: State) throws -> SVGRect? {
        let x = try SVGProcessor.stringToCGFloat(xmlElement["x"]?.stringValue, defaultVal: 0.0)
        let y = try SVGProcessor.stringToCGFloat(xmlElement["y"]?.stringValue, defaultVal: 0.0)
        let width = try SVGProcessor.stringToCGFloat(xmlElement["width"]?.stringValue)
        let height = try SVGProcessor.stringToCGFloat(xmlElement["height"]?.stringValue)
        let rx = try SVGProcessor.stringToOptionalCGFloat(xmlElement["rx"]?.stringValue)
        let ry = try SVGProcessor.stringToOptionalCGFloat(xmlElement["ry"]?.stringValue)
        
        xmlElement["x"] = nil
        xmlElement["y"] = nil
        xmlElement["width"] = nil
        xmlElement["height"] = nil
        xmlElement["rx"] = nil
        xmlElement["ry"] = nil

        let svgElement = SVGRect(rect: CGRect(x: x, y: y, w: width, h: height), rx: rx, ry: ry)
        return svgElement
    }

    private func getAttributeWithKey(xmlElement: NSXMLElement, attribute: String) -> String? {
        if let name = xmlElement[attribute]?.stringValue {
            return name
        }
        
        // lets see if the font family name is in the style attribute.
        guard let style = xmlElement["style"]?.stringValue else {
            return Optional.None
        }
        
        let seperators = NSCharacterSet(charactersInString: ";")
        let trimChars = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let parts = style.componentsSeparatedByCharactersInSet(seperators)
        let pairSeperator = NSCharacterSet(charactersInString: ":")
        
        for part in parts {
            let pair = part.componentsSeparatedByCharactersInSet(pairSeperator)
            if pair.count != 2 {
                continue
            }
            let propertyName = pair[0].stringByTrimmingCharactersInSet(trimChars)
            let value = pair[1].stringByTrimmingCharactersInSet(trimChars)
            if propertyName == attribute {
                return value
            }
        }
        return Optional.None
    }
    
    func processSVGTextSpan(xmlElement: NSXMLElement, textOrigin: CGPoint, state: State) throws -> SVGTextSpan? {
        let x = try SVGProcessor.stringToCGFloat(xmlElement["x"]?.stringValue, defaultVal: textOrigin.x)
        let y = try SVGProcessor.stringToCGFloat(xmlElement["y"]?.stringValue, defaultVal: textOrigin.y)
        let newOrigin = CGPoint(x: x, y: y)
        guard let string = xmlElement.stringValue else {
            throw Error.corruptXML(#file, #function, #line)
        }
        let textSpan = SVGTextSpan(string: string, textOrigin: newOrigin)
        let textStyle = try self.processTextStyle(xmlElement)
        let style = try self.processStyle(xmlElement, state: state)
        let transform = try self.processTransform(xmlElement, elementKey: "transform")
        textSpan.textStyle = textStyle
        textSpan.style = style
        textSpan.transform = transform
        return textSpan
    }
    
    public func processSVGText(xmlElement: NSXMLElement, state: State) throws -> SVGSimpleText? {
        // Since I am not tracking the size of drawn text we can't do any text flow.
        // This means any text that isn't explicitly positioned we can't render.
        
        let x = try SVGProcessor.stringToCGFloat(xmlElement["x"]?.stringValue, defaultVal: 0.0)
        let y = try SVGProcessor.stringToCGFloat(xmlElement["y"]?.stringValue, defaultVal: 0.0)
        let textOrigin = CGPoint(x: x, y: y)

        xmlElement["x"] = nil
        xmlElement["y"] = nil

        let nodes = xmlElement.children ?? [NSXMLNode]()
        
        let textSpans = try nodes.map { node -> SVGTextSpan? in
            if let textItem = node as? NSXMLElement {
                return try self.processSVGTextSpan(textItem, textOrigin: textOrigin, state: state)
            }
            else if let string = node.stringValue {
                return SVGTextSpan(string: string, textOrigin: textOrigin)
            }
            return nil
        }

        var flattenedTextSpans = textSpans.flatMap { $0 }
        if flattenedTextSpans.isEmpty {
            if let text = xmlElement.stringValue where !text.isEmpty {
                flattenedTextSpans = [SVGTextSpan(string: text, textOrigin: textOrigin)]
            }
        }

        xmlElement.setChildren(nil)
        if flattenedTextSpans.count > 0 {
            return SVGSimpleText(spans: flattenedTextSpans)
        }
        return nil
    }
    
    private class func processColorString(colorString: String, opacity: CGFloat?) -> [NSObject : AnyObject]? {
        // Double optional. What?
        let ooColorDict = try? SVGColors.stringToColorDictionary(colorString)
        if let oColorDict = ooColorDict {
            if var colorDict = oColorDict,
                let theOpacity = opacity {
                if let originalOpacity = colorDict["alpha"] as? CGFloat {
                    colorDict["alpha"] = theOpacity * originalOpacity
                }
                else {
                    colorDict["alpha"] = theOpacity
                }
                return colorDict
            }
            return oColorDict
        }
        return nil
    }
    
    private class func processFillColor(colorString: String, svgElement: SVGElement, state: State?) -> StyleElement? {
        if colorString == "none" {
            svgElement.drawFill = false
            return nil
        }

        if colorString.hasPrefix("url(#") {
            let string = colorString.substringFromIndex(colorString.startIndex.advancedBy(5))
            let gradientString = string.substringToIndex(string.endIndex.advancedBy(-1))
            let gradientElement = state?.elementsByID[gradientString] as? SVGLinearGradient

            if let gradient = gradientElement {
                svgElement.gradientFill = gradient
            }
            else {
                print("Identifier did not refer to a linear gradient")
                return StyleElement.Alpha(0.0)
            }
            return .None
        }
        else if let colorDict = SVGProcessor.processColorString(colorString, opacity: state?.fillOpacity),
            let color = SVGColors.colorDictionaryToCGColor(colorDict) {
            return StyleElement.FillColor(color)
        }
        else {
            return .None
        }
    }

    private class func processStrokeColor(colorString: String, opacity: CGFloat?) -> StyleElement? {
        if let colorDict = SVGProcessor.processColorString(colorString, opacity: opacity),
            let color = SVGColors.colorDictionaryToCGColor(colorDict)
        {
            return StyleElement.StrokeColor(color)
        }
        else {
            return nil
        }
    }

    private class func processPresentationAttribute(style: String, inout styleElements: [StyleElement], svgElement: SVGElement, state: State) throws {
        let seperators = NSCharacterSet(charactersInString: ";")
        let trimChars = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        let parts = style.componentsSeparatedByCharactersInSet(seperators)
        let pairSeperator = NSCharacterSet(charactersInString: ":")
        
        // Since the fill and stroke colors can include an alpha component which
        // can be specified seperately, we need to treat these as special cases.
        var fillColor: String? = .None
        var strokeColor: String? = .None

        let styles:[StyleElement?] = try parts.map {
            let pair = $0.componentsSeparatedByCharactersInSet(pairSeperator)
            if pair.count != 2 {
                return .None
            }
            let propertyName = pair[0].stringByTrimmingCharactersInSet(trimChars)
            let value = pair[1].stringByTrimmingCharactersInSet(trimChars)
            switch(propertyName) {
                case "opacity":
                    if let value = try SVGProcessor.stringToOptionalClampedCGFloat(value, minClamp: 0.0, maxClamp: 1.0) {
                        return StyleElement.Alpha(value)
                    }
                    return .None
                case "fill":
                    fillColor = value
                    return .None
                    // return processFillColor(value, svgElement: svgElement, state:state)
                case "fill-opacity":
                    state.fillOpacity = try SVGProcessor.stringToCGFloat(value)
                    return .None
                case "fill-rule":
                    if value == "evenodd" {
                        if var pathElement = svgElement as? PathGenerator {
                            pathElement.evenOdd = true
                        }
                    }
                    return .None
                case "stroke":
                    strokeColor = value
                    return .None
                    // return processStrokeColor(value)
                case "stroke-opacity":
                    state.strokeOpacity = try SVGProcessor.stringToCGFloat(value)
                    return .None
                case "stroke-width":
                    return StyleElement.LineWidth(try SVGProcessor.stringToCGFloat(value))
                case "stroke-miterlimit":
                    return StyleElement.MiterLimit(try SVGProcessor.stringToCGFloat(value))
                case "stroke-linejoin":
                    let lineJoin = CGLineJoin.valueFromSVG(string: value)
                    
                    if let lineJoinValue = lineJoin {
                        return StyleElement.LineJoin(lineJoinValue)
                    }
                    return .None
                case "stroke-linecap":
                    let lineCap = CGLineCap.valueFromSVG(string: value)
                    
                    if let lineCapValue = lineCap {
                        return StyleElement.LineCap(lineCapValue)
                    }
                    return .None
                case "display":
                    if value == "none" {
                        svgElement.display = false
                    }
                    return .None
                case "stroke-dasharray":
                    if let dashSegmentsOpt = try? SVGProcessor.processDashSegments(value),
                        let dashSegments = dashSegmentsOpt {
                        return StyleElement.LineDash(dashSegments)
                    }
                    return .None
                case "stroke-dashoffset":
                    if let dashPhase =  try SVGProcessor.stringToOptionalCGFloat(value) {
                        return StyleElement.LineDashPhase(dashPhase)
                    }
                    return .None
                default:
                    return .None
            }
        }

        styles.forEach {
            if let theStyle = $0 {
                styleElements.append(theStyle)
            }
        }
        if let color = fillColor {
            if let styleElement = SVGProcessor.processFillColor(color, svgElement: svgElement, state:state) {
                styleElements.append(styleElement)
            }
        }

        if let color = strokeColor {
            if let styleElement = SVGProcessor.processStrokeColor(color, opacity:state.strokeOpacity) {
                styleElements.append(styleElement)
            }
        }
    }
    
    public func processTextStyle(xmlElement: NSXMLElement) throws -> TextStyle? {
        // We won't be scrubbing the style element after checking for font family and font size here.
        var textStyleElements: [TextStyleElement] = []
        let fontFamily = self.getAttributeWithKey(xmlElement, attribute: "font-family")
        if let fontFamily = fontFamily {
            let familyName = fontFamily.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "'"))
            textStyleElements.append(TextStyleElement.fontFamily(familyName))
        }
        xmlElement["font-family"] = nil
        
        let fontSizeString = self.getAttributeWithKey(xmlElement, attribute: "font-size")
        if let fontSizeString = fontSizeString {
            let fontSize = try SVGProcessor.stringToCGFloat(fontSizeString)
            textStyleElements.append(TextStyleElement.fontSize(fontSize))
        }
        xmlElement["font-size"] = nil
        
        if let textAnchor = self.getAttributeWithKey(xmlElement, attribute: "text-anchor") {
            textStyleElements.append(TextStyleElement.textAnchor(TextAnchor(input: textAnchor)))
        }
        xmlElement["text-anchor"] = nil
        
        if textStyleElements.count > 0 {
            var textStyle = TextStyle()
            textStyleElements.forEach {
                textStyle.add($0)
            }
            return textStyle
        }
        return nil
    }
    
    public func processStyle(xmlElement: NSXMLElement, state: State, svgElement: SVGElement? = .None) throws -> SwiftGraphics.Style? {
        // http://www.w3.org/TR/SVG/styling.html
        var styleElements = [StyleElement]()

        if let value = xmlElement["style"]?.stringValue,
            let svgElement = svgElement {
            try SVGProcessor.processPresentationAttribute(value, styleElements: &styleElements, svgElement: svgElement, state:state)
            xmlElement["style"] = nil
        }

        if let value = try SVGProcessor.stringToOptionalCGFloat(xmlElement["fill-opacity"]?.stringValue) {
            state.fillOpacity = value
            xmlElement["fill-opacity"] = nil
        }

        if let value = xmlElement["fill"]?.stringValue,
            let svgElement = svgElement {
            if let styleElement = SVGProcessor.processFillColor(value, svgElement: svgElement, state:state) {
                styleElements.append(styleElement)
            }
            xmlElement["fill"] = nil
        }
        
        if let value = try SVGProcessor.stringToOptionalCGFloat(xmlElement["stroke-opacity"]?.stringValue) {
            state.strokeOpacity = value
            xmlElement["stroke-opacity"] = nil
        }

        if let value = xmlElement["stroke"]?.stringValue {
            if let styleElement = SVGProcessor.processStrokeColor(value, opacity: state.strokeOpacity) {
                styleElements.append(styleElement)
            }
            xmlElement["stroke"] = nil
        }

        if let value = try SVGProcessor.stringToOptionalClampedCGFloat(xmlElement["opacity"]?.stringValue, minClamp: 0.0, maxClamp: 1.0) {
            styleElements.append(StyleElement.Alpha(value))
            xmlElement["opacity"] = nil
        }

        if let value = xmlElement["fill-rule"]?.stringValue {
            if value == "evenodd" {
                if let svgElement = svgElement,
                    var pathElement = svgElement as? PathGenerator {
                    pathElement.evenOdd = true
                }
            }
        }

        let strokeWidth = try SVGProcessor.stringToOptionalCGFloat(xmlElement["stroke-width"]?.stringValue)
        if let strokeWidthValue = strokeWidth {
            styleElements.append(StyleElement.LineWidth(strokeWidthValue))
        }
        xmlElement["stroke-width"] = nil

        let lineJoinString = xmlElement["stroke-linejoin"]?.stringValue
        if let lineJoinStringValue = lineJoinString,
            let lineJoin = CGLineJoin.valueFromSVG(string: lineJoinStringValue) {
            styleElements.append(StyleElement.LineJoin(lineJoin))
        }
        xmlElement["stroke-linejoin"] = nil

        let lineCapString = xmlElement["stroke-linecap"]?.stringValue
        if let lineCapStringValue = lineCapString,
            let lineCap = CGLineCap.valueFromSVG(string: lineCapStringValue) {
            styleElements.append(StyleElement.LineCap(lineCap))
        }
        xmlElement["stroke-linecap"] = nil

        let mitreLimit = try SVGProcessor.stringToOptionalCGFloat(xmlElement["stroke-miterlimit"]?.stringValue)
        if let mitreLimitValue = mitreLimit {
            styleElements.append(StyleElement.MiterLimit(mitreLimitValue))
        }
        xmlElement["stroke-miterlimit"] = nil

        if let value = xmlElement["display"]?.stringValue {
            if let svgElement = svgElement where value == "none" {
                svgElement.display = false
            }
            xmlElement["display"] = nil
        }
        
        if let dashSegments = try SVGProcessor.processDashSegments(xmlElement) {
            styleElements.append(StyleElement.LineDash(dashSegments))
            let dashPhase =  try SVGProcessor.stringToOptionalCGFloat(xmlElement["stroke-dashoffset"]?.stringValue)
            if let dashPhaseValue = dashPhase {
                styleElements.append(StyleElement.LineDashPhase(dashPhaseValue))
            }
        }
        
        if styleElements.count > 0 {
            return SwiftGraphics.Style(elements: styleElements)
        }
        else {
            return nil
        }
    }

    public class func processDashSegments(value: String) throws -> [CGFloat]? {
        let COMMA = Literal(",")
        let OPT_COMMA = zeroOrOne(COMMA).makeStripped()
        let VALUE_LIST = oneOrMore((cgFloatValue + OPT_COMMA).makeStripped().makeFlattened())
        let result = try VALUE_LIST.parse(value)
        switch result {
            case .Ok(let value):
                guard let value = value as? [Any] else {
                    return .None
                }
                return value.map() { return $0 as! CGFloat }
            default:
                return .None
        }
    }
    
    private class func processDashSegments(xmlElement: NSXMLElement) throws -> [CGFloat]? {
        guard let value = xmlElement["stroke-dasharray"]?.stringValue else {
            return nil
        }
        let result = try self.processDashSegments(value)
        xmlElement["stroke-dasharray"] = nil
        return result
    }

    private func processTransform(xmlElement: NSXMLElement, elementKey: String) throws -> Transform2D? {
        guard let value = xmlElement[elementKey]?.stringValue else {
            return nil
        }
        xmlElement[elementKey] = nil
        let transform = try svgTransformAttributeStringToTransform(value)
        return transform
    }

    private func processInheritedGradient(xmlElement: NSXMLElement, elementKey: String, state: State) -> SVGLinearGradient? {
        guard let value = xmlElement[elementKey]?.stringValue else {
            print("No key for inherited gradient")
            return nil
        }
        print("Key for inherited gradient is: \(value)")
        xmlElement[elementKey] = nil
        return state.elementsByID[value.substringFromIndex(value.startIndex.advancedBy(1))] as? SVGLinearGradient
    }

    private func processGradientStop(xmlElement: NSXMLElement) throws -> SVGGradientStop {
        let offset = try SVGProcessor.stringToCGFloat(xmlElement["offset"]?.stringValue)
        
        if let style = xmlElement["style"]?.stringValue {
            let seperators = NSCharacterSet(charactersInString: ";")
            let trimChars = NSCharacterSet.whitespaceAndNewlineCharacterSet()
            let parts = style.componentsSeparatedByCharactersInSet(seperators)
            let pairSeperator = NSCharacterSet(charactersInString: ":")
            
            var stopColor: CGColor?
            var stopOpacity: CGFloat = 1.0

            for styleItem in parts where !styleItem.isEmpty {
                let pair = styleItem.componentsSeparatedByCharactersInSet(pairSeperator)
                if pair.count != 2 {
                    throw Error.invalidSVG(#file, #function, #line)
                }
                let propertyName = pair[0].stringByTrimmingCharactersInSet(trimChars)
                let value = pair[1].stringByTrimmingCharactersInSet(trimChars)
                switch(propertyName) {
                    case "stop-color":
                        guard let stopColorDict = SVGProcessor.processColorString(value, opacity: .None),
                            let color = SVGColors.colorDictionaryToCGColor(stopColorDict) else {
                                throw Error.invalidSVG(#file, #function, #line)
                        }
                        stopColor = color

                    case "stop-opacity":
                        stopOpacity = try SVGProcessor.stringToCGFloat(value, defaultVal: 1.0)
                    
                    default:
                        print("Unhandled stop property \(propertyName)")
                        break
                }
            }
            guard var color = stopColor else {
                throw Error.invalidSVG(#file, #function, #line)
            }
            if stopOpacity < 1.0 {
                color = CGColorCreateCopyWithAlpha(color, stopOpacity)!
            }
            return SVGGradientStop(offset: offset, opacity: stopOpacity, color: color)
        }

        let colorString: String
        if let stopColor = xmlElement["stop-color"] {
            if let stopColorString = stopColor.stringValue {
                colorString = stopColorString
            }
            else {
                throw Error.corruptXML(#file, #function, #line)
            }
        }
        else {
            colorString = "black"
        }

        guard let stopColorDict = SVGProcessor.processColorString(colorString, opacity: .None),
            var stopColor = SVGColors.colorDictionaryToCGColor(stopColorDict) else {
            throw Error.invalidSVG(#file, #function, #line)
        }
        let stopOpacity = try SVGProcessor.stringToCGFloat(xmlElement["stop-opacity"]?.stringValue, defaultVal: 1.0)
        if stopOpacity < 1.0 {
            stopColor = CGColorCreateCopyWithAlpha(stopColor, stopOpacity)!
        }
        return SVGGradientStop(offset: offset, opacity: stopOpacity, color: stopColor)
    }
    
    private func processGradientStops(xmlElements: [NSXMLNode]?) throws -> [SVGGradientStop]? {
        guard let xmlElements = xmlElements else {
            return .None
        }
        var gradientStops = [SVGGradientStop]()
        for xmlNode in xmlElements {
            guard let xmlElement = xmlNode as? NSXMLElement else {
                throw Error.corruptXML(#file, #function, #line)
            }
            let stop = try processGradientStop(xmlElement)
            gradientStops.append(stop)
        }
        if gradientStops.isEmpty {
            return .None
        }
        return gradientStops
    }
    
    public func processGradientDefs(xmlElement: NSXMLElement, state: State) throws -> SVGLinearGradient? {
        let stops = try processGradientStops(xmlElement.children)
        let x1 = try SVGProcessor.stringToCGFloat(xmlElement["x1"]?.stringValue, defaultVal: 0.0)
        let y1 = try SVGProcessor.stringToCGFloat(xmlElement["y1"]?.stringValue, defaultVal: 0.0)
        let x2 = try SVGProcessor.stringToCGFloat(xmlElement["x2"]?.stringValue, defaultVal: 1.0)
        let y2 = try SVGProcessor.stringToCGFloat(xmlElement["y2"]?.stringValue, defaultVal: 1.0)

        xmlElement["x1"] = nil
        xmlElement["y1"] = nil
        xmlElement["x2"] = nil
        xmlElement["y2"] = nil

        let gradientUnitString = xmlElement["gradientUnits"]?.stringValue ?? "objectBoundingBox"
        guard let gradientUnit = SVGGradientUnit(rawValue: gradientUnitString) else {
            throw Error.invalidSVG(#file, #function, #line)
        }
        xmlElement["gradientUnits"] = nil
        let point1 = SVGProcessor.makeOptionalPoint(x: x1, y: y1)
        let point2 = SVGProcessor.makeOptionalPoint(x: x2, y: y2)
        
        let gradientTransform = try processTransform(xmlElement, elementKey: "gradientTransform")
        let inherited: SVGLinearGradient?
        if let _ = xmlElement["xlink:href"]?.stringValue {
            inherited = processInheritedGradient(xmlElement, elementKey: "xlink:href", state: state)
        }
        else {
            inherited = nil
        }
        print("In process gradient defs")
        return SVGLinearGradient(stops: stops, gradientUnit: gradientUnit,
                                 point1: point1, point2: point2,
                                 transform: gradientTransform, inherited: inherited)
    }
}

private protocol Parser {
    static func makeOptionalPoint(x x: CGFloat?, y: CGFloat?) -> CGPoint?
    static func floatsToPoints(data: [Float]) throws -> [CGPoint]
    static func parseListOfPoints(entry : String) throws -> [CGPoint]
    static func stringToCGFloat(string: String?) throws -> CGFloat
    static func stringToOptionalCGFloat(string: String?) throws -> CGFloat?
    static func stringToCGFloat(string: String?, defaultVal: CGFloat) throws -> CGFloat
}

// MARK: SVGProcessor: String to number parser methods.

extension SVGProcessor: Parser {
    private class func makeOptionalPoint(x x: CGFloat?, y: CGFloat?) -> CGPoint? {
        if let x = x, let y = y {
            return CGPoint(x: x, y: y)
        }
        return .None
    }
    
    /// Convert an even list of floats to CGPoints
    private class func floatsToPoints(data: [Float]) throws -> [CGPoint] {
        guard data.count % 2 == 0 else {
            throw Error.corruptXML(#file, #function, #line)
        }
        var out : [CGPoint] = []
        for i in 0.stride(to: data.count, by: 2) {
            out.append(CGPoint(x: CGFloat(data[i]), y: CGFloat(data[i + 1])))
        }
        
        return out
    }
    
    /// Parse the list of points from a polygon/polyline entry
    private class func parseListOfPoints(entry : String) throws -> [CGPoint] {
        // Split by all commas and whitespace, then group into coords of two floats
        let entry = entry.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let separating = NSMutableCharacterSet.whitespaceAndNewlineCharacterSet()
        separating.addCharactersInString(",")
        let parts = entry.componentsSeparatedByCharactersInSet(separating).filter { !$0.isEmpty }
        return try floatsToPoints(parts.map({Float($0)!}))
    }

    private class func stringToCGFloat(string: String?) throws -> CGFloat {
        guard let string = string else {
            throw Error.expectedSVGElementNotFound(#file, #function, #line)
        }
        // This is probably a bit reckless.
        let string2 = string.stringByTrimmingCharactersInSet(NSCharacterSet.lowercaseLetterCharacterSet())
        if string2.characters.isEmpty {
            throw Error.corruptXML(#file, #function, #line)
        }
        if string2.characters.last! == Character("%") {
            return try self.percentageStringToCGFloat(String(string2.characters.dropLast()))
        }
        guard let value = NSNumberFormatter().numberFromString(string2) else {
            throw Error.corruptXML(#file, #function, #line)
        }
        return CGFloat(value.doubleValue)
    }
    
    private class func stringToOptionalCGFloat(string: String?) throws -> CGFloat? {
        guard let string = string else {
            return Optional.None
        }
        let string2 = string.stringByTrimmingCharactersInSet(NSCharacterSet.lowercaseLetterCharacterSet())
        guard let value = NSNumberFormatter().numberFromString(string2) else {
            throw Error.corruptXML(#file, #function, #line)
        }
        return CGFloat(value.doubleValue)
    }
    
    private class func stringToOptionalClampedCGFloat(string: String?, minClamp: CGFloat = -CGFloat.max, maxClamp: CGFloat = CGFloat.max) throws -> CGFloat? {
        if minClamp > maxClamp {
            throw Error.invalidFunctionParameters(#file, #function, #line)
        }
        guard let value = try stringToOptionalCGFloat(string) else {
            return .None
        }
        return max(minClamp, min(maxClamp, value))
    }
    
    private class func stringToCGFloat(string: String?, defaultVal: CGFloat) throws -> CGFloat {
        guard let stringValue = string else {
            return defaultVal
        }
        return try stringToCGFloat(stringValue)
    }
    
    private class func percentageStringToCGFloat(string: String?) throws -> CGFloat {
        guard let string = string else {
            throw Error.corruptXML(#file, #function, #line)
        }
        
        let theValue = NSNumberFormatter().numberFromString(string)
        guard let value = theValue else {
            throw Error.corruptXML(#file, #function, #line)
        }
        return CGFloat(value.doubleValue * 0.01)
    }
}

extension SVGProcessor.Event: CustomStringConvertible {
    public var description: String {
        get {
            switch severity {
                case .debug:
                    return "DEBUG: \(message)"
                case .info:
                    return "INFO: \(message)"
                case .warning:
                    return "WARNING: \(message)"
                case .error:
                    return "ERROR: \(message)"
            }
        }
    }
}
