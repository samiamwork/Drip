//
//  HUDView.m
//  Drip
//
//  Created by Nur Monson on 10/21/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "HUDView.h"
#import "TIPCGUtils.h"


@implementation HUDView

- (void)drawRect:(NSRect)aRect {
	NSRect bounds = [self bounds];
	
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGMutablePathRef roundedBox = TIPCGUtilsRoundedBoxCreate( *(CGRect *)&bounds, 0.0f, 20.0f, 1.0f );
	CGContextSetRGBFillColor( cxt, 0.0f,0.0f,0.0f,0.7f );
	CGContextAddPath( cxt, roundedBox );
	CGContextFillPath( cxt );
	CGContextSetRGBStrokeColor( cxt, 0.5f,0.5f,0.5f,0.5f );
	CGContextAddPath( cxt, roundedBox );
	CGContextStrokePath( cxt );
	
	CGPathRelease( roundedBox );
}

@end
