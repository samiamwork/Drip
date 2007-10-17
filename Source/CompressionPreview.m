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
    }
    return self;
}

- (void)setImage:(NSImage *)newImage
{
	[super setImage:newImage];
	NSSize frameSize = [self frame].size;
	
	// center the image
	_imageOffset.x = roundf( (frameSize.width - [[self image] size].width)/2.0f );
	_imageOffset.y = roundf( (frameSize.height - [[self image] size].height)/2.0f );
	
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
	printf("setFrame offset: %.01f, %.01f\n", _imageOffset.x, _imageOffset.y );
}

- (void)mouseDown:(NSEvent *)theEvent
{
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

- (void)drawRect:(NSRect)rect {
	[[NSColor grayColor] setFill];
	NSRectFill( [self bounds] );
	
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState( cxt );
	//CGContextTranslateCTM( cxt, 100.0f,0.0f );
	[[self image] drawAtPoint:_imageOffset fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0f];
	CGContextRestoreGState( cxt );
}

@end
