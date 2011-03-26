/*
 *  TIPCGUtils.c
 *  TriviaPlayer
 *
 *  Created by Nur Monson on 10/6/06.
 *  Copyright 2006 theidiotproject. All rights reserved.
 *
 */

#include "TIPCGUtils.h"

// For debugging
void TIPDumpCGImageToPNG(CGImageRef theImage, const char* path)
{
	CFURLRef url = CFURLCreateFromFileSystemRepresentation(NULL, (const UInt8*)path, strlen(path), false);
	CGImageDestinationRef imageDest = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
	CGImageDestinationAddImage(imageDest, theImage, NULL);
	CGImageDestinationFinalize(imageDest);
	CFRelease(imageDest);
	CFRelease(url);
}

CGMutablePathRef TIPCGUtilsRoundedBoxCreate( CGRect inRect, float margin, float radius, float lineWidth )
{	
	float halfLineWidth = lineWidth/2.0f;
	
	inRect.origin.x += margin;
	inRect.origin.y += margin;
	inRect.size.width -= 2.0f*margin;
	inRect.size.height -= 2.0f*margin;
	
	CGMutablePathRef roundedBoxRef = CGPathCreateMutable();
	
	CGPathMoveToPoint(roundedBoxRef, NULL,
					  inRect.origin.x + halfLineWidth, inRect.origin.y + halfLineWidth + radius);
	CGPathAddLineToPoint(roundedBoxRef, NULL,
						 inRect.origin.x + halfLineWidth, inRect.origin.y + inRect.size.height - radius - halfLineWidth);
	CGPathAddArcToPoint(roundedBoxRef, NULL,
						inRect.origin.x + halfLineWidth, inRect.origin.y + inRect.size.height - halfLineWidth,
						inRect.origin.x + halfLineWidth + radius, inRect.origin.y + inRect.size.height - halfLineWidth,
						radius);
	CGPathAddArcToPoint(roundedBoxRef, NULL,
						inRect.origin.x + inRect.size.width - halfLineWidth, inRect.origin.y + inRect.size.height - halfLineWidth,
						inRect.origin.x + inRect.size.width - halfLineWidth, inRect.origin.y + inRect.size.height - radius - halfLineWidth,
						radius);
	CGPathAddArcToPoint(roundedBoxRef, NULL,
						inRect.origin.x + inRect.size.width - halfLineWidth, inRect.origin.y + halfLineWidth,
						inRect.origin.x + inRect.size.width - radius - halfLineWidth, inRect.origin.y + halfLineWidth,
						radius);
	CGPathAddArcToPoint(roundedBoxRef, NULL,
						inRect.origin.x + halfLineWidth, inRect.origin.y + halfLineWidth,
						inRect.origin.x + halfLineWidth, inRect.origin.y + halfLineWidth + radius,
						radius);
	
	return roundedBoxRef;
}

CGMutablePathRef TIPCGUtilsPartialRoundedBoxCreate( CGRect inRect, float radius, bool lowerRight, bool upperRight, bool upperLeft, bool lowerLeft )
{
	CGMutablePathRef roundedBoxRef = CGPathCreateMutable();
	
	if( lowerRight ) {
		CGPathMoveToPoint(roundedBoxRef, NULL,
						  inRect.origin.x, inRect.origin.y + radius);
	} else {
		CGPathMoveToPoint(roundedBoxRef, NULL,
						  inRect.origin.x, inRect.origin.y);
	}
	
	if( upperRight ) {
		CGPathAddLineToPoint(roundedBoxRef, NULL,
							 inRect.origin.x, inRect.origin.y + inRect.size.height - radius);
		CGPathAddArcToPoint(roundedBoxRef, NULL,
							inRect.origin.x, inRect.origin.y + inRect.size.height,
							inRect.origin.x + radius, inRect.origin.y + inRect.size.height,
							radius);
	} else {
		CGPathAddLineToPoint(roundedBoxRef, NULL,
							 inRect.origin.x, inRect.origin.y + inRect.size.height);
	}
	
	if( upperLeft ) {
		CGPathAddArcToPoint(roundedBoxRef, NULL,
							inRect.origin.x + inRect.size.width, inRect.origin.y + inRect.size.height,
							inRect.origin.x + inRect.size.width, inRect.origin.y + inRect.size.height - radius,
							radius);
	} else {
		CGPathAddLineToPoint(roundedBoxRef, NULL,
							 inRect.origin.x + inRect.size.width, inRect.origin.y + inRect.size.height);
	}
	
	if( lowerLeft ) {
		CGPathAddArcToPoint(roundedBoxRef, NULL,
							inRect.origin.x + inRect.size.width, inRect.origin.y,
							inRect.origin.x + inRect.size.width - radius, inRect.origin.y,
							radius);
	} else {
		CGPathAddLineToPoint(roundedBoxRef, NULL,
							 inRect.origin.x + inRect.size.width, inRect.origin.y);
	}
	
	if( lowerRight ) {
		CGPathAddArcToPoint(roundedBoxRef, NULL,
							inRect.origin.x, inRect.origin.y,
							inRect.origin.x, inRect.origin.y + radius,
							radius);
	}
	
	return roundedBoxRef;
}

CGMutablePathRef TIPCGUtilsPill( CGRect inRect )
{
	float radius;
	
	if( inRect.size.width < inRect.size.height )
		radius = inRect.size.width/2.0f;
	else
		radius = inRect.size.height/2.0f;
	
	return TIPCGUtilsPartialRoundedBoxCreate(inRect, radius, TRUE,TRUE,TRUE,TRUE);
}
