//
//  ColoredView.m
//  Drip
//
//  Created by Nur Monson on 10/7/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ColoredView.h"


@implementation ColoredView
- (id)init
{
	if( (self = [super init]) ) {
		_color = [[NSColor colorWithCalibratedWhite:232.0f/255.0f alpha:1.0f] retain];
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if( (self = [super initWithCoder:decoder]) ) {
		_color = [[NSColor colorWithCalibratedWhite:232.0f/255.0f alpha:1.0f] retain];
	}
	
	return self;
}

- (id)initWithFrame:(NSRect)frame
{
	if( (self = [super initWithFrame:frame]) ) {
		_color = [[NSColor colorWithCalibratedWhite:232.0f/255.0f alpha:1.0f] retain];
	}

	return self;
}

- (void)dealloc
{
	[_color release];

	[super dealloc];
}

- (NSColor *)color
{
	return _color;
}
- (void)setColor:(NSColor *)aColor
{
	if( aColor = _color )
		return;
	
	[_color release];
	_color = [aColor retain];
}

- (void)drawRect:(NSRect)aRect {
	[_color setFill];
	NSRectFill( aRect );
}

@end
