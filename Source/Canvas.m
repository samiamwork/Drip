//
//  Canvas.m
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "Canvas.h"
#import "DripEvent.h"

#import "DripInspectors.h"
#import "DripEventBrushSettings.h"
#import "DripEventLayerSettings.h"
#import "DripEventLayerFill.h"
#import "DripEventLayerImageFill.h"
#import "DripEventStrokeBegin.h"
#import "DripEventLayerChange.h"
#import "DripEventLayerAdd.h"
#import "DripEventLayerDelete.h"
#import "DripEventLayerCollapse.h"
#import "DripEventLayerMove.h"
#import "DripEventStrokeContinue.h"
#import "DripEventStrokeEnd.h"

@interface Canvas (Private)
- (void)addEvents:(NSArray *)theEvents;
- (void)removeEventCount:(unsigned)eventCount;
- (void)setLayerSettings:(DripEventLayerSettings *)newSettings oldSettings:(DripEventLayerSettings *)oldSettings;
- (void)recordLayerChanges;
@end

@implementation Canvas

- (id)init
{
	if( (self = [super init]) ) {
		_compositeLayers = nil;
		_currentLayer = nil;
		
		_layers = [[NSMutableArray alloc] init];
		_paintEvents = [[NSMutableArray alloc] init];
		_undoEvents = [[NSMutableArray alloc] init];
		_layerSettings = nil;
		
		_width = 0;
		_height = 0;
		
		_playbackArtist = nil;
		_playbackCanvas = nil;
		_displayPlaybackUpdates = YES;
		
		_document = nil;
	}

	return self;
}

- (void)dealloc
{
	[_layers release];
	[_compositeLayers release];
	
	[_paintEvents release];
	[_undoEvents release];
	[_document release];
	[_playbackArtist release];
	[_playbackCanvas release];
	
	//[_lastLayerSettings release];
	
	[super dealloc];
}

#pragma mark Events and Playback

- (void)compactEvents
{
	NSMutableArray *newEvents = [[NSMutableArray alloc] init];
	
	DripEventBrushSettings *lastSettings = nil;
	DripEventBrushSettings *newSettings = nil;
	NSEnumerator *eventEnumerator = [_paintEvents objectEnumerator];
	DripEvent *anEvent;
	while( (anEvent = [eventEnumerator nextObject]) ) {
		if( [anEvent isKindOfClass:[DripEventBrushSettings class]] && ![anEvent isEqual:lastSettings] ) {
			newSettings = (DripEventBrushSettings *)anEvent;
		} else if( [anEvent isKindOfClass:[DripEventStrokeBegin class]] ) {
			if( newSettings != nil ) {
				[newEvents addObject:newSettings];
				lastSettings = newSettings;
				newSettings = nil;
			}
			[newEvents addObject:anEvent];
		} else {
			[newEvents addObject:anEvent];
		}
	}	
	
	[_paintEvents release];
	_paintEvents = newEvents;
}

- (unsigned int)currentPlaybackEvent
{
	if( ![self isPlayingBack] )
		return 0;
	
	return _eventIndex;
}
- (unsigned int)eventCount
{
	return [_paintEvents count];
}

// TODO: need to preserve the selected layer before begining playback
// (and restore it when we're done).
- (void)beginPlayback
{
	_playbackCanvas = [[Canvas alloc] initWithWidth:_width height:_height backgroundColor:nil imageData:nil];
	[_playbackCanvas disableRecording];
	_playbackArtist = [[Artist alloc] init];
	[_playbackArtist setCanvasSize:[_playbackCanvas size]];
	
	_eventIndex = 0;
	// peek at the first event and play it if it's a layer fill event
	// we do this to eliminate flicker at the start of playback.
	// layer fill is basically part of layer setup. Also includes imageFill
	DripEvent *anEvent = [_paintEvents objectAtIndex:_eventIndex];
	while( [anEvent isKindOfClass:[DripEventLayerFill class]] || [anEvent isKindOfClass:[DripEventLayerImageFill class]] ) {
		[anEvent runWithCanvas:_playbackCanvas artist:nil];
		_eventIndex++;
		anEvent = [_paintEvents objectAtIndex:_eventIndex];
	}
}
- (void)endPlayback
{
	if( !_playbackCanvas )
		return;
	
	[_playbackArtist release];
	_playbackArtist = nil;
	[_playbackCanvas release];
	_playbackCanvas = nil;
}
- (BOOL)isPlayingBack
{
	return _playbackCanvas ? YES : NO;
}
- (NSRect)playNextEvent
{
	if( _eventIndex >= [_paintEvents count] ) {
		[self endPlayback];
		return NSZeroRect;
	}
	
	DripEvent *theEvent = [_paintEvents objectAtIndex:_eventIndex];
	_eventIndex++;

	return [theEvent runWithCanvas:_playbackCanvas artist:_playbackArtist];
}

- (NSRect)playNextVisibleEvent
{
	NSRect canvasRect = NSMakeRect(0.0f,0.0f,_width,_height);
	NSRect invalidCanvasRect = NSIntersectionRect( [self playNextEvent], canvasRect );
	while( NSIsEmptyRect(invalidCanvasRect) && [self isPlayingBack] )
		invalidCanvasRect = NSIntersectionRect( [self playNextEvent], canvasRect );
	
	return invalidCanvasRect;
}

- (void)addEvents:(NSArray *)theEvents
{
	[_paintEvents addObjectsFromArray:theEvents];
	
}
- (void)removeEventCount:(unsigned)eventCount
{
	NSRange oldEventRange = NSMakeRange([_paintEvents count]-eventCount, eventCount);
	NSArray *oldEvents = [_paintEvents objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:oldEventRange]];
	[_paintEvents removeObjectsInRange:oldEventRange];
	
	[[[_document undoManager] prepareWithInvocationTarget:self] addEvents:oldEvents];
}

- (void)addUndoEvents
{
	if( _layerSettings ) {
		
	}
	
	[[[_document undoManager] prepareWithInvocationTarget:self] removeEventCount:[_undoEvents count]];
	[_paintEvents addObjectsFromArray:_undoEvents];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if( ![encoder isKindOfClass:[NSKeyedArchiver class]] )
		return;
	
	NSKeyedArchiver *archiver = (NSKeyedArchiver *)encoder;
	[archiver encodeInt32:(int)_width forKey:@"width"];
	[archiver encodeInt32:(int)_height forKey:@"height"];
	[archiver encodeObject:_layers forKey:@"layers"];
	
	// archive events as data
	// when events are compacted, undo-integrity is lost.
	// Undo relies on removing a certain number of events from the list and
	// compacting disrupts that.
	//[self compactEvents];
	NSMutableData *eventData = [[NSMutableData alloc] init];
	NSEnumerator *eventEnumerator = [_paintEvents objectEnumerator];
	DripEvent *anEvent;
	while( (anEvent = [eventEnumerator nextObject]) )
		[eventData appendData:[anEvent data]];
	
	[archiver encodeObject:[eventData gzipDeflate] forKey:@"events"];
	[eventData release];
}

- (id)initWithCoder:(NSCoder *)decoder
{	
	if( (self = [super init]) ) {
		if( ![decoder isKindOfClass:[NSKeyedUnarchiver class]] ) {
			[self release];
			return nil;
		}
		NSKeyedUnarchiver *unarchiver = (NSKeyedUnarchiver *)decoder;
		
		_playbackArtist = nil;
		_playbackCanvas = nil;
		_displayPlaybackUpdates = YES;
		
		_width = (unsigned int)[unarchiver decodeIntForKey:@"width"];
		_height = (unsigned int)[unarchiver decodeIntForKey:@"height"];
		// TODO: should probably be fixed to add some kind of release.
		_layers = [[NSMutableArray alloc] initWithArray:[unarchiver decodeObjectForKey:@"layers"]];
		[self setCurrentLayer:[_layers objectAtIndex:0]];
		
		//get events
		_paintEvents = [[NSMutableArray alloc] init];
		_layerSettings = nil;
		NSData *zippedEvents = [unarchiver decodeObjectForKey:@"events"];
		//printf("events: %d\n", [zippedEvents length]);
		NSData *eventData = [zippedEvents gzipInflate];
		unsigned char *bytes = (unsigned char *)[eventData bytes];
		//DANGER: could possibly be too small
		unsigned int position = 0;
		while( position < [eventData length] ) {
			// event list is incomplete... we might want to fail more gracefully since
			// we probably have everything else. Not worth dying for.
			if( bytes[position] > [eventData length]-position ) {
				[self release];
				return nil;
			}
			
			DripEvent *newEvent = [DripEvent eventWithBytes:&bytes[position] length:[eventData length]-position];
			position += [newEvent length];
			while( [newEvent bytesNeeded] )
				position += [newEvent addBytes:&bytes[position] length:[eventData length]-position];
				
			
			[_paintEvents addObject:newEvent];
		}
		
	}
	
	return self;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height backgroundColor:(NSColor *)aColor imageData:(NSData *)theImageData
{
	if( (self =[super init]) ) {
		_width = width;
		_height = height;
		
		_compositeLayers = nil;
		Layer *aLayer = [[Layer alloc] initWithWidth:_width height:_height];
		[aLayer setName:@"Layer 0"];
		_layers = [[NSMutableArray alloc] initWithObjects:aLayer,nil];
		[aLayer release];
		[self setCurrentLayer:aLayer];
		
		_paintEvents = [[NSMutableArray alloc] init];
		_layerSettings = nil;
		_document = nil;
		
		_playbackCanvas = nil;
		_playbackArtist = nil;
		_displayPlaybackUpdates = YES;
		// fill first layer with white
		[self fillCurrentLayerWithColor:aColor];
		[self fillCurrentLayerWithImage:theImageData];
	}
	
	return self;
}

- (NSSize)size
{
	return NSMakeSize((float)_width,(float)_height);
}

- (void)rebuildTopAndBottom
{
	unsigned int targetIndex = [_layers indexOfObject:_currentLayer];
	if( targetIndex == NSNotFound )
		return;
	
	[_compositeLayers release];
	_compositeLayers = [[NSMutableArray alloc] init];
	
	int layerIndex;
	int indexOfLastSimilarLayer;
	CGBlendMode targetBlendMode;
	if( targetIndex > 0 ) {
		indexOfLastSimilarLayer = 0;
		targetBlendMode = [[_layers objectAtIndex:indexOfLastSimilarLayer] blendMode];
		for( layerIndex = 0; layerIndex < targetIndex; layerIndex++ ) {
			if( targetBlendMode != [[_layers objectAtIndex:layerIndex] blendMode] ) {
				[_compositeLayers addObject:[[[Layer alloc] initWithContentsOfLayers:_layers inRange:NSMakeRange(indexOfLastSimilarLayer,layerIndex-indexOfLastSimilarLayer)] autorelease]];
				[[_compositeLayers lastObject] setBlendMode:targetBlendMode];
				indexOfLastSimilarLayer = layerIndex;
				targetBlendMode = [[_layers objectAtIndex:indexOfLastSimilarLayer] blendMode];
			}
		}
		
		[_compositeLayers addObject:[[[Layer alloc] initWithContentsOfLayers:_layers inRange:NSMakeRange(indexOfLastSimilarLayer,layerIndex-indexOfLastSimilarLayer)] autorelease]];
		[[_compositeLayers lastObject] setBlendMode:targetBlendMode];
	}
	[_compositeLayers addObject:_currentLayer];
	if( targetIndex < [_layers count]-1 ) {
		indexOfLastSimilarLayer = targetIndex+1;
		targetBlendMode = [[_layers objectAtIndex:indexOfLastSimilarLayer] blendMode];
		for( layerIndex = targetIndex+1; layerIndex < [_layers count]; layerIndex++ ) {
			if( targetBlendMode != [[_layers objectAtIndex:layerIndex] blendMode] ) {
				[_compositeLayers addObject:[[[Layer alloc] initWithContentsOfLayers:_layers inRange:NSMakeRange(indexOfLastSimilarLayer,layerIndex-indexOfLastSimilarLayer)] autorelease]];
				[[_compositeLayers lastObject] setBlendMode:targetBlendMode];
				indexOfLastSimilarLayer = layerIndex;
				targetBlendMode = [[_layers objectAtIndex:indexOfLastSimilarLayer] blendMode];
			}
		}
		
		[_compositeLayers addObject:[[[Layer alloc] initWithContentsOfLayers:_layers inRange:NSMakeRange(indexOfLastSimilarLayer,layerIndex-indexOfLastSimilarLayer)] autorelease]];
		[[_compositeLayers lastObject] setBlendMode:targetBlendMode];
	}
	
}

// This CANNOT be undone!
// designed to be used for a playback canvas.
- (void)disableRecording
{
	[_paintEvents release];
	_paintEvents = nil;
}

- (void)setDisplayPlaybackUpdates:(BOOL)shouldUpdate
{
	_displayPlaybackUpdates = shouldUpdate;
}
- (Canvas *)playbackCanvas
{
	return _playbackCanvas;
}

- (void)addDripEvent:(DripEvent *)newEvent
{
	if( _layerSettings != nil ) {
		[_paintEvents addObject:_layerSettings];
		[_layerSettings release];
		_layerSettings = nil;
	}
	
}

#pragma mark Events

- (void)addLayer
{
	unsigned int currentIndex = [_layers indexOfObject:_currentLayer];
	//assume that it exists
	if( currentIndex == NSNotFound ) {
		printf("currentLayer not found! Serious!\n");
		return;
	}

	//I don't really need to do this here... but I probably should.
	[self recordLayerChanges];
	
	// EVENT:
	// add new layer
	DripEventLayerAdd *newEvent = [[DripEventLayerAdd alloc] init];
	[self addEvents:[NSArray arrayWithObject:newEvent]];
	[newEvent release];
	Layer *newLayer = [[Layer alloc] initWithWidth:_width height:_height];
	
	//rename
	NSMutableArray *names = [NSMutableArray array];
	NSEnumerator *layerEnumerator = [_layers objectEnumerator];
	Layer *aLayer;
	while( (aLayer = [layerEnumerator nextObject]) )
		[names addObject:[aLayer name]];
	unsigned int layerNumber = 0;
	while( [names containsObject:[NSString stringWithFormat:@"Layer %d",layerNumber]] )
		layerNumber++;
	[newLayer setName:[NSString stringWithFormat:@"Layer %d",layerNumber]];
	
	[newLayer setUndoManager:[_document undoManager]];
	[_layers insertObject:newLayer atIndex:currentIndex+1];
	
	[newLayer release];
	[self setCurrentLayer:newLayer];
	
	//UNDO
	[[[_document undoManager] prepareWithInvocationTarget:self] deleteLayer:newLayer];
	
	[_document updateChangeCount:NSChangeDone];
}

- (void)deleteLayer:(Layer *)layerToDelete
{
	// can't delete if there's only one layer
	if( [_layers count] == 1 )
		return;
	
	unsigned int deleteIndex = [_layers indexOfObject:layerToDelete];
	
	//assume that it exists
	if( deleteIndex == NSNotFound ) {
		printf("layerToDelete not found! Serious!\n");
		return;
	}
	
	//I don't really need to do this here... but I probably should.
	[self recordLayerChanges];
	
	// EVENT: remove layer at "deleteIndex"
	DripEventLayerDelete *newEvent = [[DripEventLayerDelete alloc] init];
	[self addEvents:[NSArray arrayWithObject:newEvent]];
	[newEvent release];
	
	[[[_document undoManager] prepareWithInvocationTarget:self] insertLayer:layerToDelete AtIndex:deleteIndex];
	[_layers removeObjectAtIndex:deleteIndex];
	
	if( deleteIndex != 0 )
		deleteIndex--;
	
	[_document updateChangeCount:NSChangeDone];
	[self setCurrentLayer:[_layers objectAtIndex:deleteIndex]];
}

- (void)insertLayer:(Layer *)theLayer AtIndex:(unsigned int)theTargetIndex
{
	// first see if this is a layer we already have
	unsigned int theLayerIndex = [_layers indexOfObject:theLayer];
	if( theLayerIndex == NSNotFound ) {
		[_layers insertObject:theLayer atIndex:theTargetIndex];
		[[[_document undoManager] prepareWithInvocationTarget:self] deleteLayer:theLayer];
		return;
	}
	// For event recording and playback purposes we're going to assume that we're always using this
	// to rearrange layers, rather than to insert foreign layers.
	// inserting foreign layers is for undo ops, so it doesn't have an event.
	
	if( theLayerIndex == theTargetIndex )
		return;
	
	[self recordLayerChanges];
	
	// EVENT: move layer at index "theLayerIndex" to "theTargetIndex"
	DripEventLayerMove *layerMoveEvent = [[DripEventLayerMove alloc] initWithFromIndex:theLayerIndex toIndex:theTargetIndex];
	[self addEvents:[NSArray arrayWithObject:layerMoveEvent]];
	[layerMoveEvent release];
	
	[_layers insertObject:theLayer atIndex:theTargetIndex];
	if( theLayerIndex > theTargetIndex )
		theLayerIndex++;
	[_layers removeObjectAtIndex:theLayerIndex];
	//UNDO: move it back
	[[[_document undoManager] prepareWithInvocationTarget:self] insertLayer:theLayer AtIndex:theLayerIndex];
	
	[self rebuildTopAndBottom];
}

- (void)moveLayerAtIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex
{
	[self insertLayer:[_layers objectAtIndex:fromIndex] AtIndex:toIndex];
}

- (void)collapseLayer:(Layer *)layerToCollapse
{
	unsigned int theLayerIndex = [_layers indexOfObject:layerToCollapse];
	if( theLayerIndex == NSNotFound || theLayerIndex == 0 )
		return;

	[self recordLayerChanges];
	
	// EVENT: merge layer at index "theLayerIndex" and the layer under it and insert in place of the two.
	DripEventLayerCollapse *layerCollapseEvent = [[DripEventLayerCollapse alloc] init];
	[self addEvents:[NSArray arrayWithObject:layerCollapseEvent]];
	[layerCollapseEvent release];
	
	Layer *joinedLayers = [[Layer alloc] initWithContentsOfLayers:_layers inRange:NSMakeRange(theLayerIndex-1,2)];
	[joinedLayers setName:[[_layers objectAtIndex:theLayerIndex-1] name]];
	
	[[[_document undoManager] prepareWithInvocationTarget:self] insertLayer:[_layers objectAtIndex:theLayerIndex] AtIndex:theLayerIndex-1];
	[[[_document undoManager] prepareWithInvocationTarget:self] insertLayer:[_layers objectAtIndex:theLayerIndex-1] AtIndex:theLayerIndex-1];
	[[[_document undoManager] prepareWithInvocationTarget:self] deleteLayer:joinedLayers];
	
	[_layers removeObjectAtIndex:theLayerIndex-1];
	[_layers removeObjectAtIndex:theLayerIndex-1];
	[_layers insertObject:joinedLayers atIndex:theLayerIndex-1];
	
	[_document updateChangeCount:NSChangeDone];
	
	[self setCurrentLayer:joinedLayers];
}

- (NSArray *)layers
{
	return [NSArray arrayWithArray:_layers];
}

- (void)setCurrentLayer:(Layer *)aLayer
{
	unsigned int layerIndex = [_layers indexOfObject:aLayer];
	if( aLayer == _currentLayer || layerIndex == NSNotFound )
		return;
	
	_currentLayer = aLayer;
	
	[self recordLayerChanges];
	
	// EVENT: set CurrentLayer to layer at index "layerIndex"
	//if( ![self isPlayingBack] )
	//	[_paintEvents addObject:[[[DripEventLayerChange alloc] initWithLayerIndex:layerIndex] autorelease]];
	DripEventLayerChange *layerChangeEvent = [[DripEventLayerChange alloc] initWithLayerIndex:layerIndex];
	[self addEvents:[NSArray arrayWithObject:layerChangeEvent]];
	[layerChangeEvent release];
	
	[[[_document undoManager] prepareWithInvocationTarget:self] setCurrentLayer:[_layers objectAtIndex:layerIndex]];
	
	[self rebuildTopAndBottom];
}

- (Layer *)currentLayer
{
	return _currentLayer;
}

#pragma mark drawing methods

- (NSRect)beginStrokeAtPoint:(PressurePoint)aPoint withArtist:(Artist *)anArtist
{
	if( [self isPlayingBack] )
		return NSZeroRect;

	[self recordLayerChanges];
	
	return [[anArtist currentBrush] beginStrokeAtPoint:aPoint onLayer:_currentLayer];
}
- (NSRect)continueStrokeAtPoint:(PressurePoint)aPoint withArtist:(Artist *)anArtist
{
	if( [self isPlayingBack] )
		return NSZeroRect;

	return [[anArtist currentBrush] continueStrokeAtPoint:aPoint];
}
- (NSRect)endStrokeWithArtist:(Artist *)anArtist
{
	// EVENT: End stroke
	// TODO: the event needs to support a brush identifier
	NSRect strokeRect = [[anArtist currentBrush] endStroke];
	
	// if we don't have a last brush setting for this artist or if the current setting
	// is different than than the one we have on record then update it and add the event.
	DripEventBrushSettings *brushSettings = [anArtist getNewBrushSettings];
	if( brushSettings )
		[self addEvents:[NSArray arrayWithObject:brushSettings]];
	[self addEvents:[[anArtist currentBrush] popStrokeEvents]];

	return strokeRect;
}

- (void)fillCurrentLayerWithColor:(NSColor *)aColor
{
	if( !aColor )
		return;
	
	//EVENT:
	// fill currentLayer
	if( ![self isPlayingBack] )
		[_paintEvents addObject:[[[DripEventLayerFill alloc] initWithColor:aColor] autorelease]];

	[_currentLayer fillLayerWithColor:aColor];
}

- (CGRect)fillCurrentLayerWithImage:(NSData *)theImageData
{
	if( !theImageData )
		return CGRectZero;
	
	DripEventLayerImageFill *imageFillEvent = [[DripEventLayerImageFill alloc] initWithImageData:theImageData];
	if( !imageFillEvent || ![imageFillEvent image] )
		return CGRectZero;
	
	if( ![self isPlayingBack] )
		[_paintEvents addObject:imageFillEvent];
	
	CGRect affectedRect = [_currentLayer fillLayerWithImage:[imageFillEvent image]];
	[imageFillEvent release];

	return affectedRect;
}

- (void)drawRect:(NSRect)aRect inContext:(CGContextRef)context
{
	if( _playbackCanvas && _displayPlaybackUpdates ) {
		[_playbackCanvas drawRect:aRect inContext:context];
		return;
	}
	
	NSEnumerator *layerEnumerator = [_compositeLayers objectEnumerator];
	Layer *aLayer;
	while( (aLayer = [layerEnumerator nextObject]) )
		[aLayer drawRect:aRect inContext:context];
}

- (void)drawRect:(NSRect)aRect
{
	if( _playbackCanvas && _displayPlaybackUpdates ) {
		[_playbackCanvas drawRect:aRect];
		return;
	}
	
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	
	[self drawRect:aRect inContext:cxt];
}

- (void)setDocument:(NSDocument *)newDocument
{
	if( newDocument == _document )
		return;
	
	[_document release];
	_document = [newDocument retain];
	
	[_layers makeObjectsPerformSelector:@selector(setUndoManager:) withObject:[_document undoManager]];
}
- (NSDocument *)document
{
	return _document;
}

// records any layer setting changes that haven't been recorded yet.
- (void)recordLayerChanges
{
	if( !_layerSettings )
		return;
	
	[self addEvents:[NSArray arrayWithObject:_layerSettings]];
	[[[_document undoManager] prepareWithInvocationTarget:self] setLayerSettings:nil oldSettings:_layerSettings];
	[_layerSettings release];
	_layerSettings = nil;
}

- (void)setLayerSettings:(DripEventLayerSettings *)newSettings oldSettings:(DripEventLayerSettings *)oldSettings
{
	if( newSettings ) {
		// the index of the layer should not have changed
		Layer *theLayer = [_layers objectAtIndex:[newSettings layerIndex]];
		DripEventLayerSettings *layerSettings = [[DripEventLayerSettings alloc] initWithLayerIndex:[newSettings layerIndex] opacity:[theLayer opacity] visible:[theLayer visible] blendMode:[theLayer blendMode]];
		[newSettings runWithCanvas:self artist:nil];
		// we ignore the lvalue because we only use this to save the new settings
		[theLayer popOldSettings];

		[[[_document undoManager] prepareWithInvocationTarget:self] setLayerSettings:layerSettings oldSettings:_layerSettings];
		[oldSettings release];
		[[DripInspectors sharedController] layersUpdated];
	}

	_layerSettings = [oldSettings retain];
}

- (void)settingsChangedForLayer:(Layer *)aLayer
{
	unsigned int layerIndex = [_layers indexOfObject:aLayer];
	if( layerIndex == NSNotFound )
		return;
	
	DripEventLayerSettings *newLayerSettings = [[DripEventLayerSettings alloc] initWithLayerIndex:layerIndex opacity:[aLayer opacity] visible:[aLayer visible] blendMode:[aLayer blendMode]];
	
	// Check to see if we have saved old settings
	// if we don't have settings from before, all parties are properly aware of this
	// layer's immediatly previous state, so in the event of undo we need to save
	// the immediately previous state.
	if( _layerSettings == nil ) {
		DripEventLayerSettings *layerSettings = [aLayer popOldSettings];
		[layerSettings setLayerIndex:layerIndex];
		[[[_document undoManager] prepareWithInvocationTarget:self] setLayerSettings:layerSettings oldSettings:nil];
	} else if( [_layerSettings layerIndex] != layerIndex ) {
		// if these settings are on a different layer than before then we should record the old ones
		[self addEvents:[NSArray arrayWithObjects:_layerSettings]];
		
		DripEventLayerSettings *layerSettings = [aLayer popOldSettings];
		[layerSettings setLayerIndex:layerIndex];
		[[[_document undoManager] prepareWithInvocationTarget:self] setLayerSettings:layerSettings oldSettings:_layerSettings];
		//[_paintEvents addObject:_layerSettings];
	}
	
	[_layerSettings release];
	_layerSettings = newLayerSettings;
	
	// if this layer is not the current layer then we need to rebuild our top and bottom (not likely but it's cheap to check
	// and it is possible).
	if( aLayer != _currentLayer )
		[self rebuildTopAndBottom];
}

- (NSBitmapImageRep *)bitmapImageRep
{
	NSImage *newImage = [[NSImage alloc] initWithSize:NSMakeSize(_width,_height)];
	[newImage lockFocus];
	
	[self drawRect:NSMakeRect(0.0f,0.0f,_width,_height)];
	NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0.0f,0.0f,_width,_height)];
	[bitmap autorelease];
	
	[newImage unlockFocus];
	[newImage release];
	
	return bitmap;
}
@end
