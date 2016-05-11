//
//  AppDelegate.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 2/25/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Cocoa

import SwiftSVG

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(aNotification: NSNotification) {
/*
        let url = NSBundle.mainBundle().URLForResource("Ghostscript_Tiger", withExtension: "svg")
        // let url = NSBundle.mainBundle().URLForResource("Apple_Swift_Logo", withExtension: "svg")
        (NSDocumentController.sharedDocumentController() ).openDocumentWithContentsOfURL(url!, display: true) {
            (document: NSDocument?, flag: Bool, error: NSError?) in
        }
*/
    }
    
    @IBAction func processFolder(sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.title = "SVG Files"
        openPanel.prompt = "Select folder with SVG files"
        
        openPanel.beginWithCompletionHandler({
            result in
            guard result == NSFileHandlingPanelOKButton else {
                return
            }
            let folderURL = openPanel.URLs[0]
            // Need to find any svg files in the folder.
            let fileManager = NSFileManager.defaultManager()
            let fileList = try? fileManager.contentsOfDirectoryAtURL(folderURL,
                includingPropertiesForKeys: nil,
                options: [])
            guard let files = fileList where files.count > 0 else {
                return
            }
            
            let svgFiles = files.filter() {
                fileURL in
                return fileURL.lastPathComponent!.hasSuffix(".svg")
            }
            
            guard svgFiles.count > 0 else {
                return
            }
            
            // OK we have more than one file, lets put up the dialog to ask where do we want to save the results
            let savePanel = NSOpenPanel()
            savePanel.canChooseDirectories = true
            savePanel.canChooseFiles = false
            savePanel.canCreateDirectories = true
            savePanel.allowsMultipleSelection = false
            savePanel.title = "MovingImages drawing files"
            savePanel.prompt = "Save folder for MovingImages"
            savePanel.beginWithCompletionHandler({
                result in
                guard result == NSFileHandlingPanelOKButton else {
                    return
                }
                let destFolder = savePanel.URLs[0]
                
                dispatch_apply(svgFiles.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    index in
                    let svgFileURL = svgFiles[index]
                    let svgFileName = svgFileURL.lastPathComponent!
                    let movingImagesFile = svgFileName.stringByReplacingOccurrencesOfString(".svg", withString: ".json")
                    let newFileURL = destFolder.URLByAppendingPathComponent(movingImagesFile)
                    var encoding = NSStringEncoding()
                    guard let source = try? String(contentsOfURL: svgFileURL, usedEncoding: &encoding) else {
                        return
                    }
                    guard let xmlDocument = try? NSXMLDocument(XMLString: source, options: 0) else {
                        return
                    }
                    
                    let processor = SVGProcessor()
                    guard let tempDocument = try? processor.processXMLDocument(xmlDocument) else {
                        return
                    }
                    guard let svgDocument = tempDocument else {
                        return
                    }
                    
                    let renderer = MovingImagesRenderer()
                    let svgRenderer = SVGRenderer()
                    let _ = try? svgRenderer.renderDocument(svgDocument, renderer: renderer)
                    let jsonObject = renderer.generateJSONDict()
                    if let demoObject = makeMIDemoObjectFromJSONObject(jsonObject) {
                        writeMovingImagesJSONObject(demoObject, fileURL: newFileURL)
                    }
                })
            })
        })
    }
}

