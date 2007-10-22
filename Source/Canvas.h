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
#import "DripEventLayerFill.h"
#import "NSData+gzip.h"
#import "Artist.h"

@interface Canvas : NSObject <NSCoding> {
	NSMutableArray *_compositeLayers;
	Layer *_currentLayer;
	
	NSMutableArray *_layers;
	
	NSMutableArray *_backupLayers;
	Canvas *_playbackCanvas;
	Artist *_playbackArtist;
	BOOL _displayPlaybackUpdates;
	
	NSMutableArray *_paintEvents;
	unsigned int _eventIndex;
	
	DripEventLayerSettings *_layerSettings;
	
	unsigned int _width;
	unsigned int _height;
	
	NSDocument *_document;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height backgroundColor:(NSColor *)aColor;
- (void)addLayer;
- (void)deleteLayer:(Layer *)layerToDelete;
- (void)insertLayer:(Layer *)theLayer AtIndex:(unsigned int)theTargetIndex;
- (void)moveLayerAtIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex;
- (void)collapseLayer:(Layer *)layerToCollapse;
- (NSArray *)layers;
- (void)setCurrentLayer:(Layer *)aLayer;
- (Layer *)currentLayer;
- (NSSize)size;
- (void)rebuildTopAndBottom;

// this is PERMANENT and cannot be undone.
// if we were to resume recording later after disabling it there will be events missing and
// we would not be able to reconstruct the drawing from the recorded events so they
// would be useless.
- (void)disableRecording;
- (void)setDisplayPlaybackUpdates:(BOOL)shouldUpdate;
- (Canvas *)playbackCanvas;

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

- (void)fillCurrentLayerWithColor:(NSColor *)aColor;

- (void)drawRect:(NSRect)aRect inContext:(CGContextRef)context;
- (void)drawRect:(NSRect)aRect;

- (void)setDocument:(NSDocument *)newDocument;
- (NSDocument *)document;

- (void)settingsChangedForLayer:(Layer *)aLayer;

- (NSBitmapImageRep *)bitmapImageRep;
@end
