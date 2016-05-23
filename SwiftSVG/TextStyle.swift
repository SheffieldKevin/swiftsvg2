//  TextStyle.swift
//  SwiftSVG
//
//  Created by Kevin Meaney on 30/09/2015.
//  Copyright © 2015 No. All rights reserved.

import Foundation

import CoreGraphics

public enum TextAnchor: String {
    case start
    case middle
    case end
    
    init(input: String) {
        switch input {
            case "start":
                self = start
            case "middle":
                self = middle
            case "end":
                self = end
        	default:
                self = start
        }
    }
    
    var coreTextAlignment: CTTextAlignment {
        get {
            switch self {
            case start:
                return .Left
            case middle:
                return .Center
            case end:
                return .Right
            }
        }
    }
}

public struct TextStyle {
    public var fontFamily: String?
    public var fontSize: CGFloat?
    public var textAnchor: TextAnchor?
    public init() {
        
    }
}

public enum TextStyleElement {
    case fontFamily(String)
    case fontSize(CGFloat)
    case textAnchor(TextAnchor)
}

public extension TextStyle {
    mutating func add(element: TextStyleElement) {
        switch element {
        case .fontFamily(let value):
            fontFamily = value
        case .fontSize(let value):
            fontSize = value
        case .textAnchor(let value):
            textAnchor = value
            // TODO: Add more text styles here.
            // font-weight, font-style, font-variant etc.
        }
    }
}
