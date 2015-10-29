//
//  CCenteringClipView.swift
//  SwiftSVGTestNT
//
//  Created by Jonathan Wight on 3/13/15.
//  Copyright (c) 2015 No. All rights reserved.
//

import Cocoa

class CenteringClipView: NSClipView {

    var centersDocumentView: Bool = true


    override func constrainBoundsRect(proposedBounds: NSRect) -> NSRect {
        if centersDocumentView == false {
            return super.constrainBoundsRect(proposedBounds)
        }

        let documentViewFrameRect = (documentView as! NSView).frame
        var constrainedClipViewBoundsRect = super.constrainBoundsRect(proposedBounds)

        // If proposed clip view bounds width is greater than document view frame width, center it horizontally.
        if proposedBounds.size.width >= documentViewFrameRect.size.width {
            constrainedClipViewBoundsRect.origin.x = centeredCoordinateUnitWithProposedContentViewBoundsDimensionAndDocumentViewFrameDimension(proposedBounds.size.width, documentViewFrameDimension: documentViewFrameRect.size.width)
        }

        if proposedBounds.size.height >= documentViewFrameRect.size.height {

            // Adjust the proposed origin.y
            constrainedClipViewBoundsRect.origin.y = centeredCoordinateUnitWithProposedContentViewBoundsDimensionAndDocumentViewFrameDimension(proposedBounds.size.height, documentViewFrameDimension: documentViewFrameRect.size.height);
        }


        return constrainedClipViewBoundsRect
    }
}

private func centeredCoordinateUnitWithProposedContentViewBoundsDimensionAndDocumentViewFrameDimension(proposedContentViewBoundsDimension: CGFloat, documentViewFrameDimension: CGFloat ) -> CGFloat {
    return floor((proposedContentViewBoundsDimension - documentViewFrameDimension) / -2.0)
}


//
//    // If proposed clip view bounds width is greater than document view frame width, center it horizontally.
//    if (proposedClipViewBoundsRect.size.width >= documentViewFrameRect.size.width) {
//        // Adjust the proposed origin.x
//        constrainedClipViewBoundsRect.origin.x = centeredCoordinateUnitWithProposedContentViewBoundsDimensionAndDocumentViewFrameDimension(proposedClipViewBoundsRect.size.width, documentViewFrameRect.size.width);
//    }
//
//    // If proposed clip view bounds is hight is greater than document view frame height, center it vertically.
//    if (proposedClipViewBoundsRect.size.height >= documentViewFrameRect.size.height) {
//
//        // Adjust the proposed origin.y
//        constrainedClipViewBoundsRect.origin.y = centeredCoordinateUnitWithProposedContentViewBoundsDimensionAndDocumentViewFrameDimension(proposedClipViewBoundsRect.size.height, documentViewFrameRect.size.height);
//    }
//
//    return constrainedClipViewBoundsRect;
//}
//