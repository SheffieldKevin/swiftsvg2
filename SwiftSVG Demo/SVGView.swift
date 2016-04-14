//
//  SVGView.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 2/25/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Cocoa

import SwiftGraphics
import SwiftSVG

class SVGView: NSView {

    @IBOutlet var horizontalConstraint: NSLayoutConstraint?
    @IBOutlet var verticalConstraint: NSLayoutConstraint?

    var svgRenderer: SVGRenderer = SVGRenderer()

    var svgDocument: SVGDocument? = nil {
        didSet {
            if let svgDocument = svgDocument, let viewBox = svgDocument.viewBox {
                horizontalConstraint?.constant = viewBox.width
                verticalConstraint?.constant = viewBox.height
            }
            needsDisplay = true
            needsLayout = true
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(SVGView.tap(_:))))
    }

    override func layout() {
        super.layout()
    }

    override func drawRect(dirtyRect: NSRect) {
        let context = NSGraphicsContext.currentContext()!.CGContext
        CGContextSetTextMatrix(context, CGAffineTransformIdentity)

        // Drawing code here.
        let filter = CheckerboardGenerator()
        filter.inputCenter = CIVector(CGPoint: CGPointZero)
        filter.inputWidth = 20
        filter.inputColor0 = CIColor(CGColor: CGColor.whiteColor())
        filter.inputColor1 = CIColor(CGColor: CGColor.color(white: 0.8, alpha: 1))
        let ciImage = filter.outputImage!
        let ciContext = CIContext(CGContext: context, options: nil)
        let image = ciContext.createCGImage(ciImage, fromRect: bounds)
        CGContextDrawImage(context, bounds, image)

        if let svgDocument = svgDocument {
            context.with() {
                CGContextScaleCTM(context, 1, -1)
                CGContextTranslateCTM(context, 0, -bounds.size.height)
                try! svgRenderer.renderDocument(svgDocument, renderer: context)
            }
        }

        CGContextStrokeRect(context, bounds)
    }

    func tap(gestureRecognizer: NSClickGestureRecognizer) {
        let location = gestureRecognizer.locationInView(self)
        if let element = try? elementForPoint(location) {
            if let element = element {
                elementSelected?(svgElement: element)
            }
        }
    }

    var elementSelected: ((svgElement: SVGElement) -> Void)?

    func elementForPoint(point: CGPoint) throws -> SVGElement? {

        guard let svgDocument = svgDocument else {
            return nil
        }
        let context = CGContext.bitmapContext(self.bounds)

        var index: UInt32 = 0

        var elementsByIndex: [UInt32: SVGElement] = [: ]
        let svgRenderer = SVGRenderer()
        svgRenderer.callbacks.styleForElement = {
            (svgElement: SVGElement) -> Style? in

            elementsByIndex[index] = svgElement

            let red = CGFloat((index & 0xFF0000) >> 16) / 255
            let green = CGFloat((index & 0x00FF00) >> 8) / 255
            let blue = CGFloat((index & 0x0000FF) >> 0) / 255

            // TODO: HACK
            let color = NSColor(red: red, green: green, blue: blue, alpha: 1.0).CGColor

            let style = Style(elements: [.FillColor(color)])
            index = index + 1
            return style
        }
        try svgRenderer.renderDocument(svgDocument, renderer: context)
//            println("Max index: \(index)")

        var data = CGBitmapContextGetData(context)
        data = data.advancedBy(Int(point.y) * CGBitmapContextGetBytesPerRow(context))

        let pixels = UnsafePointer <UInt32> (data).advancedBy(Int(point.x))
        let argb = pixels.memory

        let blue  = (argb & 0xFF000000) >> 24
        let green = (argb & 0x00FF0000) >> 16
        let red   = (argb & 0x0000FF00) >> 8
//            let alpha = (argb & 0x000000FF) >> 0


        let searchIndex = red << 16 | green << 8 | blue

        return elementsByIndex[searchIndex]
    }
}
