/*
 *  CheckerPattern.c
 *  Drip
 *
 *  Created by Nur Monson on 10/12/07.
 *  Copyright 2007 theidiotproject. All rights reserved.
 *
 */

#include "CheckerPattern.h"

void drawCheckerPattern( void *info, CGContextRef cxt )
{
	float size = *(float *)info;
	
	CGContextSetRGBFillColor( cxt, 1.0f, 1.0f, 1.0f, 1.0f );
	CGRect checkerRect = CGRectMake(0.0f,0.0f,size,size);
	CGContextFillRect( cxt, checkerRect );
	checkerRect.origin.x += size;
	checkerRect.origin.y = checkerRect.origin.x;
	CGContextFillRect( cxt, checkerRect );
	
	checkerRect.origin.y -= size;
	CGContextSetRGBFillColor( cxt, 0.7f,0.7f,0.7f, 1.0f);
	CGContextFillRect( cxt, checkerRect );
	
	checkerRect.origin.x -= size;
	checkerRect.origin.y += size;
	CGContextFillRect( cxt, checkerRect );
}

void checkerPatternInfoRelease( void *info )
{
	free( info );
}

static const CGPatternCallbacks patternCallbacks = {0, &drawCheckerPattern, &checkerPatternInfoRelease };

void drawCheckerPatternInContextWithPhase( CGContextRef cxt, CGSize phase, CGRect aRect, float size )
{
	CGContextSaveGState( cxt ); {
		float *sizePointer;
		sizePointer = malloc( sizeof(float) );
		*sizePointer = size;
		CGPatternRef checkerPattern = CGPatternCreate(sizePointer, CGRectMake(0.0f,0.0f, *sizePointer*2.0f, *sizePointer*2.0f), CGAffineTransformMake(1,0,0, 1,0,0), *sizePointer*2.0f, *sizePointer*2.0f, kCGPatternTilingConstantSpacingMinimalDistortion, true, &patternCallbacks );
		CGColorSpaceRef checkerColorSpace = CGColorSpaceCreatePattern(NULL);
		CGContextSetFillColorSpace( cxt, checkerColorSpace );
		CGColorSpaceRelease( checkerColorSpace );
		
		float alpha = 1.0f;
		CGContextSetFillPattern( cxt, checkerPattern, &alpha );
		CGContextSetPatternPhase( cxt, phase );
		CGContextFillRect( cxt, aRect );
		CGPatternRelease( checkerPattern );
	} CGContextRestoreGState( cxt );
}
