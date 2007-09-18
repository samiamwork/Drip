//
//  ScrollingSketchView.h
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Canvas.h"
#import "Brush.h"

@interface ScrollingSketchView : NSView {
	NSScroller *_verticalScroller;
	NSScroller *_horizontalScroller;
	NSView *_cornerView;
	Brush *_currentBrush;
	
	Canvas *_canvas;
	NSPoint _canvasOrigin;
	float _zoom;
	NSSize _canvasSize;
	
	NSCursor *_brushCursor;
	BOOL _panningMode;
	BOOL _isPanning;
	NSPoint _lastDragPoint;
}

- (void)setCanvas:(Canvas *)newCanvas;
- (Canvas *)canvas;
- (void)setBrush:(Brush *)newBrush;
- (Brush *)brush;
- (void)setZoom:(float)newZoom;
- (float)zoom;

- (void)rebuildBrushCursor;

- (void)updateVerticalScroller;
- (void)updateHorizontalScroller;
- (void)redoScrollers;
- (float)visibleWidth;
- (float)visibleHeight;

- (void)invalidateCanvasRect:(NSRect)invalidCanvasRect;
@end
