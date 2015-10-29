//
//  NSXML+Extensions.swift
//  SwiftSVG
//
//  Created by Jonathan Wight on 8/26/15.
//  Copyright © 2015 No. All rights reserved.
//

import Foundation

extension NSXMLElement {

    subscript(name: String) -> NSXMLNode? {
        get {
            return attributeForName(name)
        }
        set {
            if let newValue = newValue {
                assert(name == newValue.name)
                addAttribute(newValue)
            }
            else {
                removeAttributeForName(name)
            }
        }
    }
}

