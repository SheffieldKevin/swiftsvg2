//
//  SVGElement+Extensions.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 3/13/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import SwiftUtilities

public extension SVGElement {

    static var walker: Walker <SVGElement> {
        let walker = Walker() {
            (node: SVGElement) -> [SVGElement]? in
            guard let node = node as? SVGContainer else {
                return nil
            }
            return node.children
        }
        return walker
    }

    var indexPath: NSIndexPath {
        get {
            guard let parent = parent else {
                return NSIndexPath(index: 0)
            }
            let index = parent.children.indexOf(self)!
            return parent.indexPath.indexPathByAddingIndex(index)
        }
    }

}