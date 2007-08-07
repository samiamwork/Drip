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
	NSPoint _lastMousePoint;
	float _lastMousePressure;
}

- (void)setCanvas:(Canvas *)newCanvas;
- (Canvas *)canvas;

- (void)updateVerticalScroller;
- (void)updateHorizontalScroller;
- (void)redoScrollers;
- (float)visibleWidth;
- (float)visibleHeight;
@end
