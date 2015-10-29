//
//  SummaryViewController.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 3/24/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Cocoa

import SwiftUtilities
import SwiftSVG

class SummaryViewController: NSViewController {

    @objc dynamic var elementCounts: [String: Int]?

    var svgDocument: SVGDocument! {
        didSet {
            if svgDocument != nil {
                try! deepThought()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    func deepThought() throws {

        var elementCounts: [String: Int] = [
            "total": 0,
            "path": 0,
            "group": 0,
        ]

        SVGElement.walker.walk(svgDocument) {
            (node: SVGElement, depth: Int) -> Void in
            elementCounts["total"]! += 1
            switch node {
                case node as SVGPath:
                    elementCounts["path"]! += 1
                case node as SVGGroup:
                    elementCounts["group"]! += 1
                default:
                    break
            }
        }

    self.elementCounts = elementCounts
    }

}
