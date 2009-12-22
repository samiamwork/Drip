/*
 *  CheckerPattern.c
 *  Drip
 *
 *  Created by Nur Monson on 10/12/07.
 *  Copyright 2007 theidiotproject. All rights reserved.
 *
 */

#include "CheckerPattern.h"

static void drawCheckerPattern( void *info, CGContextRef cxt )
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

static void checkerPatternInfoRelease( void *info )
{
	free( info );
}

static const CGPatternCallbacks patternCallbacks = {0, &drawCheckerPattern, &checkerPatternInfoRelease };

void drawCheckerPatternInContextWithPhase( const CGContextRef cxt, const CGSize phase, const CGRect aRect, const float size )
{
	CGContextSaveGState( cxt ); {
		float *sizePointer;
		sizePointer = malloc( sizeof(float) );
		*sizePointer = size;
		CGPatternRef checkerPattern = CGPatternCreate(sizePointer, CGRectMake(0.0f,0.0f, size*2.0f, size*2.0f), CGAffineTransformMake(1,0,0, 1,0,0), size*2.0f, size*2.0f, kCGPatternTilingConstantSpacingMinimalDistortion, true, &patternCallbacks );
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

void drawStripePattern( void *info, CGContextRef cxt )
{
	float size = *(float *)info;
	
	CGContextSetRGBFillColor( cxt, 0.5f, 0.5f, 0.5f, 0.2f );
	CGContextFillRect( cxt, CGRectMake(0.0f,0.0f,size,size));
	
	CGContextMoveToPoint( cxt, -size/2.0f, 0.0f );
	CGContextAddLineToPoint( cxt, size, size+size/2.0f );
	CGContextSetRGBStrokeColor( cxt, 1.0f,1.0f,1.0f,0.3f);
	CGContextSetLineWidth( cxt, 5.0f );
	CGContextStrokePath( cxt );
	
	CGContextMoveToPoint( cxt, 0.0f, -size/2.0f);
	CGContextAddLineToPoint( cxt, size+size/2.0f, size);
	CGContextStrokePath( cxt );
}

static void stripePatternInfoRelease( void *info )
{
	free( info );
}

static const CGPatternCallbacks stripePatternCallbacks = {0, &drawStripePattern, &stripePatternInfoRelease };

void drawStripePatternInContextWithPhase( CGContextRef cxt, CGSize phase, CGRect aRect, float size )
{
	CGContextSaveGState( cxt ); {
		float *sizePointer;
		sizePointer = malloc( sizeof(float) );
		*sizePointer = size;
		CGPatternRef stripePattern = CGPatternCreate(sizePointer, CGRectMake(0.0f,0.0f, *sizePointer, *sizePointer), CGAffineTransformMake(1,0,0, 1,0,0), *sizePointer, *sizePointer, kCGPatternTilingConstantSpacingMinimalDistortion, true, &stripePatternCallbacks );
		CGColorSpaceRef stripeColorSpace = CGColorSpaceCreatePattern(NULL);
		CGContextSetFillColorSpace( cxt, stripeColorSpace );
		CGColorSpaceRelease( stripeColorSpace );
		
		float alpha = 1.0f;
		CGContextSetFillPattern( cxt, stripePattern, &alpha );
		CGContextSetPatternPhase( cxt, phase );
		CGContextFillRect( cxt, aRect );
		CGPatternRelease( stripePattern );
	} CGContextRestoreGState( cxt );
}