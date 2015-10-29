//
//  SVGStandardColors.swift
//  SwiftSVG
//
//  Created by Kevin Meaney on 20/09/2015.
//  Copyright © 2015 No. All rights reserved.
//

import Foundation
import SwiftGraphics

// SVG Color names
private let svgColorNames = [
    "red":       "rgb(255, 0, 0)",     "lightgray":            "rgb(211, 211, 211)",
    "tan":       "rgb(210, 180, 140)", "lightgrey":            "rgb(211, 211, 211)",
    "aqua":      "rgb( 0, 255, 255)",  "lightpink":            "rgb(255, 182, 193)",
    "blue":      "rgb( 0, 0, 255)",    "limegreen":            "rgb( 50, 205, 50)",
    "cyan":      "rgb( 0, 255, 255)",  "mintcream":            "rgb(245, 255, 250)",
    "gold":      "rgb(255, 215, 0)",   "mistyrose":            "rgb(255, 228, 225)",
    "gray":      "rgb(128, 128, 128)", "olivedrab":            "rgb(107, 142, 35)",
    "grey":      "rgb(128, 128, 128)", "orangered":            "rgb(255, 69, 0)",
    "lime":      "rgb( 0, 255, 0)",    "palegreen":            "rgb(152, 251, 152)",
    "navy":      "rgb( 0, 0, 128)",    "peachpuff":            "rgb(255, 218, 185)",
    "peru":      "rgb(205, 133, 63)",  "rosybrown":            "rgb(188, 143, 143)",
    "pink":      "rgb(255, 192, 203)", "royalblue":            "rgb( 65, 105, 225)",
    "plum":      "rgb(221, 160, 221)", "slateblue":            "rgb(106, 90, 205)",
    "snow":      "rgb(255, 250, 250)", "slategray":            "rgb(112, 128, 144)",
    "teal":      "rgb( 0, 128, 128)",  "slategrey":            "rgb(112, 128, 144)",
    "azure":     "rgb(240, 255, 255)", "steelblue":            "rgb( 70, 130, 180)",
    "beige":     "rgb(245, 245, 220)", "turquoise":            "rgb( 64, 224, 208)",
    "black":     "rgb( 0, 0, 0)",      "aquamarine":           "rgb(127, 255, 212)",
    "brown":     "rgb(165, 42, 42)",   "blueviolet":           "rgb(138, 43, 226)",
    "coral":     "rgb(255, 127, 80)",  "chartreuse":           "rgb(127, 255, 0)",
    "green":     "rgb( 0, 128, 0)",    "darkorange":           "rgb(255, 140, 0)",
    "ivory":     "rgb(255, 255, 240)", "darkorchid":           "rgb(153, 50, 204)",
    "khaki":     "rgb(240, 230, 140)", "darksalmon":           "rgb(233, 150, 122)",
    "linen":     "rgb(250, 240, 230)", "darkviolet":           "rgb(148, 0, 211)",
    "olive":     "rgb(128, 128, 0)",   "dodgerblue":           "rgb( 30, 144, 255)",
    "wheat":     "rgb(245, 222, 179)", "ghostwhite":           "rgb(248, 248, 255)",
    "white":     "rgb(255, 255, 255)", "lightcoral":           "rgb(240, 128, 128)",
    "bisque":    "rgb(255, 228, 196)", "lightgreen":           "rgb(144, 238, 144)",
    "indigo":    "rgb( 75, 0, 130)",   "mediumblue":           "rgb( 0, 0, 205)",
    "maroon":    "rgb(128, 0, 0)",     "papayawhip":           "rgb(255, 239, 213)",
    "orange":    "rgb(255, 165, 0)",   "powderblue":           "rgb(176, 224, 230)",
    "orchid":    "rgb(218, 112, 214)", "sandybrown":           "rgb(244, 164, 96)",
    "purple":    "rgb(128, 0, 128)",   "whitesmoke":           "rgb(245, 245, 245)",
    "salmon":    "rgb(250, 128, 114)", "darkmagenta":          "rgb(139, 0, 139)",
    "sienna":    "rgb(160, 82, 45)",   "deepskyblue":          "rgb( 0, 191, 255)",
    "silver":    "rgb(192, 192, 192)", "floralwhite":          "rgb(255, 250, 240)",
    "tomato":    "rgb(255, 99, 71)",   "forestgreen":          "rgb( 34, 139, 34)",
    "violet":    "rgb(238, 130, 238)", "greenyellow":          "rgb(173, 255, 47)",
    "yellow":    "rgb(255, 255, 0)",   "lightsalmon":          "rgb(255, 160, 122)",
    "crimson":   "rgb(220, 20, 60)",   "lightyellow":          "rgb(255, 255, 224)",
    "darkred":   "rgb(139, 0, 0)",     "navajowhite":          "rgb(255, 222, 173)",
    "dimgray":   "rgb(105, 105, 105)", "saddlebrown":          "rgb(139, 69, 19)",
    "dimgrey":   "rgb(105, 105, 105)", "springgreen":          "rgb( 0, 255, 127)",
    "fuchsia":   "rgb(255, 0, 255)",   "yellowgreen":          "rgb(154, 205, 50)",
    "hotpink":   "rgb(255, 105, 180)", "antiquewhite":         "rgb(250, 235, 215)",
    "magenta":   "rgb(255, 0, 255)",   "darkseagreen":         "rgb(143, 188, 143)",
    "oldlace":   "rgb(253, 245, 230)", "lemonchiffon":         "rgb(255, 250, 205)",
    "skyblue":   "rgb(135, 206, 235)", "lightskyblue":         "rgb(135, 206, 250)",
    "thistle":   "rgb(216, 191, 216)", "mediumorchid":         "rgb(186, 85, 211)",
    "cornsilk":  "rgb(255, 248, 220)", "mediumpurple":         "rgb(147, 112, 219)",
    "darkblue":  "rgb( 0, 0, 139)",    "midnightblue":         "rgb( 25, 25, 112)",
    "darkcyan":  "rgb( 0, 139, 139)",  "darkgoldenrod":        "rgb(184, 134, 11)",
    "darkgray":  "rgb(169, 169, 169)", "darkslateblue":        "rgb( 72, 61, 139)",
    "darkgrey":  "rgb(169, 169, 169)", "darkslategray":        "rgb( 47, 79, 79)",
    "deeppink":  "rgb(255, 20, 147)",  "darkslategrey":        "rgb( 47, 79, 79)",
    "honeydew":  "rgb(240, 255, 240)", "darkturquoise":        "rgb( 0, 206, 209)",
    "lavender":  "rgb(230, 230, 250)", "lavenderblush":        "rgb(255, 240, 245)",
    "moccasin":  "rgb(255, 228, 181)", "lightseagreen":        "rgb( 32, 178, 170)",
    "seagreen":  "rgb( 46, 139, 87)",  "palegoldenrod":        "rgb(238, 232, 170)",
    "seashell":  "rgb(255, 245, 238)", "paleturquoise":        "rgb(175, 238, 238)",
    "aliceblue": "rgb(240, 248, 255)", "palevioletred":        "rgb(219, 112, 147)",
    "burlywood": "rgb(222, 184, 135)", "blanchedalmond":       "rgb(255, 235, 205)",
    "cadetblue": "rgb( 95, 158, 160)", "cornflowerblue":       "rgb(100, 149, 237)",
    "chocolate": "rgb(210, 105, 30)",  "darkolivegreen":       "rgb( 85, 107, 47)",
    "darkgreen": "rgb( 0, 100, 0)",    "lightslategray":       "rgb(119, 136, 153)",
    "darkkhaki": "rgb(189, 183, 107)", "lightslategrey":       "rgb(119, 136, 153)",
    "firebrick": "rgb(178, 34, 34)",   "lightsteelblue":       "rgb(176, 196, 222)",
    "gainsboro": "rgb(220, 220, 220)", "mediumseagreen":       "rgb( 60, 179, 113)",
    "goldenrod": "rgb(218, 165, 32)",  "mediumslateblue":      "rgb(123, 104, 238)",
    "indianred": "rgb(205, 92, 92)",   "mediumturquoise":      "rgb( 72, 209, 204)",
    "lawngreen": "rgb(124, 252, 0)",   "mediumvioletred":      "rgb(199, 21, 133)",
    "lightblue": "rgb(173, 216, 230)", "mediumaquamarine":     "rgb(102, 205, 170)",
    "lightcyan": "rgb(224, 255, 255)", "mediumspringgreen":    "rgb( 0, 250, 154)",
    "lightgoldenrodyellow": "rgb(250, 250, 210)"
]

private class SVGStandardColors {
    class func colorFromName(name: String) -> String? {
        return svgColorNames[name]
    }
}

class SVGColors {
    class func stringToColor(string: String) throws -> CGColor? {
        if let colorDictionary = try stringToColorDictionary(string) {
            return colorDictionaryToCGColor(colorDictionary)
        }
        return .None
    }
    
    class func stringToColorDictionary(string: String) throws -> [NSObject : AnyObject]? {
        if string == "none" {
            return nil
        }
        if let colorWithName = SVGStandardColors.colorFromName(string) {
            return try CColorConverter.sharedInstance().colorDictionaryWithString(colorWithName)
        }
        return try CColorConverter.sharedInstance().colorDictionaryWithString(string)
    }
    
    class func colorDictionaryToCGColor(cDict: [NSObject : AnyObject]) -> CGColor? {
        return CGColor.color(red: cDict["red"] as! CGFloat, green: cDict["green"] as! CGFloat,
            blue: cDict["blue"] as! CGFloat, alpha: 1.0)
    }
}
