//
//  SwiftGraphics+Extensions.swift
//  SwiftSVG
//
//  Created by Jonathan Wight on 8/26/15.
//  Copyright © 2015 No. All rights reserved.
//

import SwiftGraphics

public func + (lhs:CGPath, rhs:CGPath) -> CGPath {
    let path = CGPathCreateMutableCopy(lhs)!
    CGPathAddPath(path, nil, rhs)
    return path
}


public extension CGColor {
    var components:[CGFloat] {
        let count = CGColorGetNumberOfComponents(self)
        let componentsPointer = CGColorGetComponents(self)
        let components = UnsafeBufferPointer <CGFloat> (start:componentsPointer, count:count)
        return Array <CGFloat> (components)
    }

    var alpha:CGFloat {
        return CGColorGetAlpha(self)
    }

    var colorSpace:CGColorSpace? {
        return CGColorGetColorSpace(self)
    }

    var colorSpaceName:String? {
        return CGColorSpaceCopyName(self.colorSpace) as? String
    }

}

extension CGColor: CustomReflectable {
    public func customMirror() -> Mirror {
        return Mirror(self, children: [
            "alpha": alpha,
            "colorSpace": colorSpaceName,
            "components": components,
        ])
    }
}

extension CGColor: Equatable {
}

public func ==(lhs: CGColor, rhs: CGColor) -> Bool {

    if lhs.alpha != rhs.alpha {
        return false
    }
    if lhs.colorSpaceName != rhs.colorSpaceName {
        return false
    }
    if lhs.components != rhs.components {
        return false
    }

    return true
}

extension Style: Equatable {
}

public func ==(lhs: Style, rhs: Style) -> Bool {
    if lhs.fillColor != rhs.fillColor {
        return false
    }
    if lhs.strokeColor != rhs.strokeColor {
        return false
    }
    if lhs.lineWidth != rhs.lineWidth {
        return false
    }
    if lhs.lineCap != rhs.lineCap {
        return false
    }
    if lhs.miterLimit != rhs.miterLimit {
        return false
    }
    if lhs.lineDash ?? [] != rhs.lineDash ?? [] {
        return false
    }
    if lhs.lineDashPhase != rhs.lineDashPhase {
        return false
    }
    if lhs.flatness != rhs.flatness {
        return false
    }
    if lhs.alpha != rhs.alpha {
        return false
    }
    if lhs.blendMode != rhs.blendMode {
        return false
    }
    return true
}


extension SwiftGraphics.Style {

    init() {
        self.init(elements: [])
    }

    var isEmpty: Bool {
        get {
            return toStyleElements().count == 0
        }
    }

    func toStyleElements() -> [StyleElement] {

        var elements: [StyleElement] = []

        if let fillColor = fillColor {
            elements.append(.fillColor(fillColor))
        }

        if let strokeColor = strokeColor {
            elements.append(.fillColor(strokeColor))
        }

        if let lineWidth = lineWidth {
            elements.append(.lineWidth(lineWidth))
        }

        if let lineCap = lineCap {
            elements.append(.lineCap(lineCap))
        }

        if let lineJoin = lineJoin {
            elements.append(.lineJoin(lineJoin))
        }

        if let miterLimit = miterLimit {
            elements.append(.miterLimit(miterLimit))
        }

        if let lineDash = lineDash {
            elements.append(.lineDash(lineDash))
        }

        if let lineDashPhase = lineDashPhase {
            elements.append(.lineDashPhase(lineDashPhase))
        }

        if let flatness = flatness {
            elements.append(.flatness(flatness))
        }

        if let alpha = alpha {
            elements.append(.alpha(alpha))
        }

        if let blendMode = blendMode {
            elements.append(.blendMode(blendMode))
        }

        return elements
    }
}


func + (lhs: SwiftGraphics.Style, rhs: SwiftGraphics.Style) -> SwiftGraphics.Style {
    var accumulator = lhs
    accumulator.add(rhs.toStyleElements())
    return accumulator
}

