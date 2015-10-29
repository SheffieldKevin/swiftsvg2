//  TextStyle.swift
//  SwiftSVG
//
//  Created by Kevin Meaney on 30/09/2015.
//  Copyright © 2015 No. All rights reserved.

import Foundation

import CoreGraphics

public struct TextStyle {
    public var fontFamily: String?
    public var fontSize: CGFloat?
    
    public init() {
        
    }
}

public enum TextStyleElement {
    case fontFamily(String)
    case fontSize(CGFloat)
}

public extension TextStyle {
    mutating func add(element: TextStyleElement) {
        switch element {
        case .fontFamily(let value):
            fontFamily = value
        case .fontSize(let value):
            fontSize = value
            // TODO: Add more text styles here.
            // font-weight, font-style, font-variant etc.
        }
    }
}
