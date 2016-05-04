//
//  Renderer.swift
//  SwiftSVG
//
//  Created by Jonathan Wight on 8/26/15.
//  Copyright © 2015 No. All rights reserved.
//

import SwiftGraphics

public protocol Renderer: AnyObject {

    func concatTransform(transform:CGAffineTransform)
    func concatCTM(transform:CGAffineTransform)
    func pushGraphicsState()
    func restoreGraphicsState()

    func startDocument(viewBox: CGRect)
    func startGroup(id: String?)
    func endElement()
    func startElement(id: String?)
    
    func addPath(path:PathGenerator)
    func addCGPath(path: CGPath)
    func drawPath(mode: CGPathDrawingMode)
    func drawText(textRenderer: TextRenderer)
    func fillPath()
    
    func render() -> String

    var strokeColor:CGColor? { get set }
    var fillColor:CGColor? { get set }
    var lineWidth:CGFloat? { get set }

    var style:Style { get set }

}

// MARK: -

public protocol CustomSourceConvertible {
    func toSource() -> String
}

extension CGAffineTransform: CustomSourceConvertible {
    public func toSource() -> String {
        return "CGAffineTransform(\(a), \(b), \(c), \(d), \(tx), \(ty))"
    }
}

// MARK: - CGContext renderer

extension CGContext: Renderer {

    public func concatTransform(transform:CGAffineTransform) {
        CGContextConcatCTM(self, transform)
    }

    public func concatCTM(transform:CGAffineTransform) {
        CGContextConcatCTM(self, transform)
    }

    public func pushGraphicsState() {
        CGContextSaveGState(self)
    }

    public func restoreGraphicsState() {
        CGContextRestoreGState(self)
    }

    public func startDocument(viewBox: CGRect) { }
    
    public func startGroup(id: String?) { }

    public func endElement() { }
    
    public func startElement(id: String?) { }

    public func addCGPath(path: CGPath) {
        CGContextAddPath(self, path)
    }

    public func addPath(path:PathGenerator) {
        addCGPath(path.cgpath)
    }

    public func drawPath(mode: CGPathDrawingMode) {
        CGContextDrawPath(self, mode)
    }
    
    public func drawText(textRenderer: TextRenderer) {
        self.pushGraphicsState()
        CGContextTranslateCTM(self, 0.0, textRenderer.textOrigin.y)
        CGContextScaleCTM(self, 1.0, -1.0)
        let line = CTLineCreateWithAttributedString(textRenderer.cttext)
        CGContextSetTextPosition(self, textRenderer.textOrigin.x, 0.0)
        CTLineDraw(line, self)
        self.restoreGraphicsState()
    }
    
    public func fillPath() {
        CGContextFillPath(self)
    }
    
    public func render() -> String { return "" }
}

//MARK: - MovingImagesRenderer

public class MovingImagesRenderer: Renderer {
    
    class MIRenderElement: Node {
        internal typealias ParentType = MIRenderContainer
        internal weak var parent: MIRenderContainer? = nil
        
        internal var movingImages = [NSString : AnyObject]()
        internal func generateJSONDict() -> [NSString : AnyObject] {
            return movingImages
        }
    }
    
    class MIRenderContainer: MIRenderElement, GroupNode {
        internal var children = [MIRenderElement]()
        
        override init() {
            super.init()
        }
        
        override internal func generateJSONDict() -> [NSString : AnyObject] {
            self.movingImages[MIJSONKeyElementType] = MIJSONKeyArrayOfElements
            let arrayOfElements = children.map { $0.generateJSONDict() }
            self.movingImages[MIJSONKeyArrayOfElements] = arrayOfElements
            return self.movingImages
        }
    }

    public init() {
        current = rootElement
    }
    
    internal var rootElement = MIRenderContainer()
    private var current: MIRenderElement
    
    // internal var movingImagesJSON: [NSString : AnyObject]
    
    public func concatTransform(transform:CGAffineTransform) {
        concatCTM(transform)
    }
    
    public func concatCTM(transform:CGAffineTransform) {
        current.movingImages[MIJSONKeyAffineTransform] = makeCGAffineTransformDictionary(transform)
    }

    public func pushGraphicsState() { }
    
    public func restoreGraphicsState() { }
    
    public func addCGPath(path: CGPath) { }
    
    // Should this be throws?
    public func startGroup(id: String?) {
        if let current = self.current as? MIRenderContainer {
            let newItem = MIRenderContainer()
            if let id = id {
                newItem.movingImages[MIJSONKeyElementDebugName] = id
            }
            current.children.append(newItem)
            newItem.parent = current
            self.current = newItem
        }
        else {
            preconditionFailure("Cannot start a new render group. Current element is a leaf")
        }
    }

    public func startElement(id: String?) {
        if let current = self.current as? MIRenderContainer {
            let newItem = MIRenderElement()
            if let id = id {
                newItem.movingImages[MIJSONKeyElementDebugName] = id
            }
            current.children.append(newItem)
            newItem.parent = current
            self.current = newItem
        }
        else {
            preconditionFailure("Cannot start a new render element. Current element is a leaf")
        }
    }

    public func startDocument(viewBox: CGRect) {
        current.movingImages["viewBox"] = makeRectDictionary(viewBox)
    }

    public func addPath(path:PathGenerator) {
        if let svgPath = path.svgpath {
            current.movingImages[MIJSONKeySVGPath] = svgPath
            return
        }

        if let mipath = path.mipath {
            for (key, value) in mipath {
                current.movingImages[key] = value
            }
        }
    }

    public func drawText(textRenderer: TextRenderer) {
        for (key, value) in textRenderer.mitext {
            current.movingImages[key] = value
        }
    }

    public func endElement() {
        if let parent = self.current.parent {
            self.current = parent
        }
        else {
            preconditionFailure("Cannot end an element when there is no parent.")
        }
    }
    
    public func drawPath(mode: CGPathDrawingMode) {
        let miDrawingElement: NSString
        let evenOdd: NSString?
        
        switch(mode) {
        case CGPathDrawingMode.Fill:
            miDrawingElement = MIJSONValuePathFillElement
            evenOdd = Optional.None
            // evenOdd = "nonwindingrule"
        case CGPathDrawingMode.Stroke:
            miDrawingElement = MIJSONValuePathStrokeElement
            evenOdd = Optional.None
        case CGPathDrawingMode.EOFill:
            miDrawingElement = MIJSONValuePathFillElement
            evenOdd = MIJSONValueEvenOddClippingRule
        case CGPathDrawingMode.EOFillStroke:
            miDrawingElement = MIJSONValuePathFillAndStrokeElement
            evenOdd = MIJSONValueEvenOddClippingRule
        case CGPathDrawingMode.FillStroke:
            miDrawingElement = MIJSONValuePathFillAndStrokeElement
            evenOdd = Optional.None
            // evenOdd = "nonwindingrule"
        }
        if let rule = evenOdd {
            current.movingImages[MIJSONKeyClippingRule] = rule
        }
        
        if current.movingImages[MIJSONKeyElementType] == nil {
            current.movingImages[MIJSONKeyElementType] = miDrawingElement
        }
    }

    // Not part of the Render protocol.
    public func generateJSONDict() -> [NSString : AnyObject] {
        return rootElement.generateJSONDict()
    }
    
    public func render() -> String {
        if let jsonString = jsonObjectToString(self.generateJSONDict()) {
            return jsonString
        }
        return ""
    }

    public func fillPath() { }

    public var strokeColor:CGColor? {
        get {
            return style.strokeColor
        }
        set {
            style.strokeColor = newValue
            if let color = newValue {
                current.movingImages[MIJSONKeyStrokeColor] = SVGColors.makeMIColorFromColor(color)
            }
            else {
                current.movingImages[MIJSONKeyStrokeColor] = nil
            }
        }
    }
    
    public var fillColor:CGColor? {
        get { return style.fillColor }
        set {
            style.fillColor = newValue
            if let color = newValue {
                current.movingImages[MIJSONKeyFillColor] = SVGColors.makeMIColorFromColor(color)
            }
            else {
                current.movingImages[MIJSONKeyFillColor] = nil
            }
        }
    }

    public var lineWidth:CGFloat? {
        get { return style.lineWidth }
        set {
            style.lineWidth = newValue
            if let lineWidth = newValue {
                current.movingImages[MIJSONKeyLineWidth] = lineWidth
            }
            else {
                current.movingImages[MIJSONKeyFillColor] = nil
            }
        }
    }

    public var style:Style = Style() {
        didSet {
            if let fillColor = style.fillColor {
                current.movingImages[MIJSONKeyFillColor] = SVGColors.makeMIColorFromColor(fillColor)
            }
            if let strokeColor = style.strokeColor {
                current.movingImages[MIJSONKeyStrokeColor] = SVGColors.makeMIColorFromColor(strokeColor)
            }
            if let lineWidth = style.lineWidth {
                current.movingImages[MIJSONKeyLineWidth] = lineWidth
            }
            if let lineCap = style.lineCap {
                current.movingImages[MIJSONKeyLineCap] = lineCap.stringValue
            }
            if let lineJoin = style.lineJoin {
                current.movingImages[MIJSONKeyLineJoin] = lineJoin.stringValue
            }
            if let miterLimit = style.miterLimit {
                current.movingImages[MIJSONKeyMiter] = miterLimit
            }
            if let alpha = style.alpha {
                current.movingImages[MIJSONKeyContextAlpha] = alpha
            }
            if let lineDash = style.lineDash {
                if let lineDashPhase = style.lineDashPhase {
                    current.movingImages[MIJSONKeyLineDashArray] = lineDash
                    current.movingImages[MIJSONKeyLineDashPhase] = lineDashPhase
                } else {
                    current.movingImages[MIJSONKeyLineDashArray] = lineDash
                }
            }
/*  Not yet implemented in SwiftSVG.
            if let blendMode = newStyle.blendMode {
                setBlendMode(blendMode)
            }
*/

        }
    }
}

private extension CGLineCap {
    var stringValue: NSString {
        switch(self) {
        case CGLineCap.Butt:
            return "kCGLineCapButt"
        case CGLineCap.Round:
            return "kCGLineCapRound"
        case CGLineCap.Square:
            return "kCGLineCapSquare"
        }
    }
}

private extension CGLineJoin {
    var stringValue: NSString {
        switch(self) {
        case CGLineJoin.Bevel:
            return "kCGLineJoinBevel"
        case CGLineJoin.Miter:
            return "kCGLineJoinMiter"
        case CGLineJoin.Round:
            return "kCGLineJoinRound"
        }
    }
}

// MARK: -

public class SourceCodeRenderer: Renderer {
    public internal(set) var source = ""

    public init() {
        // Shouldn't this be fill color. Default stroke is no stroke.
        // whereas default fill is black. ktam?
        self.style.strokeColor = CGColor.blackColor()
    }

    public func concatTransform(transform:CGAffineTransform) {
        concatCTM(transform)
    }

    public func concatCTM(transform:CGAffineTransform) {
        source += "CGContextConcatCTM(context, \(transform.toSource()))\n"
    }

    public func pushGraphicsState() {
        source += "CGContextSaveGState(context)\n"
    }
    
    public func restoreGraphicsState() {
        source += "CGContextRestoreGState(self)\n"
    }

    public func startGroup(id: String?) { }
    
    public func endElement() { }
    
    public func startElement(id: String?) { }

    public func startDocument(viewBox: CGRect) { }
    
    public func addCGPath(path: CGPath) {
        source += "CGContextAddPath(context, \(path))\n"
    }

    public func addPath(path:PathGenerator) {
        addCGPath(path.cgpath)
    }

    public func drawPath(mode: CGPathDrawingMode) {
        source += "CGContextDrawPath(context, TODO)\n"
    }

    public func drawText(textRenderer: TextRenderer) {
        
    }
    
    public func fillPath() {
        source += "CGContextFillPath(context)\n"
    }

    public func render() -> String {
        return source
    }

    public var strokeColor:CGColor? {
        get {
            return style.strokeColor
        }
        set {
            style.strokeColor = newValue
            source += "CGContextSetStrokeColor(context, TODO)\n"
        }
    }

    public var fillColor:CGColor? {
        get {
            return style.fillColor
        }
        set {
            style.fillColor = newValue
            source += "CGContextSetFillColor(context, TODO)\n"
        }
    }

    public var lineWidth:CGFloat? {
        get {
            return style.lineWidth
        }
        set {
            style.lineWidth = newValue
            source += "CGContextSetLineWidth(context, TODO)\n"
        }
    }

    public var style:Style = Style() {
        didSet {
            source += "CGContextSetStrokeColor(context, TODO)\n"
            source += "CGContextSetFillColor(context, TODO)\n"
        }
    }
}
