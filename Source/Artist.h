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
	
	// this artist's current color;
	NSColor *_color;
}

- (void)loadSettings;
- (void)saveSettings;
- (void)setCanvasSize:(NSSize)canvasSize;
- (void)changeBrushSettings:(DripEventBrushSettings *)newSettings;

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
