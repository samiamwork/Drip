//
//  ScrollingSketchView.m
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ScrollingSketchView.h"


@implementation ScrollingSketchView

#define IS_HORIZONTAL_SCROLLER ( [_canvas size].width > [self bounds].size.width - (([_canvas size].height > [self bounds].size.height)?[NSScroller scrollerWidth]:0.0f) )

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
		
		_currentBrush = nil;
		_brushCursor = nil;
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

- (void)drawRect:(NSRect)rect {
	NSRect bounds = [self bounds];
	[[NSColor grayColor] set];
	NSRectFill(bounds);
	
	if( _canvas == nil )
		return;
	
	NSRect canvasRect = NSMakeRect(0.0f,0.0f,[_canvas size].width,[_canvas size].height);
	NSRect drawRect = rect;
	drawRect.origin.x -= _canvasOrigin.x;
	drawRect.origin.y -= _canvasOrigin.y;
	
	NSRect canvasDrawRect = NSIntersectionRect(canvasRect,drawRect);
	if( NSIsEmptyRect(canvasDrawRect) )
		return;
	
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(cxt);
	CGContextTranslateCTM(cxt,_canvasOrigin.x,_canvasOrigin.y);
	[_canvas drawRect:canvasDrawRect];
	CGContextRestoreGState(cxt);
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	_lastMousePoint = (PressurePoint){clickPoint.x, clickPoint.y, [theEvent pressure]};
	_lastMousePoint.x -= _canvasOrigin.x;
	_lastMousePoint.y -= _canvasOrigin.y;
	
	NSRect drawnRect = [_currentBrush renderPointAt:_lastMousePoint onLayer:[_canvas currentLayer]];
	drawnRect.origin.x += _canvasOrigin.x;
	drawnRect.origin.y += _canvasOrigin.y;
	
	[[_canvas document] updateChangeCount:NSChangeDone];
	
	[self setNeedsDisplayInRect:drawnRect];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSPoint newPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	newPoint.x -= _canvasOrigin.x;
	newPoint.y -= _canvasOrigin.y;
	float newPressure = [theEvent pressure];
	
	PressurePoint newPressurePoint = (PressurePoint){ newPoint.x, newPoint.y, newPressure };
	NSRect drawnRect = [_currentBrush renderLineFromPoint:_lastMousePoint
												  toPoint:&newPressurePoint
												  onLayer:[_canvas currentLayer]];
	_lastMousePoint = newPressurePoint;
	
	drawnRect.origin.x += _canvasOrigin.x;
	drawnRect.origin.y += _canvasOrigin.y;
	[self setNeedsDisplayInRect:drawnRect];
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
	
	if( _canvas != nil ) {
		NSSize frameSize = [self frame].size;
		_canvasOrigin.x = floorf( (frameSize.width - [_canvas size].width)/2.0f);
		_canvasOrigin.y = floorf( (frameSize.height - [_canvas size].height)/2.0f) + (IS_HORIZONTAL_SCROLLER?[NSScroller scrollerWidth]:0.0f);
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
	[self addCursorRect:visibleRect cursor:_brushCursor];
}

#define IDENTITY_TRANSFORM ((NSAffineTransformStruct){1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f})
- (void)setFrame:(NSRect)frameRect
{
	NSSize oldSize = [self bounds].size;
	[super setFrame:frameRect];
	NSSize newSize = [self bounds].size;
	
	// first reposition horizontally
	if( [self visibleWidth] >= [_canvas size].width )
		_canvasOrigin.x = floorf( ([self visibleWidth] - [_canvas size].width)/2.0f);
	else {
		if( (oldSize.width - (oldSize.height<[_canvas size].height?[NSScroller scrollerWidth]:0)) >= [_canvas size].width &&
			_canvasOrigin.x + [_canvas size].width > [self visibleWidth])
			_canvasOrigin.x = 0.0f;
	}

	// then reposition vertically
	if( [self visibleHeight] >= [_canvas size].height )
		_canvasOrigin.y = floorf( ([self visibleHeight] - [_canvas size].height)/2.0f) + (IS_HORIZONTAL_SCROLLER?[NSScroller scrollerWidth]:0.0f);
	else if( [self visibleHeight] < [_canvas size].height ) {
		_canvasOrigin.y += newSize.height - oldSize.height;
		
		// in the special case that we're switching from one state to the other...
		if( (oldSize.height - (oldSize.width<[_canvas size].width?[NSScroller scrollerWidth]:0)) >= [_canvas size].height &&
			_canvasOrigin.y + [_canvas size].height > [self visibleHeight])
			_canvasOrigin.y = [self visibleHeight]-[_canvas size].height + (IS_HORIZONTAL_SCROLLER?[NSScroller scrollerWidth]:0.0f);
	}
	
	[self redoScrollers];
}

#pragma mark Scrollers

- (float)visibleHeight
{
	if( [_canvas size].width > [self bounds].size.width - (([_canvas size].height > [self bounds].size.height)?[NSScroller scrollerWidth]:0.0f) )
		return [self bounds].size.height-[NSScroller scrollerWidth];
	
	return [self bounds].size.height;
}

- (void)updateVerticalScroller
{
	float knobSize = [self visibleHeight]/[_canvas size].height;
	float position = (-_canvasOrigin.y)/([_canvas size].height-[self visibleHeight]);
	
	[_verticalScroller setFloatValue:(1.0f-position) knobProportion:knobSize]; 
}

- (void)verticalScrollerClicked:(id)sender
{
	switch( [sender hitPart] ) {
		case NSScrollerKnob:
		case NSScrollerKnobSlot:
			_canvasOrigin.y = -roundf((1.0f-[sender floatValue])*([_canvas size].height-[self visibleHeight]));
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
	_canvasOrigin.y = -roundf((1.0f-[_verticalScroller floatValue])*([_canvas size].height-[self visibleHeight]));
	
	[self setNeedsDisplay:YES];
}

- (float)visibleWidth
{
	if( [_canvas size].height > [self bounds].size.height - (([_canvas size].width > [self bounds].size.width)?[NSScroller scrollerWidth]:0.0f) )
		return [self bounds].size.width-[NSScroller scrollerWidth];
	
	return [self bounds].size.width;
}

- (void)updateHorizontalScroller
{
	float knobSize = [self visibleWidth]/[_canvas size].width;
	float position = (-_canvasOrigin.x)/([_canvas size].width-[self visibleWidth]);

	[_horizontalScroller setFloatValue:position knobProportion:knobSize]; 
}

- (void)horizontalScrollerClicked:(id)sender
{
	switch( [sender hitPart] ) {
		case NSScrollerKnob:
		case NSScrollerKnobSlot:
			_canvasOrigin.x = -roundf([sender floatValue]*([_canvas size].width-[self visibleWidth]));
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
	_canvasOrigin.x = -roundf([_horizontalScroller floatValue]*([_canvas size].width-[self visibleWidth]));
	
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
		[_horizontalScroller setFrame:NSMakeRect(0.0f,0.0f,boundSize.width-[NSScroller scrollerWidth],[NSScroller scrollerWidth])];
		[_verticalScroller setFrame:NSMakeRect(boundSize.width-[NSScroller scrollerWidth],
											   [NSScroller scrollerWidth],
											   [NSScroller scrollerWidth],
											   boundSize.height-[NSScroller scrollerWidth])];
		[_cornerView setFrame:NSMakeRect([_verticalScroller frame].origin.x,
										 [_horizontalScroller frame].origin.y,
										 [NSScroller scrollerWidth],[NSScroller scrollerWidth])];
		[self addSubview:_cornerView];
		
		[self updateVerticalScroller];
		[self updateHorizontalScroller];
	} else if( [_verticalScroller superview] == self ) {
		[_verticalScroller setFrame:NSMakeRect(boundSize.width-[NSScroller scrollerWidth],0.0f,[NSScroller scrollerWidth],boundSize.height)];
		[_cornerView removeFromSuperview];
		
		[self updateVerticalScroller];
	} else if( [_horizontalScroller superview] == self ) {
		[_horizontalScroller setFrame:NSMakeRect(0.0f,0.0f,boundSize.width,[NSScroller scrollerWidth])];
		[_cornerView removeFromSuperview];
		
		[self updateHorizontalScroller];
	}
	
}

@end
