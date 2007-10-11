//
//  FramedImageCell.m
//  Drip
//
//  Created by Nur Monson on 10/11/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "FramedImageCell.h"


@implementation FramedImageCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSImage *theImage = [self objectValue];
	if( !theImage )
		return;
	
	NSSize imageSize = [theImage size];
	NSRect imageRect = NSMakeRect(cellFrame.origin.x+(cellFrame.size.width-imageSize.width)*0.5f,
								  cellFrame.origin.y+(cellFrame.size.height-imageSize.height)*0.5f,
								  imageSize.width,imageSize.height);
	imageRect = NSIntegralRect(imageRect);
	NSRect frameRect = NSInsetRect( imageRect, -0.5f, -0.5f);
	[[NSColor blackColor] setStroke];
	CGContextStrokeRectWithWidth( [[NSGraphicsContext currentContext] graphicsPort], *(CGRect *)&frameRect, 1.0f );
	[theImage setFlipped:YES];
	[theImage drawAtPoint:imageRect.origin fromRect:NSMakeRect(0.0f,0.0f,imageSize.width,imageSize.height) operation:NSCompositeSourceOver fraction:1.0f];
}

@end
