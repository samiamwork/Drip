//
//  SketchView.m
//  Drip
//
//  Created by Nur Monson on 12/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "SketchView.h"
#import "DripInspectors.h"
#import "CheckerPattern.h"

NSString *const DripPenEnteredNotification = @"DripPenEnteredNotification";

@implementation SketchView

- (id)initWithFrame:(NSRect)frame {
	if( (self = [super initWithFrame:frame]) ) {
		_artist = nil;
		_canvas = nil;
		_zoom = 1.0f;		
		
		_brushCursor = nil;
		_isPanning = NO;
	}

	return self;
}

- (void)dealloc
{
	[_canvas release];
	[_artist release];
	[_brushCursor release];
	
	[super dealloc];
}

#define SCALE_RECT(a,z) NSMakeRect(a.origin.x*z,a.origin.y*z,a.size.width*z,a.size.height*z)
#define DESCALE_RECT(a,z) NSMakeRect(a.origin.x/z,a.origin.y/z,a.size.width/z,a.size.height/z)

- (void)invalidateCanvasRect:(NSRect)invalidCanvasRect
{
	invalidCanvasRect = SCALE_RECT(invalidCanvasRect,_zoom);
	invalidCanvasRect = NSIntegralRect(invalidCanvasRect);
	// enlarge rect by one too compensate for any rounding error
	invalidCanvasRect = NSInsetRect(invalidCanvasRect, -1.0f, -1.0f);
	[self setNeedsDisplayInRect:invalidCanvasRect];
}

// Need to disable this while playing back
- (void)invalidateCanvasRectForUndo:(NSRect)invalidCanvasRect
{
	[[[[self window] undoManager] prepareWithInvocationTarget:self] invalidateCanvasRectForUndo:invalidCanvasRect];
	[self invalidateCanvasRect:invalidCanvasRect];
}

- (void)drawMinimalRect:(NSRect)rect
{
	NSRect canvasRect = NSMakeRect(0.0f,0.0f,[_canvas size].width,[_canvas size].height);
	NSRect drawRect = rect;
	drawRect = DESCALE_RECT(drawRect,_zoom);
	
	NSRect canvasDrawRect = NSIntersectionRect(canvasRect,drawRect);
	if( NSIsEmptyRect(canvasDrawRect) )
		return;
	
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(cxt);
	NSAffineTransform *tempTransform = [NSAffineTransform transform];
	[tempTransform scaleXBy:_zoom yBy:_zoom];
	[tempTransform concat];
	canvasDrawRect = NSIntegralRect(canvasDrawRect);
	
	CGContextSetInterpolationQuality(cxt, kCGInterpolationNone );
	drawCheckerPatternInContextWithPhase( cxt, CGSizeMake(0.0f,0.0f), *(CGRect *)&canvasDrawRect, 10.0f );
	[_canvas drawRect:canvasDrawRect];
	CGContextRestoreGState(cxt);
}

- (void)drawRect:(NSRect)rect {
	if( _canvas == nil )
		return;
	//NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
	NSRect *rectsToDraw = NULL;
	int rectCount;
	[self getRectsBeingDrawn:(const NSRect **)&rectsToDraw count:&rectCount];
	int i;
	for( i=0; i < rectCount; i++ )
		[self drawMinimalRect:rectsToDraw[i]];
	//NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
	
	//printf("took %.05fs\n", (float)(end-start));
}

- (BOOL)preservesContentDuringLiveResize
{
	return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{	
	NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	PressurePoint theMousePoint = (PressurePoint){clickPoint.x, clickPoint.y, [theEvent pressure]};
	theMousePoint.x /= _zoom;
	theMousePoint.y /= _zoom;
	
	
	if( _panningMode ) {
		_isPanning = YES;
		_lastDragPoint = [theEvent locationInWindow];
		return;
	}
	
	if( [_canvas isPlayingBack] )
		return;
	
	NSRect drawnRect = [_canvas beginStrokeAtPoint:theMousePoint withArtist:_artist];
	
	[[_canvas document] updateChangeCount:NSChangeDone];
	
	[self invalidateCanvasRect:drawnRect];
}

- (void)mouseDragged:(NSEvent *)theEvent
{	
	NSPoint newPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	PressurePoint newPressurePoint = (PressurePoint){ newPoint.x, newPoint.y, [theEvent pressure] };
	newPressurePoint.x /= _zoom;
	newPressurePoint.y /= _zoom;
	
	if( _panningMode ) {
		
		if( ![[self superview] isKindOfClass:[NSClipView class]] )
			return;
		
		newPoint = [theEvent locationInWindow];
		NSPoint scrollPoint = [self visibleRect].origin;
		
		scrollPoint.y -= newPoint.y - _lastDragPoint.y;
		scrollPoint.x -= newPoint.x - _lastDragPoint.x;
		[self scrollPoint:scrollPoint];
		
		_lastDragPoint = newPoint;
		return;
	}
	
	if( [_canvas isPlayingBack] )
		return;
	
	NSRect drawnRect = [_canvas continueStrokeAtPoint:newPressurePoint withArtist:_artist];
	
	[self invalidateCanvasRect:drawnRect];
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if( _panningMode ) {
		_isPanning = NO;
		[self resetCursorRects];
		return;
	} else {
		NSRect strokeRect = [_canvas endStrokeWithArtist:_artist];
		[[_canvas currentLayer] updateThumbnail];
		[[DripInspectors sharedController] layersUpdated];
		[[[[self window] undoManager] prepareWithInvocationTarget:self] invalidateCanvasRectForUndo:strokeRect];
	}
	
}

- (void)tabletProximity:(NSEvent *)theEvent
{
	if( [theEvent type] != NSTabletProximity )
		return;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:DripPenEnteredNotification object:nil userInfo:[NSDictionary dictionaryWithObject:theEvent forKey:@"event"]];
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

- (void)setArtist:(Artist *)newArtist
{
	if( newArtist == _artist )
		return;

	[_artist release];
	_artist = [newArtist retain];
	[self rebuildBrushCursor];
}
- (Artist *)artist
{
	return _artist;
}

- (void)setCanvas:(Canvas *)newCanvas
{
	if( newCanvas == _canvas )
		return;
	
	[_canvas release];
	_canvas = [newCanvas retain];
	
	_zoom = 1.0f;
	_canvasSize = [_canvas size];
	if( _canvas != nil ) {
		NSRect frame = [self frame];
		frame.size = _canvasSize;
		[self setFrame:frame];
	}

}
- (Canvas *)canvas
{
	return _canvas;
}

- (void)setZoom:(float)newZoom
{
	if( newZoom > 10.0f )
		newZoom = 10.0f;
	else if( newZoom < 0.1f )
		newZoom = 0.1f;
	
	if( newZoom == _zoom )
		return;
	
	_zoom = newZoom;
	_canvasSize.width = floorf([_canvas size].width*_zoom);
	_canvasSize.height = floorf([_canvas size].height*_zoom);
	[self rebuildBrushCursor];
	
	NSRect frame = [self frame];
	frame.size = _canvasSize;
	NSView *superview = [self superview];
	if( [superview isKindOfClass:[NSClipView class]] ) {
		NSSize clipSize = [superview frame].size;
		NSRect oldDocFrame = [self frame];
		NSRect oldContentBounds = [superview bounds];
		
		[self setFrameSize:frame.size];
		
		NSRect newDocFrame = [self frame];
		NSRect newContentBounds = [superview bounds];
		
		if( newDocFrame.size.width < clipSize.width && newDocFrame.size.height < clipSize.height ) {
			[self setNeedsDisplay:YES];
			return;
		}
		
		NSPoint newOrigin = newContentBounds.origin;
		if( newDocFrame.size.width > clipSize.width )
			newOrigin.x = roundf( ((oldContentBounds.origin.x+oldContentBounds.size.width/2.0f)/oldDocFrame.size.width)*newDocFrame.size.width - (newContentBounds.size.width/2.0f) );
		
		if( newDocFrame.size.height > clipSize.height )
			newOrigin.y = roundf( ((oldContentBounds.origin.y+oldContentBounds.size.height/2.0f)/oldDocFrame.size.height)*newDocFrame.size.height - (newContentBounds.size.height/2.0f) );
		
		[self scrollPoint:newOrigin];
	}
	
	[self setNeedsDisplay:YES];
}
- (float)zoom
{
	return _zoom;
}

- (void)rebuildBrushCursor
{
	if( _artist == nil ) {
		[_brushCursor release];
		_brushCursor = nil;
		[self resetCursorRects];
		return;
	}
	
	float brushSize = [[_artist currentBrush] size]*_zoom;
	if( brushSize < 2.0f )
		brushSize = 2.0f;
	int cursorSize = (int)ceilf(brushSize+2.0f);
	if( !(cursorSize & 1) )
		cursorSize++;
	
	NSImage *brushImage = [[NSImage alloc] initWithSize:NSMakeSize((float)cursorSize,(float)cursorSize)];
	[brushImage lockFocus];
	[[NSColor colorWithCalibratedWhite:0.0f alpha:0.7f] setStroke];
	NSRect outerRect = NSMakeRect((float)((cursorSize-1)/2)+1.0f-brushSize/2.0f, (float)((cursorSize-1)/2)+1.0f-brushSize/2.0f, brushSize, brushSize);
	NSBezierPath *outerCircle = [NSBezierPath bezierPathWithOvalInRect:outerRect];
	[outerCircle setLineWidth:1.0f];
	[outerCircle stroke];
	
	[[NSColor colorWithCalibratedWhite:1.0f alpha:0.7f] setStroke];
	NSBezierPath *innerCircle = [NSBezierPath bezierPathWithOvalInRect:NSInsetRect(outerRect,1.0f,1.0f)];
	[innerCircle setLineWidth:1.0f];
	[innerCircle stroke];
	[brushImage unlockFocus];
	[_brushCursor release];
	_brushCursor = [[NSCursor alloc] initWithImage:brushImage hotSpot:NSMakePoint((float)((cursorSize-1)/2)+1.0f,(float)((cursorSize-1)/2)+1.0f)];
	
	[self resetCursorRects];
}

- (void)resetCursorRects
{
	[[self window] invalidateCursorRectsForView:self];
	[self discardCursorRects];
	
	if( _brushCursor == nil ) {
		[self addCursorRect:[self visibleRect] cursor:[NSCursor arrowCursor]];
		return;
	}
		
	NSCursor *aCursor = _brushCursor;
	if( _panningMode )
		aCursor = _isPanning ? [NSCursor closedHandCursor] : [NSCursor openHandCursor];
	[self addCursorRect:[self visibleRect] cursor:aCursor];
}

@end
