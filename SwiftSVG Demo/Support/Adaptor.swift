//
//  NodeAdaptor.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 3/13/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Foundation

class ObjectAdaptor: NSObject, NSCopying {

    struct Template {
        var childrenGetter: (AnyObject -> [AnyObject]?)!
        var getters: [String: AnyObject -> AnyObject?] = [: ]

        init() {
        }
    }

    weak var object: AnyObject!
    let template: Template

    init(object: AnyObject, template: Template) {
        self.object = object
        self.template = template
    }

    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = ObjectAdaptor(object: object, template: template)
        return copy

    }

    var children: [ObjectAdaptor]? {
        get {
            guard let children = template.childrenGetter(object) else {
                return nil
            }
            return children.map() {
                return ObjectAdaptor(object: $0, template: self.template)
            }
        }
    }

    override func valueForKey(key: String) -> AnyObject? {
        switch key {
            case "children":
                return children
            default:
                if let getter = template.getters[key] {
                    return getter(object)
                }
        }
        return nil
    }
}
