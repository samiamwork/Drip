//
//  Artist.h
//  Drip
//
//  Created by Nur Monson on 10/20/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BrushEraser.h"


@interface Artist : NSObject {
	Brush *_paintBrush;
	BrushEraser *_eraserBrush;
	
	// this is the current brush for the pen tip and mouse
	Brush *_currentPenTipBrush;
	// the current brush for the eraser tip
	Brush *_currentPenEndBrush;
	
	Brush **_currentBrushPtr;
	
	// the last settings returned by the getChangedBrushSettings method
	id _lastCheckedBrushSettings;
	// this artist's current color;
	NSColor *_color;
}

- (void)loadSettings;
- (void)saveSettings;
- (void)setCanvasSize:(NSSize)canvasSize;
// ONLY! called by the canvas object to check if the settings have
// changed since the last call to this method.
// This restriction prevents an Artist from being used on more
// than one canvas at a time (not a problem since there is no reason
// to do that).
// - returns nil if there are no changes
// - returns a DripEventBrushSettings object if things have changed.
- (id)getNewBrushSettings;

- (Brush *)paintBrush;
- (BrushEraser *)eraserBrush;

- (NSColor *)color;
- (void)setColor:(NSColor *)aColor;

- (Brush *)currentBrush;
- (void)selectPaintBrush;
- (void)selectEraser;

// if it's not using the pen tip it's using the pen end (eraser).
- (void)setUsingPenTip:(BOOL)willUsePenTip;
@end
