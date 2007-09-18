//
//  ScrollingSketchView.m
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ScrollingSketchView.h"
#import "DripInspectors.h"

@implementation ScrollingSketchView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_verticalScroller = [[NSScroller alloc] initWithFrame:NSMakeRect(frame.size.width-[NSScroller scrollerWidth],
																		 [NSScroller scrollerWidth],
																		 [NSScroller scrollerWidth],
																		 frame.size.height-[NSScroller scrollerWidth])];
		[_verticalScroller setAutoresizingMask:NSViewMinXMargin|NSViewHeightSizable];
		[_verticalScroller setTarget:self];
		[_verticalScroller setAction:@selector(verticalScrollerClicked:)];
		[_verticalScroller setEnabled:YES];
		
		_horizontalScroller = [[NSScroller alloc] initWithFrame:NSMakeRect(0.0f,0.0f,
																		   frame.size.width-[NSScroller scrollerWidth],
																		   [NSScroller scrollerWidth])];
		[_horizontalScroller setAutoresizingMask:NSViewMaxYMargin|NSViewWidthSizable];
		[_horizontalScroller setTarget:self];
		[_horizontalScroller setAction:@selector(horizontalScrollerClicked:)];
		[_horizontalScroller setEnabled:YES];
		_cornerView = [[NSView alloc] initWithFrame:NSMakeRect([_verticalScroller frame].origin.x,
															   [_horizontalScroller frame].origin.y,
															   [NSScroller scrollerWidth],[NSScroller scrollerWidth])];
		[_cornerView setAutoresizingMask:NSViewMinXMargin|NSViewMaxYMargin];
		
		_currentBrush = [[Brush alloc] init];
		_canvas = nil;
		_canvasOrigin = NSZeroPoint;
		_zoom = 2.0f;
		
		_currentBrush = nil;
		_brushCursor = nil;
		_isPanning = NO;
		[self setBrush:[[Brush alloc] init]];
    }
    return self;
}

- (void)dealloc
{
	[_horizontalScroller release];
	[_verticalScroller release];
	[_cornerView release];
	
	[_canvas release];
	[_currentBrush release];
	
	[super dealloc];
}

#define SCALE_RECT(a,z) NSMakeRect(a.origin.x*z,a.origin.y*z,a.size.width*z,a.size.height*z)
#define DESCALE_RECT(a,z) NSMakeRect(a.origin.x/z,a.origin.y/z,a.size.width/z,a.size.height/z)

- (void)invalidateCanvasRect:(NSRect)invalidCanvasRect
{
	invalidCanvasRect.origin.x += _canvasOrigin.x/_zoom;
	invalidCanvasRect.origin.y = [_canvas size].height - (invalidCanvasRect.origin.y+invalidCanvasRect.size.height) + _canvasOrigin.y/_zoom;

	invalidCanvasRect = SCALE_RECT(invalidCanvasRect,_zoom);
	invalidCanvasRect = NSIntegralRect(invalidCanvasRect);
	invalidCanvasRect.origin.x -= 1.0f;
	invalidCanvasRect.origin.y -= 1.0f;
	invalidCanvasRect.size.width += 2.0f;
	invalidCanvasRect.size.width += 2.0f;
	[self setNeedsDisplayInRect:invalidCanvasRect];
}

- (void)drawRect:(NSRect)rect {
	NSRect bounds = [self bounds];
	[[NSColor grayColor] set];
	NSRectFill(bounds);
	
	if( _canvas == nil )
		return;
	
	NSRect canvasRect = NSMakeRect(0.0f,0.0f,[_canvas size].width,[_canvas size].height);
	NSRect drawRect = rect;
	drawRect.origin.x -= _canvasOrigin.x;
	drawRect.origin.y = _canvasSize.height-(drawRect.origin.y-_canvasOrigin.y)-drawRect.size.height;
	drawRect = DESCALE_RECT(drawRect,_zoom);
	
	NSRect canvasDrawRect = NSIntersectionRect(canvasRect,drawRect);
	if( NSIsEmptyRect(canvasDrawRect) )
		return;
	
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(cxt);
	NSAffineTransform *tempTransform = [NSAffineTransform transform];
	[tempTransform translateXBy:_canvasOrigin.x yBy:_canvasOrigin.y+[_canvas size].height*_zoom];
	[tempTransform scaleXBy:_zoom yBy:-1.0f*_zoom];
	[tempTransform concat];
	canvasDrawRect = NSIntegralRect(canvasDrawRect);
	[_canvas drawRect:canvasDrawRect];
	CGContextRestoreGState(cxt);
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}
- (BOOL)isFlipped;
{
	return YES;
}
- (void)mouseDown:(NSEvent *)theEvent
{
	if( [_canvas isPlayingBack] )
		return;
	
	NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	PressurePoint theMousePoint = (PressurePoint){clickPoint.x, clickPoint.y, [theEvent pressure]};
	theMousePoint.x = (theMousePoint.x - _canvasOrigin.x);
	theMousePoint.y = _canvasSize.height-(theMousePoint.y-_canvasOrigin.y);
	theMousePoint.x /= _zoom;
	theMousePoint.y /= _zoom;
	
	
	if( _panningMode ) {
		_isPanning = YES;
		_lastDragPoint = clickPoint;
		[self resetCursorRects];
		return;
	}
	
	NSRect drawnRect = [_canvas beginStrokeAtPoint:theMousePoint withBrush:_currentBrush];
	
	[[_canvas document] updateChangeCount:NSChangeDone];
	
	[self invalidateCanvasRect:drawnRect];
}

- (void)boundsCheckCanvas
{
	if( [_verticalScroller superview] == self ) {
		if( _canvasOrigin.y + [_canvas size].height*_zoom < [self bounds].size.height ) {
			_canvasOrigin.y = [self bounds].size.height-[_canvas size].height*_zoom;
		} else if( _canvasOrigin.y > 0.0f ) {
			_canvasOrigin.y = 0.0f;
		}
	}
	
	if( [_horizontalScroller superview] == self ) {
		if( _canvasOrigin.x + [_canvas size].width*_zoom < [self visibleWidth] )
			_canvasOrigin.x = [self visibleWidth]-[_canvas size].width*_zoom;
		else if( _canvasOrigin.x > 0.0f )
			_canvasOrigin.x = 0.0f;
	}
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	if( [_canvas isPlayingBack] )
		return;
	
	NSPoint newPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	PressurePoint newPressurePoint = (PressurePoint){ newPoint.x, newPoint.y, [theEvent pressure] };
	newPressurePoint.x -= _canvasOrigin.x;
	newPressurePoint.y = _canvasSize.height-(newPressurePoint.y-_canvasOrigin.y);
	newPressurePoint.x /= _zoom;
	newPressurePoint.y /= _zoom;
	
	if( _panningMode ) {
		if( [_verticalScroller superview] == self )
			_canvasOrigin.y += newPoint.y - _lastDragPoint.y;
		if( [_horizontalScroller superview] == self )
			_canvasOrigin.x += newPoint.x - _lastDragPoint.x;
		
		_lastDragPoint = newPoint;
		[self boundsCheckCanvas];
		
		[self updateVerticalScroller];
		[self updateHorizontalScroller];
		
		[self setNeedsDisplay:YES];
		return;
	}
	
	NSRect drawnRect = [_canvas continueStrokeAtPoint:newPressurePoint withBrush:_currentBrush];
	
	[self invalidateCanvasRect:drawnRect];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if( _panningMode ) {
		_isPanning = NO;
		[self resetCursorRects];
		return;
	} else {
		[_currentBrush endStroke];
		[[_canvas currentLayer] updateThumbnail];
		[[DripInspectors sharedController] layersUpdated];
	}
	
}

- (void)tabletProximity:(NSEvent *)theEvent
{
	if( ![theEvent isEnteringProximity] )
		return;
	
	switch( [theEvent pointingDeviceType] ) {
		case NSEraserPointingDevice:
			printf("eraser entered!\n");
			break;
		case NSPenPointingDevice:
			printf("pen entered!\n");
			break;
		default:
			printf("other!\n");
			break;
	}
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
	if( ![[theEvent charactersIgnoringModifiers] isEqualToString:@" "] ) {
		[super keyDown:theEvent];
		return;
	}
	
	if( [theEvent isARepeat] )
		return;
	
	_panningMode = YES;
	[self resetCursorRects];
}

- (void)keyUp:(NSEvent *)theEvent
{
	if( ![[theEvent charactersIgnoringModifiers]  isEqualToString:@" "] ) {
		[super keyUp:theEvent];
		return;
	}
	
	[self resetCursorRects];
	_panningMode = NO;
}

- (void)setBrush:(Brush *)newBrush
{
	if( newBrush == _currentBrush )
		return;
	
	[_currentBrush release];
	_currentBrush = [newBrush retain];
	[self rebuildBrushCursor];
}
- (Brush *)brush
{
	return _currentBrush;
}

- (void)setCanvas:(Canvas *)newCanvas
{
	if( newCanvas == _canvas )
		return;
	
	[_canvas release];
	_canvas = [newCanvas retain];
	
	_canvasSize = [_canvas size];
	_canvasSize.width *= _zoom;
	_canvasSize.height *= _zoom;
	if( _canvas != nil ) {
		NSSize frameSize = [self frame].size;
		_canvasOrigin.x = floorf( (frameSize.width - _canvasSize.width)/2.0f);
		_canvasOrigin.y = floorf( (frameSize.height - _canvasSize.height)/2.0f);
	}
	
	[self redoScrollers];
}
- (Canvas *)canvas
{
	return _canvas;
}

- (void)rebuildBrushCursor
{
	if( _currentBrush == nil ) {
		[_brushCursor release];
		_brushCursor = nil;
		[self resetCursorRects];
		return;
	}
	
	float brushSize = [_currentBrush size];
	NSImage *brushImage = [[NSImage alloc] initWithSize:NSMakeSize(brushSize+2.0f,brushSize+2.0f)];
	[brushImage lockFocus];
	[[NSColor colorWithCalibratedWhite:0.0f alpha:0.7f] setStroke];
	NSRect outerRect = NSMakeRect(1.0f, 1.0f, brushSize, brushSize);
	NSBezierPath *outerCircle = [NSBezierPath bezierPathWithOvalInRect:outerRect];
	[outerCircle setLineWidth:1.0f];
	//float pattern[2] = {2.0f, 2.0f};
	//[outerCircle setLineDash:pattern count:2 phase:0.0f];
	[outerCircle stroke];
	
	[[NSColor colorWithCalibratedWhite:1.0f alpha:0.7f] setStroke];
	//[outerCircle setLineDash:pattern count:2 phase:2.0f];
	//[outerCircle stroke];
	NSBezierPath *innerCircle = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(outerRect,1.0f,1.0f)];
	[innerCircle setLineWidth:1.0f];
	[innerCircle stroke];
	[brushImage unlockFocus];
	[_brushCursor release];
	_brushCursor = [[NSCursor alloc] initWithImage:brushImage hotSpot:NSMakePoint(brushSize/2.0f+1.0f,brushSize/2.0f+1.0f)];
	
	[self resetCursorRects];
}

- (void)resetCursorRects
{
	[[self window] invalidateCursorRectsForView:self];
	[self discardCursorRects];
	
	if( _brushCursor == nil ) {
		[self addCursorRect:[self bounds] cursor:[NSCursor arrowCursor]];
		return;
	}
		
	NSRect visibleRect = [self bounds];
	if( [_verticalScroller superview] == self )
		visibleRect.size.width -= [NSScroller scrollerWidth];
	if( [_horizontalScroller superview] == self ) {
		visibleRect.size.height -= [NSScroller scrollerWidth];
		visibleRect.origin.y += [NSScroller scrollerWidth];
	}
	
	NSCursor *aCursor = _brushCursor;
	if( _panningMode )
		aCursor = _isPanning ? [NSCursor closedHandCursor] : [NSCursor openHandCursor];
	[self addCursorRect:visibleRect cursor:aCursor];
}

#define IDENTITY_TRANSFORM ((NSAffineTransformStruct){1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f})
- (void)setFrame:(NSRect)frameRect
{
	//NSSize oldSize = [self bounds].size;
	[super setFrame:frameRect];
	//NSSize newSize = [self bounds].size;
	
	// first reposition horizontally
	if( [self visibleWidth] >= [_canvas size].width*_zoom )
		_canvasOrigin.x = floorf( ([self visibleWidth] - [_canvas size].width*_zoom)/2.0f);

	// then reposition vertically
	
	// if the canvas does fit in the view...
	if( [self visibleHeight] >= [_canvas size].height*_zoom )
		_canvasOrigin.y = floorf( ([self visibleHeight] - [_canvas size].height*_zoom)/2.0f);
	
	[self redoScrollers];
}

#pragma mark Scrollers

- (float)visibleHeight
{
	if( [_canvas size].width*_zoom > [self bounds].size.width - (([_canvas size].height*_zoom > [self bounds].size.height)?[NSScroller scrollerWidth]:0.0f) )
		return [self bounds].size.height-[NSScroller scrollerWidth];
	
	return [self bounds].size.height;
}

- (void)updateVerticalScroller
{
	float knobSize = [self visibleHeight]/([_canvas size].height*_zoom);
	float position = (-_canvasOrigin.y)/([_canvas size].height*_zoom-[self visibleHeight]);
	
	[_verticalScroller setFloatValue:position knobProportion:knobSize];
}

- (void)verticalScrollerClicked:(id)sender
{
	switch( [sender hitPart] ) {
		case NSScrollerKnob:
		case NSScrollerKnobSlot:
			_canvasOrigin.y = -roundf([sender floatValue]*([_canvas size].height*_zoom-[self visibleHeight]));
			break;
		case NSScrollerDecrementLine:
			_canvasOrigin.y -= 1.0f;
			break;
		case NSScrollerDecrementPage:
			_canvasOrigin.y -= [self visibleHeight];
			break;
		case NSScrollerIncrementLine:
			_canvasOrigin.y += 1.0f;
			break;
		case NSScrollerIncrementPage:
			_canvasOrigin.y += [self visibleHeight];
			break;
	}
	// we let the scroller handle the bounds checking and then we read the position
	// back out
	[self updateVerticalScroller];
	_canvasOrigin.y = -roundf(([_verticalScroller floatValue])*([_canvas size].height*_zoom-[self visibleHeight]));
	
	[self setNeedsDisplay:YES];
}

- (float)visibleWidth
{
	if( [_canvas size].height*_zoom > [self bounds].size.height - (([_canvas size].width*_zoom > [self bounds].size.width)?[NSScroller scrollerWidth]:0.0f) )
		return [self bounds].size.width-[NSScroller scrollerWidth];
	
	return [self bounds].size.width;
}

- (void)updateHorizontalScroller
{
	float knobSize = [self visibleWidth]/([_canvas size].width*_zoom);
	float position = (-_canvasOrigin.x)/([_canvas size].width*_zoom-[self visibleWidth]);

	[_horizontalScroller setFloatValue:position knobProportion:knobSize]; 
}

- (void)horizontalScrollerClicked:(id)sender
{
	switch( [sender hitPart] ) {
		case NSScrollerKnob:
		case NSScrollerKnobSlot:
			_canvasOrigin.x = -roundf([sender floatValue]*([_canvas size].width*_zoom-[self visibleWidth]));
			break;
		case NSScrollerDecrementLine:
			_canvasOrigin.x += 1.0f;
			break;
		case NSScrollerDecrementPage:
			_canvasOrigin.x += [self visibleWidth];
			break;
		case NSScrollerIncrementLine:
			_canvasOrigin.x -= 1.0f;
			break;
		case NSScrollerIncrementPage:
			_canvasOrigin.x -= [self visibleWidth];
			break;
	}
	
	// we let the scroller handle the bounds checking and then we read the position
	// back out
	[self updateHorizontalScroller];
	_canvasOrigin.x = -roundf([_horizontalScroller floatValue]*([_canvas size].width*_zoom-[self visibleWidth]));
	
	[self setNeedsDisplay:YES];
}

- (void)redoScrollers
{
	if( _canvas == nil ) {
		[_verticalScroller removeFromSuperview];
		[_horizontalScroller removeFromSuperview];
		[_cornerView removeFromSuperview];
		
		return;
	}
	
	NSSize canvasSize = [_canvas size];
	canvasSize.width *= _zoom;
	canvasSize.height *= _zoom;
	NSSize boundSize = [self bounds].size;

	if( canvasSize.width <= [self visibleWidth] && [_horizontalScroller superview] == self )
		[_horizontalScroller removeFromSuperview];
	else if( canvasSize.width > [self visibleWidth] && [_horizontalScroller superview] != self)
		[self addSubview:_horizontalScroller];
	
	if( canvasSize.height <= [self visibleHeight] && [_verticalScroller superview] == self )
		[_verticalScroller removeFromSuperview];
	else if( canvasSize.height > [self visibleHeight] && [_verticalScroller superview] != self )
		[self addSubview:_verticalScroller];
	
	// set scroller frames and positions
	if( [_verticalScroller superview] == self && [_horizontalScroller superview] == self ) {
		[_horizontalScroller setFrame:NSMakeRect(0.0f, boundSize.height-[NSScroller scrollerWidth],boundSize.width-[NSScroller scrollerWidth],[NSScroller scrollerWidth])];
		[_verticalScroller setFrame:NSMakeRect(boundSize.width-[NSScroller scrollerWidth],
											   0.0f,
											   [NSScroller scrollerWidth],
											   boundSize.height-[NSScroller scrollerWidth])];
		[_cornerView setFrame:NSMakeRect([_verticalScroller frame].origin.x,
										 [_horizontalScroller frame].origin.y,
										 [NSScroller scrollerWidth],[NSScroller scrollerWidth])];
		[self addSubview:_cornerView];

		if( _canvasOrigin.y + canvasSize.height < boundSize.height-[NSScroller scrollerWidth] ) {
			_canvasOrigin.y = boundSize.height-[NSScroller scrollerWidth]-canvasSize.height;
		} else if( _canvasOrigin.y > 0.0f ) {
			_canvasOrigin.y = 0.0f;
		}
		
		if( _canvasOrigin.x + canvasSize.width < boundSize.width-[NSScroller scrollerWidth] )
			_canvasOrigin.x = boundSize.width-[NSScroller scrollerWidth]-canvasSize.width;
		else if( _canvasOrigin.x > 0.0f )
			_canvasOrigin.x = 0.0f;
		
		[self updateVerticalScroller];
		[self updateHorizontalScroller];
	} else if( [_verticalScroller superview] == self ) {
		[_verticalScroller setFrame:NSMakeRect(boundSize.width-[NSScroller scrollerWidth],0.0f,[NSScroller scrollerWidth],boundSize.height)];
		[_cornerView removeFromSuperview];
		
		if( _canvasOrigin.y + canvasSize.height < boundSize.height )
			_canvasOrigin.y = boundSize.height-canvasSize.height;
		else if( _canvasOrigin.y > 0.0f )
			_canvasOrigin.y = 0.0f;
		[self updateVerticalScroller];
	} else if( [_horizontalScroller superview] == self ) {
		[_horizontalScroller setFrame:NSMakeRect(0.0f,boundSize.height-[NSScroller scrollerWidth],boundSize.width,[NSScroller scrollerWidth])];
		[_cornerView removeFromSuperview];
		
		if( _canvasOrigin.x + [_canvas size].width < boundSize.width )
			_canvasOrigin.x = boundSize.width-canvasSize.width;
		else if( _canvasOrigin.x > 0.0f )
			_canvasOrigin.x = 0.0f;
		[self updateHorizontalScroller];
	}
	
}

@end
