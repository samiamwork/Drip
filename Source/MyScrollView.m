//
//  MyScrollView.m
//  centeredScrollView
//
//  Created by Nur Monson on 12/28/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "MyScrollView.h"


@implementation MyScrollView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)setDocumentView:(NSView *)aView
{
	NSView *contentView = [self contentView];
	if( [contentView class] != [CenteredClipView class] ) {
		CenteredClipView *aCenteredClipView = [[CenteredClipView alloc] initWithFrame:[contentView frame]];
		//[aCenteredClipView setBackgroundColor:[NSColor whiteColor]];
		[aCenteredClipView setBackgroundColor:[self backgroundColor]];
		[self setContentView:aCenteredClipView];
		[aCenteredClipView release];
	}

	[super setDocumentView:aView];

}
@end
