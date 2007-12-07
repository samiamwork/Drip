//
//  CenteredScrollView.m
//  Drip
//
//  Created by Nur Monson on 12/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "CenteredScrollView.h"
#import "CenteredClipView.h"

@implementation CenteredScrollView

- (void)setDocumentView:(NSView *)aView
{
	NSView *contentView = [self contentView];
	if( [contentView class] != [CenteredClipView class] ) {
		CenteredClipView *aCenteredClipView = [[CenteredClipView alloc] initWithFrame:[contentView frame]];
		[aCenteredClipView setBackgroundColor:[(NSClipView *)contentView backgroundColor]];
		[aCenteredClipView setDrawsBackground:[(NSClipView *)contentView drawsBackground]];
		[self setContentView:aCenteredClipView];
		[aCenteredClipView release];
	}
	
	[super setDocumentView:aView];
}

@end
