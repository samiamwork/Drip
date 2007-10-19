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
	
	NSImage *theImage = nil;
	if( [[self cell] isHighlighted] )
		theImage = [self alternateImage];
	else
		theImage = [self image];
	
	if( !theImage )
		return;
	
	NSSize imageSize = [theImage size];
	NSRect bounds = [self bounds];
	[theImage drawAtPoint:NSMakePoint(floorf((bounds.size.width-imageSize.width)/2.0f), floorf((bounds.size.height-imageSize.height)/2.0f)) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
}

@end
