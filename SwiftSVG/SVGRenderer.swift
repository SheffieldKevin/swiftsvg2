//
//  SVGRenderer.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 2/25/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Foundation

import SwiftGraphics

public class SVGRenderer {

    public struct Callbacks {
        public var prerenderElement: ((svgElement: SVGElement, renderer: Renderer) throws -> Bool)? = nil
        public var postrenderElement: ((svgElement: SVGElement, renderer: Renderer) throws -> Void)? = nil
        public var styleForElement: ((svgElement: SVGElement) throws -> Style?)? = nil
    }

    public var callbacks = Callbacks()

    public init() {
    }

    public func prerenderElement(svgElement: SVGElement, renderer: Renderer) throws -> Bool {
        if let prerenderElement = callbacks.prerenderElement {
            return try prerenderElement(svgElement: svgElement, renderer: renderer)
        }
        return true
    }

    public func styleForElement(svgElement: SVGElement) throws -> Style? {
        if let style = try callbacks.styleForElement?(svgElement: svgElement) {
            return style
        }
        return svgElement.style
    }

    public func renderElement(svgElement: SVGElement, renderer: Renderer) throws {
        if !svgElement.display {
            return
        }

        let hasStroke = svgElement.hasStroke
        let hasFill: Bool
        let hasGradientFill: Bool

        if let _ = svgElement.gradientFill {
            hasGradientFill = true
            hasFill = false
        }
        else {
            hasGradientFill = false
            hasFill = svgElement.hasFill
        }

        if let _ = svgElement as? SVGContainer {
            renderer.startGroup(svgElement.id)
        }
        else if !(hasStroke || hasFill || hasGradientFill) {
            return
        }
        
        // Because text has an array of text spans for rendering purposes a
        // simple text item should be considered a group.
        if let _ = svgElement as? SVGSimpleText {
            renderer.startGroup(svgElement.id)
        }
            
        if let _ = svgElement as? PathGenerator {
            renderer.startElement(svgElement.id)
        }

        defer {
            renderer.endElement()
        }

        renderer.pushGraphicsState()
        defer {
            renderer.restoreGraphicsState()
        }
        
        if try prerenderElement(svgElement, renderer: renderer) == false {
            return
        }

        if !(svgElement is SVGSimpleText) {
            if let style = try styleForElement(svgElement) {
                renderer.style = style
            }
        }

        if let transform = svgElement.transform {
            renderer.concatTransform(transform.toCGAffineTransform())
        }
        
        switch svgElement {
            case let svgDocument as SVGDocument:
                try renderDocument(svgDocument, renderer: renderer)
            case let svgGroup as SVGGroup:
                try renderGroup(svgGroup, renderer: renderer)
            case let pathable as PathGenerator:
                // svgElement.printSelfAndParents()
                if (hasGradientFill) {
                    print("Need to render gradient fill: ")
                    var gradientFill = svgElement.gradientFill!.coalesceLinearGradientInheritance()
                    gradientFill.owningElement = svgElement
                    print("========================================================")
                    print(gradientFill.description)
                    renderer.drawLinearGradient(gradientFill, pathGenerator: pathable)
                }
                if (hasStroke || hasFill) {
                    let evenOdd = hasFill && pathable.evenOdd
                    let mode = CGPathDrawingMode(hasStroke: hasStroke, hasFill: hasFill, evenOdd: evenOdd)
                    renderer.addPath(pathable)
                    renderer.drawPath(mode)
                }
            case let textElement as SVGSimpleText:
                for textSpan in textElement.spans {
                    renderer.pushGraphicsState()
                    renderer.startElement(nil)
                    defer {
                        renderer.restoreGraphicsState()
                        renderer.endElement()
                    }
                    if let transform = textSpan.transform {
                        renderer.concatCTM(transform.toCGAffineTransform())
                    }
                    renderer.drawText(textSpan)
                }
            default:
                assert(false)
        }
    }

    public func pathForElement(svgElement: SVGElement) -> CGPath? {
        switch svgElement {
            case let svgDocument as SVGDocument:
                let path = CGPathCreateMutable()
                for svgElement in svgDocument.children {
                    if let pathOfChildren = pathForElement(svgElement) {
                        CGPathAddPath(path, nil, pathOfChildren)
                    }
                }
                return path
            case let svgGroup as SVGGroup:
                let path = CGPathCreateMutable()
                for svgElement in svgGroup.children {
                    if let pathOfChildren = pathForElement(svgElement) {
                        CGPathAddPath(path, nil, pathOfChildren)
                    }
                }
                return path
            case let pathable as CGPathable:
                return pathable.cgpath
            case _ as SVGSimpleText:
                return nil
            default:
                assert(false)
        }
    }

    public func renderDocument(svgDocument: SVGDocument, renderer: Renderer) throws {
        if let viewBox = svgDocument.viewBox {
            renderer.startDocument(viewBox)
        }
        renderer.fillColor = try SVGColors.stringToColor("black")
        renderer.lineWidth = 1.0

        for child in svgDocument.children {
            try renderElement(child, renderer: renderer)
        }
    }

    public func renderGroup(svgGroup: SVGGroup, renderer: Renderer) throws {
        for child in svgGroup.children {
            try renderElement(child, renderer: renderer)
        }
    }
}