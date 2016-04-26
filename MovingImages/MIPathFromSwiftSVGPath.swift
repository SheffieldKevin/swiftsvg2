//  MIPathFromSwiftSVGPath.swift
//  SwiftSVG
//
//  Created by Kevin Meaney on 17/09/2015.

import Foundation

public func MICGPathCreateFromSVGPath(d:String, inout pathArray: NSMutableArray) -> CGMutablePath
{
    let path = CGPathCreateMutable()
    MI_CGPathFromSVGPath(path, pathArray, d)
    return path
}
