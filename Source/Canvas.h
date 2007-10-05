//
//  Canvas.h
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Layer.h"
#import "Brush.h"
#import "BrushEraser.h"
#import "DripEventStrokeBegin.h"
#import "DripEventStrokeContinue.h"
#import "DripEventStrokeEnd.h"
#import "DripEventBrushSettings.h"
#import "DripEventLayerChange.h"
#import "DripEventLayerAdd.h"
#import "DripEventLayerDelete.h"
#import "DripEventLayerCollapse.h"
#import "DripEventLayerMove.h"
#import "DripEventLayerSettings.h"
#import "NSData+gzip.h"

@interface Canvas : NSObject <NSCoding> {
	NSMutableArray *_compositeLayers;
	Layer *_currentLayer;
	
	NSMutableArray *_layers;
	
	NSMutableArray *_backupLayers;
	BOOL _isPlayingBack;
	unsigned int _eventIndex;
	Brush *_playbackBrush;
	BrushEraser *_playbackEraser;
	Brush *_currentPlaybackBrush;
	PressurePoint _lastPlaybackPoint;
	NSMutableArray *_paintEvents;
	DripEventLayerSettings *_layerSettings;
	
	unsigned int _width;
	unsigned int _height;
	
	NSDocument *_document;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;
- (void)addLayer;
- (void)deleteLayer:(Layer *)layerToDelete;
- (void)insertLayer:(Layer *)theLayer AtIndex:(unsigned int)theTargetIndex;
- (void)collapseLayer:(Layer *)layerToCollapse;
- (NSArray *)layers;
- (void)setCurrentLayer:(Layer *)aLayer;
- (Layer *)currentLayer;
- (NSSize)size;
- (void)rebuildTopAndBottom;

- (void)compactEvents;
- (unsigned int)currentPlaybackEvent;
- (unsigned int)eventCount;
- (void)beginPlayback;
- (void)endPlayback;
- (BOOL)isPlayingBack;
- (NSRect)playNextEvent;
- (NSRect)playNextVisibleEvent;

- (NSRect)beginStrokeAtPoint:(PressurePoint)aPoint withBrush:(Brush *)aBrush;
- (NSRect)continueStrokeAtPoint:(PressurePoint)aPoint withBrush:(Brush *)aBrush;
- (void)endStrokeWithBrush:(Brush *)aBrush;

- (void)drawRect:(NSRect)aRect inContext:(CGContextRef)context;
- (void)drawRect:(NSRect)aRect;

- (void)setDocument:(NSDocument *)newDocument;
- (NSDocument *)document;

- (void)settingsChangedForLayer:(Layer *)aLayer;
@end
