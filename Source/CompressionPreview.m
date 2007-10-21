//
//  CompressionPreview.m
//  Drip
//
//  Created by Nur Monson on 10/16/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "CompressionPreview.h"


@implementation CompressionPreview

- (id)initWithFrame:(NSRect)frame {
	if( (self = [super initWithFrame:frame]) ) {
        _imageOffset = NSZeroPoint;
		_isDragging = NO;
    }
    return self;
}

- (void)setImage:(NSImage *)newImage
{
	NSImage *oldImage = [self image];
	[super setImage:newImage];
	NSSize frameSize = [self frame].size;
	
	if( !oldImage ) {
		// center the image
		_imageOffset.x = roundf( (frameSize.width - [[self image] size].width)/2.0f );
		_imageOffset.y = roundf( (frameSize.height - [[self image] size].height)/2.0f );
	} else {
		// since we're not recentering it we need to check and make sure the new image
		// works with the new offsets.
		NSSize imageSize = [[self image] size];
		
		if( imageSize.width < frameSize.width )
			_imageOffset.x = roundf( (frameSize.width - imageSize.width)/2.0f );
		else if( _imageOffset.x+imageSize.width < frameSize.width )
			_imageOffset.x = frameSize.width-imageSize.width;
		
		if( imageSize.height < frameSize.height )
			_imageOffset.y = roundf( (frameSize.height - imageSize.height)/2.0f );
		if( _imageOffset.y+imageSize.height < frameSize.height )
			_imageOffset.y = frameSize.height-imageSize.height;
	}
	
}

- (void)setFrame:(NSRect)newFrame
{
	NSSize oldSize = [self frame].size;
	[super setFrame:newFrame];
	NSSize newSize = [self frame].size;
	
	_imageOffset.x += newSize.width - oldSize.width;
	if( _imageOffset.x > 0.0f )
		_imageOffset.x = 0.0f;
	_imageOffset.y += newSize.height - oldSize.height;
	if( _imageOffset.y > 0.0 )
		_imageOffset.y = 0.0f;
	
	if( ![self image] )
		return;
	
	// if we're smaller than the frame then we need to center the image
	if( [[self image] size].width < newSize.width )
		_imageOffset.x = roundf( (newSize.width - [[self image] size].width)/2.0f );
	if( [[self image] size].height < newSize.height )
		_imageOffset.y = roundf( (newSize.height - [[self image] size].height)/2.0f );
}

- (void)mouseDown:(NSEvent *)theEvent
{
	_isDragging = YES;
	[[self window] invalidateCursorRectsForView:self];
	_lastMousePosition = [self convertPoint:[theEvent locationInWindow] fromView:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint newMousePosition = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	NSSize imageSize = [[self image] size];
	NSSize boundsSize = [self bounds].size;
	
	if( imageSize.width > boundsSize.width ) {
		_imageOffset.x += newMousePosition.x - _lastMousePosition.x;
		if( _imageOffset.x > 0.0f )
			_imageOffset.x = 0.0f;
		if( _imageOffset.x+imageSize.width < boundsSize.width )
			_imageOffset.x = boundsSize.width-imageSize.width;
	}
	
	if( imageSize.height > boundsSize.height ) {
		_imageOffset.y += newMousePosition.y - _lastMousePosition.y;
		if( _imageOffset.y > 0.0f )
			_imageOffset.y = 0.0f;
		if( _imageOffset.y+imageSize.height < boundsSize.height )
			_imageOffset.y = boundsSize.height-imageSize.height;
	}
	
	_lastMousePosition = newMousePosition;
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	_isDragging = YES;
	[[self window] invalidateCursorRectsForView:self];
}

- (void)drawRect:(NSRect)rect {
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState( cxt );
	CGContextSetRGBFillColor( cxt, 0.6f,0.6f,0.6f,0.2f );
	CGContextFillRect( cxt, *(CGRect *)&rect );
	[[self image] drawAtPoint:_imageOffset fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
	NSRect bounds = [self bounds];
	bounds = NSInsetRect( bounds, 0.5f,0.5f );
	CGContextSetRGBFillColor( cxt, 0.6f,0.6f,0.6f,1.0f );
	CGContextStrokeRectWithWidth(cxt, *(CGRect *)&bounds, 1.0f);
	CGContextRestoreGState( cxt );
}

- (void)resetCursorRects
{
	if( _isDragging )
		[self addCursorRect:[self bounds] cursor:[NSCursor closedHandCursor]];
	else
		[self addCursorRect:[self bounds] cursor:[NSCursor openHandCursor]];
}

@end
