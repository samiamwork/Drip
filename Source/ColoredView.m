//
//  ColoredView.m
//  Drip
//
//  Created by Nur Monson on 10/7/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ColoredView.h"


@implementation ColoredView

- (void)drawRect:(NSRect)aRect {
	[[NSColor colorWithCalibratedWhite:232.0f/255.0f alpha:1.0f] setFill];
	NSRectFill( aRect );
}

@end
