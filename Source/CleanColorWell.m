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

	CGContextSaveGState( cxt ); {
		NSRect tinyRect = NSMakeRect(5.0f,5.0f,5.0f,5.0f);
		NSBezierPath *circle = [NSBezierPath bezierPathWithOvalInRect:tinyRect];
		NSShadow *shadow = [[NSShadow alloc] init];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.6f alpha:1.0f]];
		[shadow setShadowOffset:NSMakeSize(0.0f,-1.5f)];
		[shadow setShadowBlurRadius:1.0f];
		[shadow set];
		[shadow release];
		CGContextSetRGBStrokeColor( cxt, 0.6f,0.6f,0.6f, 1.0f);
		[circle setLineWidth:3.0f];
		[[NSColor redColor] setFill];
		[circle fill];
		
		CGContextTranslateCTM( cxt, 6.0f, 0.0f );
		[[NSColor greenColor] setFill];
		[circle fill];
		
		CGContextTranslateCTM( cxt, 6.0f, 0.0f );
		[[NSColor blueColor] setFill];
		[circle fill];
	} CGContextRestoreGState( cxt );
	[[NSColor colorWithCalibratedWhite:0.6f alpha:1.0f] setStroke];
	CGContextMoveToPoint( cxt, 0.0f,0.5f);
	CGContextAddLineToPoint( cxt, bounds.size.width,0.5f);
	CGContextSetLineWidth( cxt, 1.0f );
	CGContextStrokePath( cxt );
}

@end
