//
//  CenteredTextCell.m
//  Drip
//
//  Created by Nur Monson on 9/19/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "CenteredTextCell.h"


@implementation CenteredTextCell

- (NSRect)centerFrame:(NSRect)aRect
{
	NSFont *theFont = [self font];
	return NSMakeRect(aRect.origin.x,aRect.origin.y+(aRect.size.height-1)/2.0f+[theFont xHeight]/2.0f-[theFont ascender],aRect.size.width,[theFont ascender]+[theFont descender]+10.0f);
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	
	NSShadow *shadow = nil;
	NSColor *textColor = nil;
	if( [self isHighlighted] ) {
		textColor = [NSColor whiteColor];
		
		[NSGraphicsContext saveGraphicsState];
		shadow = [[NSShadow alloc] init];
		[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0f alpha:1.0f]];
		[shadow setShadowOffset:NSMakeSize(0.0f,-1.0f)];
		[shadow setShadowBlurRadius:1.0f];
		[shadow set];
	} else
		textColor = [NSColor blackColor];
	
	[self setTextColor:textColor];
	[super drawWithFrame:[self centerFrame:cellFrame] inView:controlView];
	
	if( shadow ) {
		[shadow release];
		[NSGraphicsContext restoreGraphicsState];
	}
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(int)selStart length:(int)selLength
{
	//printf("select aRect = (%.01f, %.01f), (%.01f, %.01f)\n", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
	[super selectWithFrame:[self centerFrame:aRect] inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{
	//printf("edit aRect = (%.01f, %.01f), (%.01f, %.01f)\n", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
	[super editWithFrame:aRect inView:controlView editor:textObj delegate:anObject event:theEvent];
}
@end
