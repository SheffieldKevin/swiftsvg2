//
//  Document.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 2/25/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Cocoa

import SwiftSVG

class Document: NSDocument {

    dynamic var source: String? = nil

    override init() {
        super.init()
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        if let controller = aController.contentViewController as? ViewController {
            controller.document = self
        }
    }

//    override class func autosavesInPlace() -> Bool {
//        return false
//    }

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
        if let controller = windowController.contentViewController as? ViewController {
            controller.document = self
        }
        self.addWindowController(windowController)
    }

    override func readFromURL(url: NSURL, ofType typeName: String) throws {
        var encoding = NSStringEncoding()
        source = try String(contentsOfURL: url, usedEncoding: &encoding)
    }

    override func dataOfType(typeName: String) throws -> NSData {
        guard let data = source?.dataUsingEncoding(NSUTF8StringEncoding) else {
            throw NSError(domain: "TODO", code: -1, userInfo: nil)
        }
        return data
    }

    deinit {
        print("Document has been deallocated")
    }
}


