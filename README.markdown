# SwiftSVG

## What is This

This is a pure Swift SVG Parser, Renderer, Optimiser and (coming soon) binary exporter.

[Obligatory Screenshot ![Obligatory Screenshot](Documentation/Screenshot_1.png)](Documentation/Screenshot_1.png)

It depends on [SwiftGraphics](https://github.com/schwa/SwiftGraphics) and [SwiftParsing](https://github.com/schwa/SwiftParsing).

## How to build.

The project should build and run out of the box. You need Swift 2 (currently b6) and Mac OS X 10.10 (if not 11).

## How to hack.

This project uses [Carthage](https://github.com/Carthage/Carthage)

Issue the following command to tell carthage to update the sub-projects and check the source out as git submodules.

```
carthage update --configuration Debug --platform Mac
```
