//
//  CenteredClipView.m
//  centeredScrollView
//
//  Created by Nur Monson on 12/28/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "CenteredClipView.h"


@implementation CenteredClipView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}
/*
- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
}
*/
- (void)centerDocument
{
	NSRect docFrame = [[self documentView] frame];
	NSRect clipBounds = [self bounds];
	
	if( docFrame.size.width < clipBounds.size.width )
		clipBounds.origin.x = roundf( (docFrame.size.width-clipBounds.size.width)/2.0f );
	
	if( docFrame.size.height < clipBounds.size.height )
		clipBounds.origin.y = roundf( (docFrame.size.height-clipBounds.size.height)/2.0f );
	
	[self scrollToPoint:clipBounds.origin];
}

- (NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin
{
	NSRect docFrame = [[self documentView] frame];
	NSRect clipBounds = [self bounds];
	NSPoint newOrigin = proposedNewOrigin;
	float maxX = docFrame.size.width - clipBounds.size.width;
	float maxY = docFrame.size.height - clipBounds.size.height;
	
	if( docFrame.size.width < clipBounds.size.width )
		newOrigin.x = roundf( maxX/2.0f );
	else
		newOrigin.x = roundf( MAX(0,MIN(newOrigin.x,maxX)) );
	
	if( docFrame.size.height < clipBounds.size.height )
		newOrigin.y = roundf( maxY/2.0f );
	else
		newOrigin.y = roundf( MAX(0,MIN(newOrigin.y,maxY)) );

	return newOrigin;
}

- (void)viewBoundsChanged:(NSNotification *)aNotification
{
	[super viewBoundsChanged:aNotification];
	[self centerDocument];
}

- (void)viewFrameChanged:(NSNotification *)aNotification
{
	[super viewFrameChanged:aNotification];
	[self centerDocument];
}
- (void)setFrame:(NSRect)newFrame
{
	[super setFrame:newFrame];
	[self centerDocument];
}

- (void)setFrameOrigin:(NSPoint)newOrigin
{
	[super setFrameOrigin:newOrigin];
	[self centerDocument];
}

- (void)setFrameSize:(NSSize)newSize
{
	NSSize oldSize;
	[super setFrameSize:newSize];
	
	NSView *documentView = [self documentView];
	if( documentView != nil )
		[documentView resizeWithOldSuperviewSize:oldSize];
	
	[self centerDocument];
}

- (void)setFrameRotation:(float)newAngle
{
	[super setFrameRotation:newAngle];
	[self centerDocument];
}

@end
