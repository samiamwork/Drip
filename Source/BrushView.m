//
//  BrushView.m
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "BrushView.h"


@implementation BrushView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_currentBrush = nil;
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	NSRect bounds = [self bounds];
	//[[NSColor whiteColor] set];
	//NSRectFill(bounds);
	
	if( _currentBrush == nil )
		return;
	
	NSPoint center = NSMakePoint(roundf(bounds.origin.x+bounds.size.width/2.0f),roundf(bounds.origin.y+bounds.size.height/2.0f));
	[[NSColor blackColor] set];
	[_currentBrush drawDabAtPoint:center];
	/*
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetRGBStrokeColor( cxt, 0.6f,0.6f,0.6f,1.0f );
	NSRect insetRect = NSInsetRect(bounds,0.5f,0.5f);
	CGContextStrokeRectWithWidth(cxt, *(CGRect *)&insetRect, 1.0f);
	 */
}

- (Brush *)brush
{
	return _currentBrush;
}
- (void)setBrush:(Brush *)newBrush
{
	if( newBrush == _currentBrush )
		return;
	
	[_currentBrush release];
	_currentBrush = [newBrush retain];
	[self setNeedsDisplay:YES];
}

@end
