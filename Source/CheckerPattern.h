/*
 *  CheckerPattern.h
 *  Drip
 *
 *  Created by Nur Monson on 10/12/07.
 *  Copyright 2007 theidiotproject. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

// I have no clue why, but if the size argument is in second argument
// the pattern will not draw for paintLayer thumbnails. It works as
// the last argument. Compiler bug?
void drawCheckerPatternInContextWithPhase( const CGContextRef cxt, const CGSize phase, const CGRect aRect, const float size );
void drawStripePattern( void *info, CGContextRef cxt );
void drawStripePatternInContextWithPhase( CGContextRef cxt, CGSize phase, CGRect aRect, float size );
