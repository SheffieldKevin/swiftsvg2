# SwiftSVG

## Fork of [Schwa's SwiftSVG project](https://github.com/schwa/SwiftSVG)

This is a fork of [Schwa's SwiftSVG project](https://github.com/schwa/SwiftSVG) and has been significantly extended to include a lot more of the SVG specification. This project  relies heavily on Schwa's work.

The various SVG shapes this project adds are:

*  SVGLine
*  SVGPolyLine
*  SVGPolygon
*  SVGCircle
*  SVGRect
*  SVGEllipse
*  SVGText †
*  SVGDefs †
*  SVGSymbol
*  SVGLinearGradient ††
*  SVGUse

† These are not complete. Text will not handle text formatting changes within a text span. The text element will not flow text from one text span to the next so that absolute text positioning for each span only is possible. Other than elements defined within symbols only the linear gradient def element is recognized.

†† The SVGLinearGradient element implements most of the SVG specification but has not tested with more than a few documents at present.

The various SVG styles that this project adds are:

* style
* fill-rule
* stroke-linejoin
* stroke-linecap
* stroke-miterlimit
* stroke-linedash
* stroke-dashoffset

This project also implements rotation around a point.

## What is This

This is a Swift SVG Parser, and Renderer. There is a small amount of c and objective-c in the project. The following image:  

![Obligatory Screenshot](Documentation/map-2.png)  

is the SwiftSVG rendering of this [svg file](Documentation/map-2.svg) generated from [OpenStreetMap](http://openstreetmap.org)

It depends on [SwiftGraphics](https://github.com/schwa/SwiftGraphics) and [SwiftParsing](https://github.com/schwa/SwiftParsing).

I have extended this project because I needed a renderer to convert from svg to my json representation of CoreGraphics called [MovingImages](https://gitlab.com/ktam/movingimages). Schwa's design of this project has made that possible. His design also makes it easy to add rendering as CoreGraphics code.

## How to build.

The project should build and run out of the box. You need Xcode 7.3, Swift 2.2 and Mac OS X 10.10

## How to hack.

This project uses git submodules to manage the various repositories needed to build the project.

### Things I'd like to see done:

It would be nice to remove the dependency on NSXMLElement which is OS X only. This is the only thing holding the project back from being iOS as well.

To remove the last remnants of Objective-C from the project.
