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

This is a pure Swift SVG Parser, Renderer, Optimiser and (coming soon) binary exporter.

![Obligatory Screenshot](Documentation/map-2.svg)

It depends on [SwiftGraphics](https://github.com/schwa/SwiftGraphics) and [SwiftParsing](https://github.com/schwa/SwiftParsing).

## How to build.

The project should build and run out of the box. You need Swift 2 (currently b6) and Mac OS X 10.10 (if not 11).

## How to hack.

This project uses git submodules to manage the various repositories needed to build the project.