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
	[[self color] set];
	NSRectFill(aRect);
	[[NSColor colorWithCalibratedWhite:0.6f alpha:1.0f] setStroke];
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	NSRect insetRect = NSInsetRect(aRect,0.5f,0.5f);
	CGContextStrokeRectWithWidth(cxt, *(CGRect *)&insetRect, 1.0f);
}

@end
