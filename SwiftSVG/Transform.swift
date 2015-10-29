//
//  main.swift
//  Transform
//
//  Created by Jonathan Wight on 3/15/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Foundation
import QuartzCore

public protocol Transform {
    var isIdentity: Bool { get }
}

public protocol Transform2D: Transform {
    func toCGAffineTransform() -> CGAffineTransform!
}

public protocol Transform3D: Transform {
    func asCATransform3D() -> CATransform3D!
}

// MARK: -

public struct IdentityTransform: Transform {
    public var isIdentity: Bool {
        return true
    }
}

extension IdentityTransform: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform! {
        return CGAffineTransformIdentity
    }
}

// MARK: -

public struct CompoundTransform: Transform {
    public let transforms: [Transform]

    public init(transforms: [Transform]) {
        // TODO: Check that all transforms are also Transform2D? Or use another init?

        // TODO: Strip out identity transforms
        self.transforms = transforms.filter() {
            return $0.isIdentity == false
        }
    }

    public var isIdentity: Bool {
        if transforms.count == 0 {
            return true
        }
        else {
            // TODO: LIE
            return false
        }
    }
}

extension CompoundTransform: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform! {

        // Convert all transforms to 2D transforms. We will explode if not all transforms are 2D capable
        let affineTransforms: [CGAffineTransform] = transforms.map{
            return ($0 as! Transform2D).toCGAffineTransform()
        }

        let transform: CGAffineTransform = affineTransforms[0]
        let result: CGAffineTransform = affineTransforms[1..<affineTransforms.count].reduce(transform) {
            (lhs: CGAffineTransform, rhs: CGAffineTransform) -> CGAffineTransform in
            return CGAffineTransformConcat(lhs, rhs)
        }
        return result
    }
}

public func + (lhs: Transform, rhs: Transform) -> CompoundTransform {
    return CompoundTransform(transforms: [lhs, rhs])
}

public func + (lhs: CompoundTransform, rhs: Transform) -> CompoundTransform {
    return CompoundTransform(transforms: lhs.transforms + [rhs])
}

public func + (lhs: Transform, rhs: CompoundTransform) -> CompoundTransform {
    return CompoundTransform(transforms: [lhs] + rhs.transforms)
}

public func + (lhs: CompoundTransform, rhs: CompoundTransform) -> CompoundTransform {
    return CompoundTransform(transforms: lhs.transforms + rhs.transforms)
}

extension CompoundTransform: CustomStringConvertible {
    public var description: String {
        let transformStrings: [String] = transforms.map() { return String($0) }
        return "CompoundTransform(\(transformStrings))"
    }
}

// MARK: -

public struct MatrixTransform2D: Transform {
    public let a: CGFloat
    public let b: CGFloat
    public let c: CGFloat
    public let d: CGFloat
    public let tx: CGFloat
    public let ty: CGFloat

    public var isIdentity: Bool {
        // TODO: LIE
        return false
    }
}

extension MatrixTransform2D: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform! {
        return CGAffineTransformMake(a, b, c, d, tx, ty)
    }
}

extension MatrixTransform2D: CustomStringConvertible {
    public var description: String {
        return "Matrix(\(a), \(b), \(c) \(d), \(tx), \(ty))"
    }
}

// MARK: Translate

public struct Translate: Transform {
    public let tx: CGFloat
    public let ty: CGFloat
    public let tz: CGFloat

    public init(tx: CGFloat, ty: CGFloat, tz: CGFloat = 0.0) {
        self.tx = tx
        self.ty = ty
        self.tz = tz
    }

    public var isIdentity: Bool {
        // TODO: LIE
        return false
    }
}

extension Translate: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform! {
        return tz == 0.0 ? CGAffineTransformMakeTranslation(tx, ty): nil
    }
}

extension Translate: Transform3D {
    public func asCATransform3D() -> CATransform3D! {
        return CATransform3DMakeTranslation(tx, ty, tz)
    }
}

extension Translate: CustomStringConvertible {
    public var description: String {
        return "Translate(\(tx), \(ty), \(tz))"
    }
}

// MARK: Scale

public struct Scale: Transform {
    public let sx: CGFloat
    public let sy: CGFloat
    public let sz: CGFloat

    public init(sx: CGFloat, sy: CGFloat, sz: CGFloat = 1) {
        self.sx = sx
        self.sy = sy
        self.sz = sz
    }

    public init(scale: CGFloat) {
        sx = scale
        sy = scale
        sz = scale
    }

    public var isIdentity: Bool {
        // TODO: LIE
        return false
    }
}

extension Scale: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform! {
        return sz == 1.0 ? CGAffineTransformMakeScale(sx, sy): nil
    }
}

extension Scale: Transform3D {
    public func asCATransform3D() -> CATransform3D! {
        return CATransform3DMakeScale(sx, sy, sz)
    }
}

extension Scale: CustomStringConvertible {
    public var description: String {
        return "Scale(\(sx), \(sy), \(sz))"
    }
}

// MARK: -

public struct Rotate: Transform {
    public let angle: CGFloat
    // AXIS, TRANSLATION

    public var isIdentity: Bool {
        // TODO: LIE
        return false
    }
}

extension Rotate: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform! {
        return CGAffineTransformMakeRotation(angle)
    }
}

extension Rotate: CustomStringConvertible {
    public var description: String {
        return "Rotate(\(angle))"
    }
}

// MARK: -

public struct Skew: Transform {
    public let angle: CGFloat
    // AXIS

    public var isIdentity: Bool {
        // TODO: LIE
        return false
    }
}

extension Skew: Transform2D {
    public func toCGAffineTransform() -> CGAffineTransform! {
        assertionFailure("Cannot skew")
        return nil
    }
}

extension Skew: CustomStringConvertible {
    public var description: String {
        return "Skew(\(angle))"
    }
}

