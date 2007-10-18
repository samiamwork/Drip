//
//  ImageButton.m
//  Drip
//
//  Created by Nur Monson on 10/17/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ImageButton.h"


@implementation ImageButton

- (void)drawRect:(NSRect)aRect
{
	[[self image] setFlipped:YES];
	[[self alternateImage] setFlipped:YES];
	if( [[self cell] isHighlighted] )
		[[self alternateImage] drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
	else
		[[self image] drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
}

@end
