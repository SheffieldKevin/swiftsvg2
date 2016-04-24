//
//  MISVGUtilities.swift
//  SwiftSVG
//
//  Created by Kevin Meaney on 21/09/2015.
//  Copyright © 2015 No. All rights reserved.
//

import Foundation

let defaultSaveFolder = "~/Desktop/Current/swiftsvg"

func jsonObjectToString(jsonObject: AnyObject) -> String? {
    if NSJSONSerialization.isValidJSONObject(jsonObject) {
        let data = try? NSJSONSerialization.dataWithJSONObject(jsonObject,
                       options: NSJSONWritingOptions.PrettyPrinted)
                    // options: NSJSONWritingOptions.init(rawValue: 0))
        if let data = data,
            let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding) {
                return jsonString as String
        }
    }
    return nil
}

public func writeMovingImagesJSONObject(jsonObject: [NSString : AnyObject], fileURL: NSURL) {
    guard let jsonString = jsonObjectToString(jsonObject) else {
        return
    }
    
    do {
        try jsonString.writeToURL(fileURL, atomically: false, encoding: NSUTF8StringEncoding)
    }
    catch {
        print("Failed to save file: \(fileURL.path!)")
    }
}

public func writeMovingImagesJSON(jsonObject: [NSString : AnyObject], sourceFileURL: NSURL) {
    guard let fileName = sourceFileURL.lastPathComponent else {
        return
    }
    
    let shortName = NSString(string: fileName).stringByDeletingPathExtension
    let newName = shortName.stringByAppendingString(".json")
    let saveFolder = NSString(string: defaultSaveFolder).stringByExpandingTildeInPath
    let folderURL = NSURL(fileURLWithPath: saveFolder, isDirectory: true)
    
    guard let newFileURL = NSURL(string: newName, relativeToURL: folderURL) else {
        return
    }
    
    guard let jsonString = jsonObjectToString(jsonObject) else {
        return
    }
    
    do {
        try jsonString.writeToURL(newFileURL, atomically: false, encoding: NSUTF8StringEncoding)
    }
    catch {
        print("Failed to save file: \(saveFolder)/\(newName)")
    }
}

internal func makePointDictionary(point: CGPoint = CGPoint.zero) -> MovingImagesPath {
    return [
        MIJSONKeyX : point.x,
        MIJSONKeyY : point.y
    ]
}

internal func makeLineDictionary(startPoint: CGPoint, endPoint: CGPoint) -> MovingImagesPath {
    return [
        MIJSONKeyLine : [
            MIJSONKeyStartPoint : makePointDictionary(startPoint),
            MIJSONKeyEndPoint : makePointDictionary(endPoint),
        ],
        MIJSONKeyElementType : MIJSONValueLineElement
    ]
}

internal func makePathDictionary(pathElements: NSArray, startPoint: CGPoint = CGPoint.zero) -> MovingImagesPath {
    return [
        MIJSONKeyArrayOfPathElements : pathElements,
        MIJSONKeyStartPoint : makePointDictionary(CGPoint(x: 0.0, y: 0.0))
    ]
}

internal func makeRectDictionary(rectangle: CGRect) -> [NSString : AnyObject] {
    return [
        MIJSONKeySize : [
            MIJSONKeyWidth : rectangle.size.width,
            MIJSONKeyHeight : rectangle.size.height,
        ],
        MIJSONKeyOrigin : [
            MIJSONKeyX : rectangle.origin.x,
            MIJSONKeyY : rectangle.origin.y,
        ]
    ]
}

internal func makeRectDictionary(rectangle: CGRect, makePath: Bool) -> MovingImagesPath {
    if makePath {
        return [
            MIJSONKeyStartPoint : makePointDictionary(),
            MIJSONKeyArrayOfPathElements : [
                [
                    MIJSONKeyElementType : MIJSONValuePathRectangle,
                    MIJSONKeyRect : makeRectDictionary(rectangle)
                ]
            ]
        ]
    }
    else {
        return [
            MIJSONKeyRect : makeRectDictionary(rectangle)
        ]
    }
}

internal func rectElementType(hasFill hasFill: Bool, hasStroke: Bool) -> NSString {
    if hasFill && hasStroke {
        return MIJSONValuePathFillAndStrokeElement
    }
    else if hasFill {
        return MIJSONValueRectangleFillElement
    }
    else if hasStroke {
        return MIJSONValueRectangleStrokeElement
    }
    else {
        return NSString(string: "")
    }
}

internal func makeRectDictionary(rectangle: CGRect, hasFill: Bool, hasStroke: Bool) -> MovingImagesPath {
    var theDict = makeRectDictionary(rectangle, makePath: hasFill && hasStroke)
    theDict[MIJSONKeyElementType] = rectElementType(hasFill: hasFill, hasStroke: hasStroke)
    return theDict
}

internal func pathElementType(hasFill hasFill: Bool, hasStroke: Bool) -> NSString {
    if hasFill && hasStroke {
        return MIJSONValuePathFillAndStrokeElement
    }
    else if hasFill {
        return MIJSONValuePathFillElement
    }
    else if hasStroke {
        return MIJSONValuePathStrokeElement
    }
    else {
        return NSString(string: "")
    }
}

internal func makeRoundedRectDictionary(rectangle: CGRect, rx: CGFloat, ry: CGFloat, hasFill: Bool, hasStroke: Bool) -> MovingImagesPath {
    let x0 = rectangle.origin.x
    let y0 = rectangle.origin.y
    let width = rectangle.size.width
    let height = rectangle.size.height
    
    return [
        MIJSONKeyStartPoint : makePointDictionary(CGPoint(x: x0 + rx, y: y0)),
        MIJSONKeyElementType : pathElementType(hasFill: hasFill, hasStroke: hasStroke),
        MIJSONKeyArrayOfPathElements : [
            [
                MIJSONKeyElementType : MIJSONValuePathLine,
                MIJSONKeyEndPoint : makePointDictionary(CGPoint(x: x0 + width - rx, y: y0))
            ],
            [
                MIJSONKeyElementType : MIJSONValuePathQuadraticCurve,
                MIJSONKeyEndPoint : makePointDictionary(CGPoint(x: x0 + width, y: y0 + ry)),
                MIJSONKeyControlPoint1 : makePointDictionary(CGPoint(x: x0 + width, y: y0))
            ],
            [
                MIJSONKeyElementType : MIJSONValuePathLine,
                MIJSONKeyEndPoint : makePointDictionary(CGPoint(x: x0 + width, y: y0 + height - ry))
            ],
            [
                MIJSONKeyElementType : MIJSONValuePathQuadraticCurve,
                MIJSONKeyEndPoint : makePointDictionary(CGPoint(x: x0 + width - rx, y: y0 + height)),
                MIJSONKeyControlPoint1 : makePointDictionary(CGPoint(x: x0 + width, y: y0 + height))
            ],
            [
                MIJSONKeyElementType : MIJSONValuePathLine,
                MIJSONKeyEndPoint : makePointDictionary(CGPoint(x: x0 + rx, y: y0 + height))
            ],
            [
                MIJSONKeyElementType : MIJSONValuePathQuadraticCurve,
                MIJSONKeyEndPoint : makePointDictionary(CGPoint(x: x0, y: y0 + height - ry)),
                MIJSONKeyControlPoint1 : makePointDictionary(CGPoint(x: x0, y: y0 + height))
            ],
            [
                MIJSONKeyElementType : MIJSONValuePathLine,
                MIJSONKeyEndPoint : makePointDictionary(CGPoint(x: x0, y: y0 + ry))
            ],
            [
                MIJSONKeyElementType : MIJSONValuePathQuadraticCurve,
                MIJSONKeyEndPoint : makePointDictionary(CGPoint(x: x0 + rx, y: y0)),
                MIJSONKeyControlPoint1 : makePointDictionary(CGPoint(x: x0, y: y0))
            ],
            [
                MIJSONKeyElementType : MIJSONValueCloseSubPath,
            ]
        ]
    ]
}

internal func makeOvalDictionary(rectangle: CGRect, makePath: Bool) -> MovingImagesPath {
    if makePath {
        return [
            MIJSONKeyStartPoint : makePointDictionary(),
            MIJSONKeyArrayOfPathElements : [
                [
                    MIJSONKeyElementType : MIJSONValuePathOval,
                    MIJSONKeyRect : makeRectDictionary(rectangle)
                ]
            ]
        ]
    }
    else {
        return [
            MIJSONKeyRect : makeRectDictionary(rectangle)
        ]
    }
}

internal func makeOvalDictionary(rectangle: CGRect, hasFill: Bool, hasStroke: Bool) -> MovingImagesPath {
    var theDict = makeOvalDictionary(rectangle, makePath: hasFill && hasStroke)
    if hasFill && hasStroke {
        theDict[MIJSONKeyElementType] = MIJSONValuePathFillAndStrokeElement
    }
    else if hasFill {
        theDict[MIJSONKeyElementType] = MIJSONValueOvalFillElement
    }
    else if hasStroke {
        theDict[MIJSONKeyElementType] = MIJSONValueOvalStrokeElement
    }
    return theDict
}

internal func makePolygonArray(points: [CGPoint]) -> [[NSString : AnyObject]] {
    return points.map() {
        return [
            MIJSONKeyElementType : MIJSONValuePathLine,
            MIJSONKeyEndPoint : [ MIJSONKeyX : $0.x, MIJSONKeyY : $0.y ]
        ]
    }
}

internal func makePolygonDictionary(points: [CGPoint]) -> MovingImagesPath {
    var pathArray = makePolygonArray(Array(points[1..<points.count]))
    pathArray.append([MIJSONKeyElementType : MIJSONValueCloseSubPath])
    return [
        MIJSONKeyStartPoint : makePointDictionary(points[0]),
        MIJSONKeyArrayOfPathElements : pathArray
    ]
}

internal func makePolylineDictionary(points: [CGPoint]) -> MovingImagesPath {
    return [
        MIJSONKeyStartPoint : makePointDictionary(points[0]),
        MIJSONKeyArrayOfPathElements : makePolygonArray(Array(points[1..<points.count]))
    ]
}

internal func makeCGAffineTransformDictionary(transform: CGAffineTransform) -> [NSString : NSObject] {
    return [
        MIJSONKeyAffineTransformM11 : transform.a,
        MIJSONKeyAffineTransformM12 : transform.b,
        MIJSONKeyAffineTransformM21 : transform.c,
        MIJSONKeyAffineTransformM22 : transform.d,
        MIJSONKeyAffineTransformtX : transform.tx,
        MIJSONKeyAffineTransformtY : transform.ty
    ]
}

internal func makeMovingImagesText(string: CFString,
                       fontSize: CGFloat,
             postscriptFontName: NSString,
                     textOrigin: CGPoint,
                      fillColor: CGColor?,
                    strokeWidth: CGFloat?,
                    strokeColor: CGColor?) -> MovingImagesText {
    var theDict:[NSString : NSObject] = [
        MIJSONKeyStringPostscriptFontName : postscriptFontName,
        MIJSONKeyElementType : MIJSONValueBasicStringElement,
        MIJSONKeyStringText : string,
        MIJSONKeyPoint : makePointDictionary(CGPoint(x:textOrigin.x, y: 0.0)),
        MIJSONKeyStringFontSize : fontSize,
        MIJSONKeyContextTransformation : [
            [
                MIJSONKeyTransformationType : MIJSONValueTranslate,
                MIJSONKeyTranslation : [ MIJSONKeyX : 0.0, MIJSONKeyY : textOrigin.y ]
            ],
            [
                MIJSONKeyTransformationType : MIJSONValueScale,
                MIJSONKeyScale : [ MIJSONKeyX : 1.0, MIJSONKeyY : -1.0 ]
            ]
        ]
    ]
    
    if let fillColor = fillColor {
        theDict[MIJSONKeyFillColor] = SVGColors.makeMIColorFromColor(fillColor)
    }
    
    if let strokeColor = strokeColor {
        theDict[MIJSONKeyStrokeColor] = SVGColors.makeMIColorFromColor(strokeColor)
    }
    
    if let strokeWidth = strokeWidth {
        theDict[MIJSONKeyStringStrokeWidth] = strokeWidth
    }
    
    // By having a wrapper dictionary the vertical text flipping can't override
    // any other transformations that might be applied to the object.
    let wrapperDict: MovingImagesText = [
        MIJSONKeyElementType : MIJSONValueArrayOfElements,
        MIJSONValueArrayOfElements : [ theDict ]
    ]
    return wrapperDict
}

public enum ColorError: ErrorType {
    case invalidColorDict
}

extension SVGColors {
    class func makeMIColorDictFromColor(color: CGColor) -> [NSString : AnyObject] {
        var colorDict = [NSString : AnyObject]()
        colorDict[MIJSONKeyColorColorProfileName] = "kCGColorSpaceSRGB"
        let colorComponents = CGColorGetComponents(color)
        colorDict[MIJSONKeyRed] = colorComponents[0]
        colorDict[MIJSONKeyGreen] = colorComponents[1]
        colorDict[MIJSONKeyBlue] = colorComponents[2]
        colorDict[MIJSONKeyAlpha] = colorComponents[3]
        return colorDict
    }

    //! Converts a float in the range from 0.0 to 1.0. Will clamp float to range first.
    class func to255(component: CGFloat) -> Int {
        let eta:CGFloat = 0.00195686274509804 // 0.499 / 255.0
        return Int(255 * (max(0.0, min(1.0, component)) + eta))
    }
    
    class func makeHexColor(red red: CGFloat, green: CGFloat, blue: CGFloat) -> String {
        let hexNum = to255(blue) + 256 * (to255(green) + 256 * to255(red))
        let string = String(format: "#%06X", arguments: [hexNum])
        return string
    }

    class func makeHexColor(color color: CGColor) -> String {
        let colorC = CGColorGetComponents(color)
        return makeHexColor(red: colorC[0], green: colorC[1], blue: colorC[2])
    }

    class func makeMIColorFromColor(color: CGColor) -> NSObject {
        // If alpha is not unity, don't create a hex string color.
        let colorComponents = CGColorGetComponents(color)
        if colorComponents[3] < 0.998 {
            return makeMIColorDictFromColor(color)
        }
        else {
            return makeHexColor(color: color)
        }
    }

    class func colorDictToHexColor(colorDict: [NSObject : AnyObject]) throws -> String {
        guard let red = colorDict["red"] as? CGFloat,
           let green = colorDict["green"] as? CGFloat,
           let blue = colorDict["blue"] as? CGFloat else {
            throw ColorError.invalidColorDict
        }
        return makeHexColor(red: red, green: green, blue: blue)
    }
    
    class func colorDictToMIColorDict(colorDict: [NSObject : AnyObject]) -> [NSObject : AnyObject] {
        let mColorDict = [
            MIJSONKeyRed : colorDict["red"]!,
            MIJSONKeyGreen : colorDict["green"]!,
            MIJSONKeyBlue : colorDict["blue"]!,
            MIJSONKeyColorColorProfileName : kCGColorSpaceSRGB
        ]
        return mColorDict
    }
}
