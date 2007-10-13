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
	CGContextSetRGBFillColor( cxt, 1.0f, 1.0f, 1.0f, 1.0f );
	CGRect checkerRect = CGRectMake(0.0f,0.0f,PATTERN_SIZE/2.0f,PATTERN_SIZE/2.0f);
	CGContextFillRect( cxt, checkerRect );
	checkerRect.origin.x += PATTERN_SIZE/2.0f;
	checkerRect.origin.y = checkerRect.origin.x;
	CGContextFillRect( cxt, checkerRect );
	
	checkerRect.origin.y -= PATTERN_SIZE/2.0f;
	CGContextSetRGBFillColor( cxt, 0.7f,0.7f,0.7f, 1.0f);
	CGContextFillRect( cxt, checkerRect );
	
	checkerRect.origin.x -= PATTERN_SIZE/2.0f;
	checkerRect.origin.y += PATTERN_SIZE/2.0f;
	CGContextFillRect( cxt, checkerRect );
}

static const CGPatternCallbacks patternCallbacks = {0, &drawCheckerPattern, NULL};

void drawCheckerPatternInContextWithPhase( CGContextRef cxt, CGSize phase, CGRect aRect )
{
	CGContextSaveGState( cxt ); {
		CGPatternRef checkerPattern = CGPatternCreate(NULL, CGRectMake(0.0f,0.0f,PATTERN_SIZE,PATTERN_SIZE), CGAffineTransformMake(1,0,0, 1,0,0), PATTERN_SIZE,PATTERN_SIZE, kCGPatternTilingConstantSpacingMinimalDistortion, true, &patternCallbacks );
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
