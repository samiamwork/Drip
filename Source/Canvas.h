//
//  Canvas.h
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PaintLayer.h"
#import "Brush.h"
#import "BrushEraser.h"
#import "DripEventBrushDown.h"
#import "DripEventBrushDrag.h"
#import "DripEventBrushSettings.h"
#import "DripEventLayerAdd.h"
#import "DripEventLayerDelete.h"
#import "DripEventLayerMove.h"
#import "NSData+gzip.h"

@interface Canvas : NSObject <NSCoding> {
	PaintLayer *_topLayer;
	PaintLayer *_bottomLayer;
	PaintLayer *_currentLayer;
	
	NSMutableArray *_layers;
	
	NSMutableArray *_backupLayers;
	BOOL _isPlayingBack;
	unsigned int _eventIndex;
	Brush *_playbackBrush;
	BrushEraser *_playbackEraser;
	Brush *_currentPlaybackBrush;
	PressurePoint _lastPlaybackPoint;
	NSMutableArray *_paintEvents;
	
	unsigned int _width;
	unsigned int _height;
	
	NSDocument *_document;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;
- (void)addLayer;
- (void)deleteLayer:(PaintLayer *)layerToDelete;
- (void)insertLayer:(PaintLayer *)theLayer AtIndex:(unsigned int)theTargetIndex;
- (NSArray *)layers;
- (void)setCurrentLayer:(PaintLayer *)aLayer;
- (PaintLayer *)currentLayer;
- (NSSize)size;

- (void)compactEvents;
- (void)beginPlayback;
- (void)endPlayback;
- (BOOL)isPlayingBack;
- (NSRect)playNextEvent;

- (NSRect)drawAtPoint:(PressurePoint)aPoint withBrush:(Brush *)aBrush onLayer:(int)layerIndex;
- (NSRect)drawAtPoint:(PressurePoint)aPoint withBrushOnCurrentLayer:(Brush *)aBrush;
- (NSRect)drawLineFromPoint:(PressurePoint)startPoint toPoint:(PressurePoint *)endPoint withBrush:(Brush *)aBrush onLayer:(int)layerIndex;
- (NSRect)drawLineFromPoint:(PressurePoint)startPoint toPoint:(PressurePoint *)endPoint withBrushOnCurrentLayer:(Brush *)aBrush;

- (void)drawRect:(NSRect)aRect;

- (void)setDocument:(NSDocument *)newDocument;
- (NSDocument *)document;
@end
