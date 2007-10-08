//
//  CleanColorWell.m
//  Drip
//
//  Created by Nur Monson on 10/7/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "CleanColorWell.h"

@implementation CleanColorWell

- (void)drawRect:(NSRect)aRect
{
	NSRect bounds = [self bounds];
	[[self color] setFill];
	NSRectFill( bounds );
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];

	NSRect tinyRect = NSMakeRect(5.0f,5.0f,5.0f,5.0f);
	NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:tinyRect];
	CGContextSetRGBStrokeColor( cxt, 0.6f,0.6f,0.6f, 1.0f);
	[circle setLineWidth:3.0f];
	[circle stroke];
	[[NSColor redColor] setFill];
	[circle fill];
	
	CGContextSaveGState( cxt );
	CGContextTranslateCTM( cxt, 6.0f, 0.0f );
	[circle stroke];
	[[NSColor greenColor] setFill];
	[circle fill];
	
	CGContextTranslateCTM( cxt, 6.0f, 0.0f );
	[circle stroke];
	[[NSColor blueColor] setFill];
	[circle fill];
	
	CGContextRestoreGState( cxt );
	[[NSColor colorWithCalibratedWhite:0.6f alpha:1.0f] setStroke];
	NSRect insetRect = NSInsetRect(bounds,0.5f,0.5f);
	CGContextStrokeRectWithWidth(cxt, *(CGRect *)&insetRect, 1.0f);
}

@end
