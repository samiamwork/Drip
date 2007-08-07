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
	[[NSColor whiteColor] set];
	NSRectFill(bounds);
	
	if( _currentBrush == nil )
		return;
	
	[[NSColor blackColor] setStroke];
	NSPoint center = NSMakePoint(bounds.origin.x+bounds.size.width/2.0f,bounds.origin.y+bounds.size.height/2.0f);
	NSRect outerRect = NSMakeRect(center.x-([_currentBrush size]/2.0f),
								  center.y-([_currentBrush size]/2.0f),
								  [_currentBrush size],
								  [_currentBrush size]);
	NSBezierPath *outerCircle = [NSBezierPath bezierPathWithOvalInRect:outerRect];
	[outerCircle setLineWidth:1.0f];
	[outerCircle stroke];
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
