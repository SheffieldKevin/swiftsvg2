//
//  SVGDocument.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 2/25/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Foundation

import SwiftGraphics

// MARK: -

public protocol Node {
    associatedtype ParentType
    var parent: ParentType? { get }
}

public protocol GroupNode: Node {
    associatedtype NodeType
    var children: [NodeType] { get }
}

// MARK: -

public class SVGElement: Node {
    public typealias ParentType = SVGContainer
    public weak var parent: SVGContainer? = nil
    public internal(set) var style: SwiftGraphics.Style? = nil
    public internal(set) var transform: Transform2D? = nil
    public let uuid = NSUUID() // TODO: This is silly.
    public internal(set) var id: String? = nil
    public internal(set) var xmlElement: NSXMLElement? = nil
    public internal(set) var textStyle: TextStyle? = nil
    public internal(set) var gradientFill: SVGElement? = nil
    public internal(set) var display = true

    var drawFill = true // If fill="none" this explictly turns off fill.
    var fillColor: CGColor? {
        get {
            if !drawFill {
                return nil
            }
            if let color = self.style?.fillColor {
                return color
            }
            guard let parent = self.parent else {
                return nil
            }
            
            if parent is SVGGroup {
                return parent.fillColor
            }
            
            if parent is SVGDocument {
                return try! SVGColors.stringToColor("black")
            }
            return nil
        }
    }
    
    var hasFill: Bool {
        get { return self.fillColor != nil }
    }

    // Different default behaviour for fill and stroke. Default fill is to draw
    // black, while default stroke is not drawing anything.
    var strokeColor: CGColor? {
        get {
            if let color = self.style?.strokeColor {
                return color
            }
            guard let parent = self.parent else {
                return nil
            }
            
            if parent is SVGGroup {
                return parent.strokeColor
            }
            return nil
        }
    }

    var fontFamily: String {
        get {
            if let fontFamily = self.textStyle?.fontFamily {
                return fontFamily
            }
            guard let parent = self.parent else {
                return "Helvetica"
            }
            if parent is SVGGroup {
                return parent.fontFamily
            }
            return "Helvetica"
        }
    }

    var fontSize: CGFloat {
        get {
            if let fontSize = self.textStyle?.fontSize {
                return fontSize
            }
            guard let parent = self.parent else {
                return 12
            }
            
            return parent.fontSize
        }
    }

    var hasStroke: Bool {
        get { return self.strokeColor != nil }
    }

    var numParents: Int {
        if let parent = parent {
            return parent.numParents + 1
        }
        return 0
    }

    public final func printElement()
    {
        var description = "================================================================\n"
        description += "Element with numParents: \(numParents) \n"
        if let id = id { description += "id: \(id). " }
        description += "type: \(self.dynamicType). "
        if let _ = self.style { description += "Has style. " }
        if let _ = self.transform { description += "Has transform. " }
        print(description)
    }
    
    public func printElements() {
        printElement()
    }
    
    func printSelfAndParents() {
        var parent: SVGElement? = self
        while let localParent = parent {
            localParent.printElement()
            parent = localParent.parent
        }
    }
}

extension SVGElement: Equatable {
}

public func == (lhs: SVGElement, rhs: SVGElement) -> Bool {
    return lhs === rhs
}

extension SVGElement: Hashable {
    public var hashValue: Int {
        return uuid.hash
    }
}

// MARK: -

public class SVGContainer: SVGElement, GroupNode {
    public var children: [SVGElement] = [] {
        didSet {
            children.forEach() { $0.parent = self }
        }
    }

    override init() {
        super.init()
    }

    public convenience init(children:[SVGElement]) {
        self.init()
        self.children = children
        self.children.forEach() { $0.parent = self }
    }

    public func replace(oldElement: SVGElement, with newElement: SVGElement) throws {

        guard let index = children.indexOf(oldElement) else {
            // TODO: throw
            fatalError("BOOM")
        }

        oldElement.parent = nil
        children[index] = newElement
        newElement.parent = self
    }
    
    override public func printElements() {
        self.printElement()
        self.children.forEach() { $0.printElements() }
    }
}

// MARK: -

public class SVGDocument: SVGContainer {

    public enum Profile {
        case full
        case tiny
        case basic
    }

    public struct Version {
        let majorVersion: Int
        let minorVersion: Int
    }

    public var profile: Profile?
    public var version: Version?
    public var viewBox: CGRect?
    public var title: String?
    public var documentDescription: String?
}

// MARK: -

public class SVGGroup: SVGContainer {

}

// MARK: -

public typealias MovingImagesPath = [NSString : NSObject]
public typealias MovingImagesText = [NSString : NSObject]

public protocol PathGenerator: CGPathable {
    var mipath:MovingImagesPath { get }
    var svgpath:String? { get }
}

public protocol TextRenderer {
    var mitext:MovingImagesText { get }
    var cttext:CFAttributedString { get }
    var textOrigin:CGPoint { get }
}

// MARK: -

public class SVGPath: SVGElement, PathGenerator {
    public private(set) var cgpath: CGPath
    public private(set) var mipath: MovingImagesPath
    public private(set) var svgpath: String?

    public init(path: CGPath, miPath: MovingImagesPath, svgPath: String) {
        self.cgpath = path
        self.mipath = miPath
        self.svgpath = svgPath
    }

    internal func addSVGPath(svgPath: SVGPath) {
        addMIPaths(&self.mipath, miPath2: svgPath.mipath)
        self.cgpath = self.cgpath + svgPath.cgpath
        self.svgpath = .None
    }
}

public class SVGLine: SVGElement, PathGenerator {
    public let startPoint: CGPoint
    public let endPoint: CGPoint

    lazy public var cgpath: CGPath = self.makePath()
    lazy public var mipath: MovingImagesPath = makeLineDictionary(self.startPoint, endPoint: self.endPoint)
    public var svgpath: String? {
        get { return .None }
    }

    public init(startPoint: CGPoint, endPoint: CGPoint) {
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    private func makePath() -> CGPath {
        let localPath = CGPathCreateMutable()
        localPath.move(startPoint)
        localPath.addLine(endPoint)
        localPath.close()
        return localPath
    }
}

public class SVGPolygon: SVGElement, PathGenerator {
    public let polygon:SwiftGraphics.Polygon
    
    lazy public var cgpath:CGPath = self.polygon.cgpath
    lazy public var mipath:MovingImagesPath = makePolygonDictionary(self.polygon.points)
    public var svgpath: String? {
        get { return .None }
    }
    
    public init(points: [CGPoint]) {
        self.polygon = SwiftGraphics.Polygon(points: points)
    }
}

public class SVGPolyline: SVGElement, PathGenerator {
    public let points: [CGPoint]
    
    lazy public var cgpath:CGPath = self.makePath()
    lazy public var mipath:MovingImagesPath = makePolylineDictionary(self.points)
    public var svgpath: String? {
        get { return .None }
    }
    
    public init(points: [CGPoint]) {
        self.points = points
    }
    
    private func makePath() -> CGPath {
        let localPath = CGPathCreateMutable()
        CGPathAddLines(localPath, nil, points, points.count)
        return localPath
    }
}

public class SVGRect: SVGElement, PathGenerator {
    public let rect: Rectangle
    public let rx: CGFloat?
    public let ry: CGFloat?

    lazy public var cgpath:CGPath = self.makeCGPath()
    lazy public var mipath:MovingImagesPath = self.makeMIPath()
    public var svgpath: String? {
        get { return .None }
    }
    
    // http://www.w3.org/TR/SVG/shapes.html#RectElement
    public init(rect: CGRect, rx: CGFloat? = Optional.None, ry: CGFloat? = Optional.None) {
        self.rect = Rectangle(frame: rect)
        if let lrx = rx {
            self.rx = min(lrx, rect.width * 0.5)
            if let lry = ry {
                self.ry = min(lry, rect.height * 0.5)
            }
            else {
                self.ry = min(lrx, rect.height * 0.5) // ry defaults to cx if not defined.
            }
        }
        else if let lry = ry {
            self.ry = min(lry, rect.height * 0.5)
            self.rx = min(lry, rect.width * 0.5) // rx defaults to cy if not defined.
        }
        else {
            self.rx = Optional.None
            self.ry = Optional.None
        }
    }

    public var notRounded: Bool {
        get {
            return self.rx == nil && self.ry == nil
        }
    }
    
    private func makeCGPath() -> CGPath {
        if self.notRounded {
            return self.rect.cgpath
        }
        
        return CGPathCreateWithRoundedRect(self.rect.frame, self.rx!, self.ry!, nil)
    }
    
    private func makeMIPath() -> MovingImagesPath {
        if self.notRounded {
            return makeRectDictionary(rect.frame, hasFill: hasFill, hasStroke: hasStroke)
        }
        return makeRoundedRectDictionary(rect.frame, rx: rx!, ry: ry!, hasFill: hasFill, hasStroke: hasStroke)
    }
}

public class SVGEllipse: SVGElement, PathGenerator {
    public var rect: CGRect!
    
    lazy public var cgpath:CGPath = CGPathCreateWithEllipseInRect(self.rect, nil)
    lazy public var mipath:MovingImagesPath = self.makeMIPath()
    public var svgpath: String? {
        get { return .None }
    }
    
    public init(rect: CGRect) {
        self.rect = rect
    }
    
    private func makeMIPath() -> MovingImagesPath {
        return makeOvalDictionary(rect, hasFill: hasFill, hasStroke: hasStroke)
    }
}

public class SVGCircle: SVGElement, PathGenerator {
    public let center: CGPoint
    public let radius: CGFloat

    lazy public var cgpath:CGPath = CGPathCreateWithEllipseInRect(self.rect, nil)
    lazy public var mipath:MovingImagesPath = self.makeMIPath()
    public var svgpath: String? {
        get { return .None }
    }
    
    public var rect: CGRect {
        let rectSize = CGSize(width: 2.0 * radius, height: 2.0 * radius)
        let rectOrigin = CGPoint(x: center.x - radius, y: center.y - radius)
        return CGRect(origin: rectOrigin, size: rectSize)
    }

    public init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.radius = radius
    }

    private func makeMIPath() -> MovingImagesPath {
        return makeOvalDictionary(rect, hasFill: hasFill, hasStroke: hasStroke)
    }
}

public class SVGTextSpan: TextRenderer {
    private(set) var textElement: SVGSimpleText!
    let string: CFString

    internal(set) var style: SwiftGraphics.Style? = nil
    internal(set) var transform: Transform2D? = nil
    internal(set) var textStyle: TextStyle? = nil
    
    public lazy var mitext:MovingImagesText = self.makeMIText()
    public lazy var cttext:CFAttributedString = self.makeAttributedString()
    
    public let textOrigin: CGPoint
    
    init(string: String, textOrigin: CGPoint) {
        self.string = string
        self.textOrigin = textOrigin
    }
    
    internal var fillColor: CGColor? {
        get {
            if let style = self.style, let fillColor = style.fillColor {
                return fillColor
            }
            return textElement.fillColor
        }
    }
    
    internal var strokeColor: CGColor? {
        get {
            if let style = self.style, let strokeColor = style.strokeColor {
                return strokeColor
            }
            return textElement.strokeColor
        }
    }
    
    internal var hasStroke: Bool { return self.strokeColor == nil ? false : true }
    
    internal var strokeWidth: CGFloat? {
        get {
            guard let _ = self.strokeColor else {
                return nil
            }
            
            let strokeWidth: CGFloat
            if let style = self.style, let lineWidth = style.lineWidth {
                strokeWidth = lineWidth
            }
            else if let style = textElement.style, let lineWidth = style.lineWidth {
                strokeWidth = lineWidth
            }
            else {
                strokeWidth = 1.0
            }
            if let _ = self.fillColor {
                return -strokeWidth
            }
            return strokeWidth
        }
    }

    internal var fontFamily: String {
        get {
            if let textStyle = self.textStyle, let fontFamily = textStyle.fontFamily {
                return fontFamily
            }
            return textElement.fontFamily
        }
    }
    
    internal var fontSize: CGFloat {
        get {
            if let textStyle = self.textStyle, let fontSize = textStyle.fontSize {
                return fontSize
            }
            if let textStyle = textElement.textStyle, let fontSize = textStyle.fontSize {
                return fontSize
            }
            return 12.0
        }
    }

    private func makeMIText() -> MovingImagesText {
        return makeMovingImagesText(self.string,
                          fontSize: self.fontSize,
                postscriptFontName: self.getPostscriptFontName(),
                        textOrigin: self.textOrigin,
                         fillColor: self.fillColor,
                       strokeWidth: self.strokeWidth,
                       strokeColor: self.strokeColor)
    }
    
    private func getPostscriptFontName() -> NSString {
        var attributes: [NSString : AnyObject] = [
            kCTFontFamilyNameAttribute : self.fontFamily,
            kCTFontSizeAttribute : self.fontSize,
        ]
        let descriptor = CTFontDescriptorCreateWithAttributes(attributes)
        if let name = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) {
            return name as! NSString
        }
        
        // Default to Helvetica.
        attributes[kCTFontFamilyNameAttribute] = "Helvetica"
        let descriptor2 = CTFontDescriptorCreateWithAttributes(attributes)
        return CTFontDescriptorCopyAttribute(descriptor2, kCTFontNameAttribute)! as! NSString
    }
    
    private func makeAttributedString() -> CFAttributedString {
        var attributes: [NSString : AnyObject] = [
            kCTFontAttributeName : CTFontCreateWithName(self.getPostscriptFontName(), self.fontSize, nil),
        ]
        
        if let fillColor = self.fillColor {
            attributes[kCTForegroundColorAttributeName] = fillColor
        }
        
        if let strokeColor = self.strokeColor {
            attributes[kCTStrokeColorAttributeName] = strokeColor
        }
        
        if let strokeWidth = self.strokeWidth {
            attributes[kCTStrokeWidthAttributeName] = strokeWidth
        }

        return CFAttributedStringCreate(kCFAllocatorDefault, self.string, attributes)
    }
}

// TODO: There is stuff to be fixed here with the way that font styles are obtained and set.
public class SVGSimpleText: SVGElement {
    internal let spans: [SVGTextSpan]
    public init(spans: [SVGTextSpan]) {
        self.spans = spans
        super.init()
        self.spans.forEach() { $0.textElement = self }
    }

}

public class SVGLinearGradientStop {
    internal let offset: CGFloat
    internal let opacity: CGFloat
    internal let color: CGColor

    public init(offset: CGFloat, opacity: CGFloat, color: CGColor) {
        self.offset = offset
        self.opacity = opacity
        self.color = color
    }
}

public class SVGLinearGradient: SVGElement {
    internal let point1: CGPoint?
    internal let point2: CGPoint?
    internal let stops: [SVGLinearGradientStop]
    
    public init(stops: [SVGLinearGradientStop], point1: CGPoint? = .None, point2: CGPoint? = .None) {
        self.stops = stops
        self.point1 = point1
        self.point2 = point2
        super.init()
    }
}
