//
//  SVGDocument.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 2/25/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Foundation

import SwiftGraphics

// TODO: This needs to be moved somewhere sane.
public extension SwiftGraphics.Style {
    mutating func apply(newStyle: Style) {
        if let fillColor = newStyle.fillColor {
            self.fillColor = fillColor
        }
        if let strokeColor = newStyle.strokeColor {
            self.strokeColor = strokeColor
        }
        if let lineWidth = newStyle.lineWidth {
            self.lineWidth = lineWidth
        }
        if let lineCap = newStyle.lineCap {
            self.lineCap = lineCap
        }
        if let lineJoin = newStyle.lineJoin {
            self.lineJoin = lineJoin
        }
        if let miterLimit = newStyle.miterLimit {
            self.miterLimit = miterLimit
        }
        if let lineDash = newStyle.lineDash {
            self.lineDash = lineDash
        }
        if let lineDashPhase = newStyle.lineDashPhase {
            self.lineDashPhase = lineDashPhase
        }
        if let flatness = newStyle.flatness {
            self.flatness = flatness
        }
        if let alpha = newStyle.alpha {
            self.alpha = alpha
        }
        if let blendMode = newStyle.blendMode {
            self.blendMode = blendMode
        }
    }
}

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
    static var numElements = 0
    public typealias ParentType = SVGContainer
    public weak var parent: SVGContainer? = nil
    public internal(set) var style: SwiftGraphics.Style? = nil
    public internal(set) var transform: Transform2D? = nil
    public let uuid = NSUUID() // TODO: This is silly.
    public internal(set) var id: String? = nil
    public internal(set) var xmlElement: NSXMLElement? = nil
    public internal(set) var textStyle: TextStyle? = nil
    public internal(set) var gradientFill: SVGLinearGradient? = nil
    public internal(set) var display = true

    init() {
        // print("init: Number of elements = \(SVGElement.numElements)")
        SVGElement.numElements += 1
    }
    
    deinit {
        SVGElement.numElements -= 1
        if SVGElement.numElements <= 10 {
            // print(self.description)
            print("deinit: Number of elements = \(SVGElement.numElements)")
        }
    }

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
    
    var textAnchor: TextAnchor? {
        get {
            if let textAnchor = self.textStyle?.textAnchor {
                return textAnchor
            }
            guard let parent = self.parent else {
                return .None
            }
            return parent.textAnchor
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

    public func printElements() {
        print(description)
    }
}

extension SVGElement: CustomStringConvertible {
    public var description: String {
        get {
            var text = "Type: \(self.dynamicType). "
            text += "Num parents: \(numParents). "
            if let id = id { text += "id: \(id). " }
            if let _ = self.style { text += "Has style. " }
            if let _ = self.transform { text += "Has transform. " }
            return text
        }
    }
    
    func printSelfAndParents() {
        var parent: SVGElement? = self
        while let localParent = parent {
            print("================================================================")
            print(localParent.description)
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
        print("================================================================")
        print(self.description)
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
    public var viewPort: CGRect?
    public var title: String?
    public var documentDescription: String?
    
    override public func printElements() {
        super.printElements()
    }
    
    deinit {
        print("SVGDocument has been deinited")
        print("Num elements = \(SVGElement.numElements)")
    }
}

// MARK: -

public class SVGGroup: SVGContainer {
    static var numGroups = 0
    override init() {
        SVGGroup.numGroups += 1
    }
    
    deinit {
        SVGGroup.numGroups -= 1
        // print("Group deinit. Number of groups: \(SVGGroup.numGroups)")
    }
}

// MARK: -

public typealias MovingImagesPath = [NSString : NSObject]
public typealias MovingImagesText = [NSString : NSObject]
public typealias MovingImagesGradient = [NSString : NSObject]

public protocol PathGenerator: CGPathable {
    var evenOdd: Bool { get set }
    var svgpath: String? { get }
    var mipath: MovingImagesPath? { get }
}

public protocol TextRenderer {
    var mitext: MovingImagesText { get }
    var cttext: CFAttributedString { get }
    var textOrigin: CGPoint { get }
}

public protocol LinearGradientRenderer {
    var miLinearGradient: MovingImagesGradient? { get }
    var linearGradient: CGGradient? { get }
    var startPoint: CGPoint? { get }
    var endPoint: CGPoint? { get }
}

// MARK: -

public class SVGPath: SVGElement, PathGenerator {
    public private(set) var cgpath: CGPath
    public private(set) var svgpath: String?
    public var mipath: MovingImagesPath? { get { return .None } }
    public var evenOdd: Bool = false

    public init(path: CGPath, svgPath: String) {
        self.cgpath = path
        self.svgpath = svgPath
    }

    internal func addSVGPath(svgPath: SVGPath) {
        self.cgpath = self.cgpath + svgPath.cgpath
        self.svgpath = .None
    }
}

public class SVGLine: SVGElement, PathGenerator {
    public let startPoint: CGPoint
    public let endPoint: CGPoint
    
    public var evenOdd: Bool {
        get { return false }
        set { }
    }

    lazy public var cgpath: CGPath = self.makePath()
    lazy public var mipath: MovingImagesPath? = makeLineDictionary(self.startPoint, endPoint: self.endPoint)
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
    lazy public var mipath:MovingImagesPath? = makePolygonDictionary(self.polygon.points)
    public var evenOdd: Bool {
        get { return false }
        set { }
    }
    
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
    lazy public var mipath:MovingImagesPath? = makePolylineDictionary(self.points)
    public var evenOdd: Bool {
        get { return false }
        set { }
    }
    
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
    lazy public var mipath:MovingImagesPath? = self.makeMIPath()
    public var evenOdd: Bool {
        get { return false }
        set { }
    }

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
    lazy public var mipath:MovingImagesPath? = self.makeMIPath()
    public var evenOdd: Bool {
        get { return false }
        set { }
    }

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
    lazy public var mipath:MovingImagesPath? = self.makeMIPath()
    public var evenOdd: Bool {
        get { return false }
        set { }
    }

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

public final class SVGTextSpan: TextRenderer {
    private(set) weak var textElement: SVGSimpleText!
    let string: CFString

    internal(set) var style: SwiftGraphics.Style? = nil
    internal(set) var transform: Transform2D? = nil
    internal(set) var textStyle: TextStyle? = nil
    
    public lazy var mitext: MovingImagesText = self.makeMIText()
    public lazy var cttext: CFAttributedString = self.makeAttributedString()
    
    public lazy var textOrigin: CGPoint = self.calculateOrigin()
    
    private let localOrigin: CGPoint
    
    init(string: String, textOrigin: CGPoint) {
        self.string = string
        self.localOrigin = textOrigin
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

    internal var textAnchor: TextAnchor? {
        if let textStyle = self.textStyle, let textAnchor = textStyle.textAnchor {
            return textAnchor
        }
        return textElement.textAnchor
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
        let fontFamily = self.fontFamily
        var attributes: [NSString : AnyObject]
        if fontFamily.containsString(",") {
            let fonts = fontFamily.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
            let familyName = fonts[0]
            let cascadeFonts = fonts.dropFirst(1)
            let cascadeDescriptors: [CTFontDescriptor] = cascadeFonts.map() {
                let cascadeAttributes: [NSString : NSObject] = [
                    kCTFontSizeAttribute : self.fontSize,
                    kCTFontFamilyNameAttribute : $0
                ]
                return CTFontDescriptorCreateWithAttributes(cascadeAttributes)
            }
            attributes = [
                kCTFontSizeAttribute : self.fontSize,
                kCTFontFamilyNameAttribute : familyName,
                kCTFontCascadeListAttribute : cascadeDescriptors
            ]
        }
        else {
            attributes = [
                kCTFontFamilyNameAttribute : self.fontFamily,
                kCTFontSizeAttribute : self.fontSize,
            ]
        }

        let descriptor = CTFontDescriptorCreateWithAttributes(attributes)
        if let tempFontName = CTFontDescriptorCopyAttribute(descriptor, kCTFontNameAttribute) {
            return tempFontName as! NSString
        }
    
        let theFont = CTFontCreateWithFontDescriptorAndOptions(descriptor, self.fontSize, nil, CTFontOptions.Default)
        let postScriptName = CTFontCopyPostScriptName(theFont)
        return postScriptName
    }
    
    private func calculateOrigin() -> CGPoint {
        guard let textAnchor = self.textAnchor else {
            return localOrigin
        }
        
        if textAnchor == TextAnchor.start {
            return localOrigin
        }
        
        let line = CTLineCreateWithAttributedString(self.cttext)
        let boundingRect = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions(rawValue: 0))
        
        var theOrigin = self.localOrigin
        if textAnchor == TextAnchor.middle {
            theOrigin.x -= boundingRect.width / 2
        }
        else if textAnchor == TextAnchor.end {
            theOrigin.x -= boundingRect.width
        }
        return theOrigin
    }
    
    private final func makeAttributedString() -> CFAttributedString {
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

public struct SVGGradientStop {
    internal let offset: CGFloat
    internal let opacity: CGFloat
    internal let color: CGColor

    public init(offset: CGFloat, opacity: CGFloat, color: CGColor) {
        self.offset = offset
        self.opacity = opacity
        self.color = color
    }
}

public enum SVGGradientUnit : String {
    case userSpaceOnUse
    case objectBoundingBox
}

public class SVGLinearGradient: SVGElement, LinearGradientRenderer {
    public lazy var linearGradient: CGGradient? = self.makeLinearGradient()
    public lazy var miLinearGradient: MovingImagesGradient? = self.makeMILinearGradient()
    public lazy var startPoint: CGPoint? = self.makeStartPoint()
    public lazy var endPoint: CGPoint? = self.makeEndPoint()
    
    // Just before rendering of the owningElement it assigns itself to the gradient.
    weak var owningElement: SVGElement?
    
    let point1: CGPoint?
    let point2: CGPoint?
    let stops: [SVGGradientStop]?
    let gradientUnit: SVGGradientUnit
    
    public init(stops: [SVGGradientStop]?,
         gradientUnit: SVGGradientUnit,
               point1: CGPoint? = .None,
               point2: CGPoint? = .None,
            transform: Transform2D?,
            inherited: SVGLinearGradient?) {
        self.stops = stops
        self.point1 = point1
        self.point2 = point2
        self.gradientUnit = gradientUnit
        super.init()
        self.gradientFill = inherited
        self.transform = transform
    }
    
    final private func convertPoint(point: CGPoint) -> CGPoint? {
        var thePoint = point
        if gradientUnit == SVGGradientUnit.userSpaceOnUse {
            if let theTransform = transform {
                thePoint = CGPointApplyAffineTransform(thePoint, theTransform.toCGAffineTransform())
            }
        }
        else {
            if thePoint.x < 0.0 || thePoint.x > 1.0 { return .None }
            if thePoint.y < 0.0 || thePoint.y > 1.0 { return .None }
            
            if let owner = owningElement as? PathGenerator {
                let boundingBox = CGPathGetPathBoundingBox(owner.cgpath)
                thePoint.x = boundingBox.origin.x + thePoint.x * boundingBox.size.width
                thePoint.y = boundingBox.origin.y + thePoint.y * boundingBox.size.height
                if let theTransform = transform {
                    thePoint = CGPointApplyAffineTransform(thePoint, theTransform.toCGAffineTransform())
                }
            }
            else {
                return .None
            }
        }
        return thePoint
    }

    private func makeMILinearGradient() -> MovingImagesGradient? {
        guard let _ = self.startPoint else {
            return .None
        }

        guard let _ = self.endPoint else {
            return .None
        }

        var colors = [CGColor]()
        var locations = [CGFloat]()
        stops?.forEach() {
            colors.append($0.color)
            locations.append($0.offset)
        }

        return makeMILinearGradientDictionary(colors: colors,
                                           locations: locations,
                                          startPoint: self.startPoint!,
                                            endPoint: self.endPoint!)
    }

    final private func makeStartPoint() -> CGPoint? {
        let thePoint = point1 ?? CGPoint(x: 0.0, y: 0.0)
        return convertPoint(thePoint)
    }
    
    final private func makeEndPoint() -> CGPoint? {
        let thePoint = point2 ?? CGPoint(x: 1.0, y: 1.0)
        return convertPoint(thePoint)
    }
    
    final private func makeLinearGradient() -> CGGradient? {
        if !canRender() {
            return .None
        }
        
        var colors = [CGColor]()
        var locations = [CGFloat]()
        stops?.forEach() {
            colors.append($0.color)
            locations.append($0.offset)
        }
        return CGGradientCreateWithColors(CGColorGetColorSpace(colors[0]), colors, locations)
    }
    
    // Since linear gradient fills can inherit from earlier defined linear gradient fills
    // we need to keep drilling down and combining the results.
    func coalesceLinearGradientInheritance() -> SVGLinearGradient {
        guard let inheritedGradient = self.gradientFill else {
            return self
        }
        
        let superInherited = inheritedGradient.coalesceLinearGradientInheritance()
        
        let pt1 = self.point1 ?? superInherited.point1
        let pt2 = self.point2 ?? superInherited.point2
        let stops = self.stops ?? superInherited.stops
        let gradientUnit = self.gradientUnit == SVGGradientUnit.userSpaceOnUse ? self.gradientUnit : superInherited.gradientUnit
        
        let style: Style
        if var inheritedStyle = superInherited.style {
            if let theStyle = self.style {
                inheritedStyle.apply(theStyle)
            }
            style = inheritedStyle
        }
        else {
            style = self.style ?? Style()
        }

        let transform: Transform2D?
        if let theTransform = self.transform {
            transform = theTransform
        }
        else {
            if let theTransform = superInherited.transform {
                transform = theTransform
            }
            else {
                transform = .None
            }
        }
        let linearGradient = SVGLinearGradient(stops: stops, gradientUnit: gradientUnit,
                                               point1: pt1, point2: pt2,
                                               transform: transform, inherited: .None)
        linearGradient.style = style
        linearGradient.id = self.id
        return linearGradient
    }
    
    func canRender() -> Bool {
/*
        guard let _ = self.point1 else {
            return false
        }

        guard let _ = self.point2 else {
            return false
        }
*/
        guard let _ = self.stops else {
            return false
        }
        
        return true
    }
}
