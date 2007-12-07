//
//  SketchView.h
//  Drip
//
//  Created by Nur Monson on 12/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Canvas.h"
#import "Brush.h"
#import "Artist.h"

extern NSString *const DripPenEnteredNotification;

@interface SketchView : NSView {
	Artist *_artist;
	
	Canvas *_canvas;
	float _zoom;
	NSSize _canvasSize;
	
	NSCursor *_brushCursor;
	BOOL _panningMode;
	BOOL _isPanning;
	NSPoint _lastDragPoint;
}

- (void)setCanvas:(Canvas *)newCanvas;
- (Canvas *)canvas;
- (void)setArtist:(Artist *)newArtist;
- (Artist *)artist;
- (void)setZoom:(float)newZoom;
- (float)zoom;

- (void)rebuildBrushCursor;
- (void)invalidateCanvasRect:(NSRect)invalidCanvasRect;

@end
