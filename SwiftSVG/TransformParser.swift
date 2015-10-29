//
//  SVGTransform.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 3/14/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Foundation

import SwiftParsing


func converter(value:Any) throws -> Any? {

    guard let value = value as? [Any], let type = value[0] as? String else {
        return nil
    }

    guard let parametersUntyped = (value[1] as? [Any]) else {
        return nil
    }

    guard let parameters:[CGFloat] = parametersUntyped.map({ return $0 as! CGFloat }) else {
        return nil
    }

    switch type {
        case "matrix":
            let parameters = parameters + Array <CGFloat> (count: 6 - parameters.count, repeatedValue: 0.0)
            let a = parameters[0]
            let b = parameters[1]
            let c = parameters[2]
            let d = parameters[3]
            let e = parameters[4]
            let f = parameters[5]
            return MatrixTransform2D(a: a, b: b, c: c, d: d, tx: e, ty: f)
        case "translate":
            let parameters = parameters + Array <CGFloat> (count: 2 - parameters.count, repeatedValue: 0.0)
            let x = parameters[0]
            let y = parameters[1]
            return Translate(tx: x, ty: y)
        case "scale":
            let x = parameters[0]
            let y = parameters.count > 1 ? parameters[1] : x
            return Scale(sx: x, sy: y)
        case "rotate":
            // On iOS rotation is in the opposite direction to OS X for CGAffineTransformRotate.
            // TODO: Confirm that this modification for iOS is correct.
            #if os(iOS)
                let angle = -parameters[0] * CGFloat(M_PI / 180.0)
            #else
                let angle = parameters[0] * CGFloat(M_PI / 180.0)
            #endif
            var t = CGAffineTransformIdentity
            let tx = (parameters.count > 1 ? parameters[1] : 0.0)
            let ty = (parameters.count > 2 ? parameters[2] : 0.0)

            t = CGAffineTransformTranslate(t, tx, ty)
            t = CGAffineTransformRotate(t, angle)
            t = CGAffineTransformTranslate(t, -tx, -ty)

            return MatrixTransform2D(a: t.a, b: t.b, c: t.c, d: t.d, tx: t.tx, ty: t.ty)
        default:
            return nil
    }
}

let COMMA = Literal(",")
let OPT_COMMA = zeroOrOne(COMMA).makeStripped()
let LPAREN = Literal("(").makeStripped()
let RPAREN = Literal(")").makeStripped()
let VALUE_LIST = oneOrMore((cgFloatValue + OPT_COMMA).makeStripped().makeFlattened())

// TODO: Should set manual min and max value instead of relying on 0..<infinite VALUE_LIST

let matrix = (Literal("matrix") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let translate = (Literal("translate") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let scale = (Literal("scale") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let rotate = (Literal("rotate") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let skewX = (Literal("skewX") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let skewY = (Literal("skewY") + LPAREN + VALUE_LIST + RPAREN).makeConverted(converter)
let transform = (matrix | translate | scale | rotate | skewX | skewY).makeFlattened()
let transforms = oneOrMore((transform + OPT_COMMA).makeFlattened())

//rotate(<rotate-angle> [<cx> <cy>]), which specifies a rotation by <rotate-angle> degrees about a given point.
//If optional parameters <cx> and <cy> are not supplied, the rotate is about the origin of the current user coordinate system. The operation corresponds to the matrix [cos(a) sin(a) -sin(a) cos(a) 0 0].
//If optional parameters <cx> and <cy> are supplied, the rotate is about the point (cx, cy). The operation represents the equivalent of the following specification: translate(<cx>, <cy>) rotate(<rotate-angle>) translate(-<cx>, -<cy>).
// 
//skewX(<skew-angle>), which specifies a skew transformation along the x-axis.
// 
//skewY(<skew-angle>), which specifies a skew transformation along the y-axis.

// MARK: -


public func svgTransformAttributeStringToTransform(string: String) throws -> Transform2D? {
    let result = try transforms.parse(string)
    switch result {
        case .Ok(let value):
            guard let value = value as? [Any] else {
                return nil
            }

            let transforms: [Transform] = value.map() {
                return $0 as! Transform
            }

            let compound = CompoundTransform(transforms: transforms)
            return compound
        default:
            break
    }
    return nil

}



