//
//  ShelfView.m
//  Drip
//
//  Created by Nur Monson on 10/8/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ShelfView.h"


@implementation ShelfView

- (void)drawRect:(NSRect)aRect {
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetRGBFillColor( cxt, 0.2f,0.2f,0.2f,0.08f);
	CGContextFillRect( cxt, *(CGRect *)&aRect );
	CGContextSetRGBStrokeColor( cxt, 0.6f,0.6f,0.6f,1.0f);
	CGContextSetLineWidth( cxt, 1.0f );
	NSRect bounds = [self bounds];
	CGContextMoveToPoint( cxt, 0.0f, bounds.size.height-0.5f );
	CGContextAddLineToPoint( cxt, bounds.size.width, bounds.size.height-0.5f );
	CGContextStrokePath( cxt );
	
	CGContextSetRGBStrokeColor( cxt, 0.6f,0.6f,0.6f,0.5f);
	CGContextMoveToPoint( cxt, 0.0f, bounds.size.height-1.5f );
	CGContextAddLineToPoint( cxt, bounds.size.width, bounds.size.height-1.5f );
	CGContextStrokePath( cxt );
}

@end
