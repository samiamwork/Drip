//
//  Canvas.m
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "Canvas.h"


@implementation Canvas

- (id)init
{
	if( (self = [super init]) ) {
		_topLayer = nil;
		_bottomLayer = nil;
		_currentLayer = nil;
		
		_layers = [[NSMutableArray alloc] init];
		_paintEvents = [[NSMutableArray alloc] init];
		_layerSettings = nil;
		
		_width = 0;
		_height = 0;
		
		_document = nil;
	}

	return self;
}

- (void)dealloc
{
	[_layers release];
	[_topLayer release];
	[_bottomLayer release];
	
	[_paintEvents release];
	[_document release];

	[super dealloc];
}

- (void)compactEvents
{
	NSMutableArray *newEvents = [[NSMutableArray alloc] init];
	
	DripEventBrushSettings *lastSetting = nil;
	NSEnumerator *eventEnumerator = [_paintEvents objectEnumerator];
	DripEvent *anEvent;
	while( (anEvent = [eventEnumerator nextObject]) ) {
		
		if( ![anEvent isKindOfClass:[DripEventBrushSettings class]] ) {
			if( lastSetting != nil )
				[newEvents addObject:lastSetting];
			lastSetting = nil;
			[newEvents addObject:anEvent];
		} else 
			lastSetting = (DripEventBrushSettings *)anEvent;
	}	
	
	[_paintEvents release];
	_paintEvents = newEvents;
}

- (void)beginPlayback
{
	_backupLayers = _layers;
	
	_currentLayer = [[PaintLayer alloc] initWithWidth:_width height:_height];
	[_currentLayer setName:@"Layer 0"];
	_layers = [[NSMutableArray alloc] initWithObjects:_currentLayer,nil];
	[_currentLayer release];
	_topLayer = nil;
	_bottomLayer = nil;
	
	_currentPlaybackBrush = _playbackBrush = [[Brush alloc] init];
	_playbackEraser = [[BrushEraser alloc] init];
	_eventIndex = 0;
	_isPlayingBack = YES;
}
- (void)endPlayback
{
	if( !_isPlayingBack )
		return;
	
	_isPlayingBack = NO;
	[_layers release];
	_layers = _backupLayers;
	[self setCurrentLayer:[_layers objectAtIndex:0]];
	
	[_playbackBrush release];
	_playbackBrush = nil;
	[_playbackEraser release];
	_playbackBrush = nil;
}
- (BOOL)isPlayingBack
{
	return _isPlayingBack;
}
- (NSRect)playNextEvent
{
	if( _eventIndex >= [_paintEvents count] ) {
		[self endPlayback];
		return NSZeroRect;
	}
	
	DripEvent *theEvent = [_paintEvents objectAtIndex:_eventIndex];
	_eventIndex++;
	
	if( [theEvent isKindOfClass:[DripEventBrushDown class]] ) {
		DripEventBrushDown *brushDown = (DripEventBrushDown *)theEvent;
		_lastPlaybackPoint = (PressurePoint){[brushDown position].x, [brushDown position].y, [brushDown pressure]};
		return [_currentPlaybackBrush renderPointAt:_lastPlaybackPoint onLayer:_currentLayer];
	} else if( [theEvent isKindOfClass:[DripEventBrushDrag class]] ) {
		DripEventBrushDrag *brushDrag = (DripEventBrushDrag *)theEvent;
		PressurePoint dragPoint = (PressurePoint){[brushDrag position].x, [brushDrag position].y, [brushDrag pressure]}; 
		NSRect affectedRect = [_currentPlaybackBrush renderLineFromPoint:_lastPlaybackPoint toPoint:&dragPoint onLayer:_currentLayer];
		_lastPlaybackPoint = dragPoint;
		return affectedRect;
	} else if( [theEvent isKindOfClass:[DripEventBrushSettings class]] ) {
		DripEventBrushSettings *brushSettings = (DripEventBrushSettings *)theEvent;
		if( [brushSettings type] == kBrushTypePaint )
			_currentPlaybackBrush = _playbackBrush;
		else
			_currentPlaybackBrush = _playbackEraser;
		[_currentPlaybackBrush changeSettings:brushSettings];
		return NSZeroRect;
	} else if( [theEvent isKindOfClass:[DripEventLayerAdd class]] ) {
		[self addLayer];
		return NSMakeRect(0.0f,0.0f,_width,_height);
	} else if( [theEvent isKindOfClass:[DripEventLayerDelete class]] ) {
		[self deleteLayer:_currentLayer];
		return NSMakeRect(0.0f,0.0f,_width,_height);
	} else if( [theEvent isKindOfClass:[DripEventLayerMove class]] ) {
		DripEventLayerMove *layerMove = (DripEventLayerMove *)theEvent;
		[self insertLayer:[_layers objectAtIndex:[layerMove fromIndex]] AtIndex:[layerMove toIndex]];
		return NSMakeRect(0.0f,0.0f,_width,_height);
	} else if( [theEvent isKindOfClass:[DripEventLayerSettings class]] ) {
		DripEventLayerSettings *layerSettings = (DripEventLayerSettings *)theEvent;
		[_currentLayer changeSettings:layerSettings];
		return NSMakeRect(0.0f,0.0f,_width,_height);
	} else {
		printf("unknown event!\n");
	}
	return NSZeroRect;
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
	[self compactEvents];
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
		
		_width = (unsigned int)[unarchiver decodeIntForKey:@"width"];
		_height = (unsigned int)[unarchiver decodeIntForKey:@"height"];
		_layers = [[NSMutableArray alloc] initWithArray:[unarchiver decodeObjectForKey:@"layers"]];
		[self setCurrentLayer:[_layers objectAtIndex:0]];
		
		//get events
		_paintEvents = [[NSMutableArray alloc] init];
		_layerSettings = nil;
		NSData *eventData = [[unarchiver decodeObjectForKey:@"events"] gzipInflate];
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
			
			DripEvent *newEvent = nil;
			switch( bytes[position+1] ) {
				case kDripEventBrushDown:
					newEvent = [DripEventBrushDown eventWithBytes:&bytes[position] length:[eventData length]-position];
					break;
				case kDripEventBrushDrag:
					newEvent = [DripEventBrushDrag eventWithBytes:&bytes[position] length:[eventData length]-position];
					break;
				case kDripEventBrushSettings:
					newEvent = [DripEventBrushSettings eventWithBytes:&bytes[position] length:[eventData length]-position];
					break;
				case kDripEventLayerAdd:
					newEvent = [DripEventLayerAdd eventWithBytes:&bytes[position] length:[eventData length]-position];
					break;
				case kDripEventLayerDelete:
					newEvent = [DripEventLayerDelete eventWithBytes:&bytes[position] length:[eventData length]-position];
					break;
				case kDripEventLayerMove:
					newEvent = [DripEventLayerMove eventWithBytes:&bytes[position] length:[eventData length]-position];
					break;
				case kDripEventLayerSettings:
					newEvent = [DripEventLayerSettings eventWithBytes:&bytes[position] length:[eventData length]-position];
					break;
				default:
					printf("unknown event! (%d)\n", bytes[position+1]);
			}
			
			[_paintEvents addObject:newEvent];
			position += bytes[position];
		}
		
	}
	
	return self;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height
{
	if( (self =[super init]) ) {
		_width = width;
		_height = height;
		
		_currentLayer = [[PaintLayer alloc] initWithWidth:_width height:_height];
		[_currentLayer setName:@"Layer 0"];
		_layers = [[NSMutableArray alloc] initWithObjects:_currentLayer,nil];
		[_currentLayer release];
		_topLayer = nil;
		_bottomLayer = nil;
		
		_paintEvents = [[NSMutableArray alloc] init];
		_layerSettings = nil;
		_document = nil;
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
	
	[_bottomLayer release];
	_bottomLayer = nil;
	[_topLayer release];
	_topLayer = nil;
	_currentLayer = [_layers objectAtIndex:targetIndex];
	
	if( targetIndex > 0 )
		_bottomLayer = [[PaintLayer alloc] initWithContentsOfLayers:_layers inRange:NSMakeRange(0,targetIndex)];
	if( targetIndex < [_layers count]-1 )
		_topLayer = [[PaintLayer alloc] initWithContentsOfLayers:_layers inRange:NSMakeRange(targetIndex+1,[_layers count]-(targetIndex+1))];
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

	if( _layerSettings != nil ) {
		[_paintEvents addObject:_layerSettings];
		[_layerSettings release];
		_layerSettings = nil;
	}
	// EVENT:
	// add new layer
	if( !_isPlayingBack )
		[_paintEvents addObject:[[[DripEventLayerAdd alloc] init] autorelease]];
	PaintLayer *newLayer = [[PaintLayer alloc] initWithWidth:_width height:_height];
	
	//rename
	NSMutableArray *names = [NSMutableArray array];
	NSEnumerator *layerEnumerator = [_layers objectEnumerator];
	PaintLayer *aLayer;
	while( (aLayer = [layerEnumerator nextObject]) )
		[names addObject:[aLayer name]];
	unsigned int layerNumber = 0;
	while( [names containsObject:[NSString stringWithFormat:@"Layer %d",layerNumber]] )
		layerNumber++;
	[newLayer setName:[NSString stringWithFormat:@"Layer %d",layerNumber]];
	
	
	[_layers insertObject:newLayer atIndex:currentIndex+1];
	[newLayer release];
	[self setCurrentLayer:newLayer];
}

- (void)deleteLayer:(PaintLayer *)layerToDelete
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
	
	if( _layerSettings != nil ) {
		[_paintEvents addObject:_layerSettings];
		[_layerSettings release];
		_layerSettings = nil;
	}
	// EVENT:
	// remove layer at "deleteIndex"
	if( !_isPlayingBack )
		[_paintEvents addObject:[[[DripEventLayerDelete alloc] init] autorelease]];
	[_layers removeObjectAtIndex:deleteIndex];
	
	if( deleteIndex != 0 )
		deleteIndex--;
	
	[self setCurrentLayer:[_layers objectAtIndex:deleteIndex]];
}

- (void)insertLayer:(PaintLayer *)theLayer AtIndex:(unsigned int)theTargetIndex
{
	// first see if this is a layer we already have
	unsigned int theLayerIndex = [_layers indexOfObject:theLayer];
	if( theLayerIndex == NSNotFound ) {
		[_layers insertObject:theLayer atIndex:theTargetIndex];
		return;
	}
	// For event recording and playback purposes we're going to assume that we're always using this
	// to rearrange layers, rather than to insert foreign layers.
	
	if( theLayerIndex == theTargetIndex )
		return;
	
	if( _layerSettings != nil ) {
		[_paintEvents addObject:_layerSettings];
		[_layerSettings release];
		_layerSettings = nil;
	}
	// EVENT:
	// move layer at index "theLayerIndex" to "theTargetIndex"
	if( !_isPlayingBack )
		[_paintEvents addObject:[[[DripEventLayerMove alloc] initWithFromIndex:theLayerIndex toIndex:theTargetIndex] autorelease]];
	[_layers insertObject:theLayer atIndex:theTargetIndex];
	if( theLayerIndex > theTargetIndex )
		theLayerIndex++;
	[_layers removeObjectAtIndex:theLayerIndex];
	
	[self rebuildTopAndBottom];
}

- (NSArray *)layers
{
	return [NSArray arrayWithArray:_layers];
}

- (void)setCurrentLayer:(PaintLayer *)aLayer
{
	unsigned int layerIndex = [_layers indexOfObject:aLayer];
	if( aLayer == _currentLayer || layerIndex == NSNotFound )
		return;
	
	if( _layerSettings != nil ) {
		[_paintEvents addObject:_layerSettings];
		[_layerSettings release];
		_layerSettings = nil;
	}
	// EVENT:
	// set CurrentLayer to layer at index "layerIndex"
	_currentLayer = aLayer;
	if( _layerSettings != nil ) {
		[_paintEvents addObject:_layerSettings];
		[_layerSettings release];
		_layerSettings = nil;
	}
	
	[self rebuildTopAndBottom];
}

- (PaintLayer *)currentLayer
{
	return _currentLayer;
}

#pragma mark drawing methods
// we funnel all drawing through these so that we can generate the proper events for recording
- (NSRect)drawAtPoint:(PressurePoint)aPoint withBrush:(Brush *)aBrush onLayer:(int)layerIndex
{
	if( _isPlayingBack )
		return NSZeroRect;
	
	if( _layerSettings != nil ) {
		[_paintEvents addObject:_layerSettings];
		[_layerSettings release];
		_layerSettings = nil;
	}
	[_paintEvents addObject:[aBrush settings]];
	[_paintEvents addObject:[[[DripEventBrushDown alloc] initWithPosition:NSMakePoint(aPoint.x,aPoint.y) pressure:aPoint.pressure] autorelease]];
	return [aBrush renderPointAt:aPoint onLayer:[_layers objectAtIndex:layerIndex]];
}
- (NSRect)drawAtPoint:(PressurePoint)aPoint withBrushOnCurrentLayer:(Brush *)aBrush
{
	if( _isPlayingBack )
		return NSZeroRect;
	
	if( _layerSettings != nil ) {
		[_paintEvents addObject:_layerSettings];
		[_layerSettings release];
		_layerSettings = nil;
	}
	[_paintEvents addObject:[aBrush settings]];
	[_paintEvents addObject:[[[DripEventBrushDown alloc] initWithPosition:NSMakePoint(aPoint.x,aPoint.y) pressure:aPoint.pressure] autorelease]];
	return [aBrush renderPointAt:aPoint onLayer:_currentLayer];
}
- (NSRect)drawLineFromPoint:(PressurePoint)startPoint toPoint:(PressurePoint *)endPoint withBrush:(Brush *)aBrush onLayer:(int)layerIndex;
{
	if( _isPlayingBack )
		return NSZeroRect;
	
	if( _layerSettings != nil ) {
		[_paintEvents addObject:_layerSettings];
		[_layerSettings release];
		_layerSettings = nil;
	}
	[_paintEvents addObject:[[[DripEventBrushDrag alloc] initWithPosition:NSMakePoint(endPoint->x,endPoint->y) pressure:endPoint->pressure] autorelease]];
	NSRect affectedRect = [aBrush renderLineFromPoint:startPoint toPoint:endPoint onLayer:[_layers objectAtIndex:layerIndex]];
	return affectedRect;
}
- (NSRect)drawLineFromPoint:(PressurePoint)startPoint toPoint:(PressurePoint *)endPoint withBrushOnCurrentLayer:(Brush *)aBrush;
{
	if( _isPlayingBack )
		return NSZeroRect;
	
	if( _layerSettings != nil ) {
		[_paintEvents addObject:_layerSettings];
		[_layerSettings release];
		_layerSettings = nil;
	}
	[_paintEvents addObject:[[[DripEventBrushDrag alloc] initWithPosition:NSMakePoint(endPoint->x,endPoint->y) pressure:endPoint->pressure] autorelease]];
	NSRect affectedRect = [aBrush renderLineFromPoint:startPoint toPoint:endPoint onLayer:_currentLayer];
	return affectedRect;
}

- (void)drawRect:(NSRect)aRect
{
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	
	[[NSColor whiteColor] set];
	NSRectFill(aRect);
	if( _bottomLayer )
		[_bottomLayer drawRect:aRect inContext:cxt];
	[_currentLayer drawRect:aRect inContext:cxt];
	if( _topLayer )
		[_topLayer drawRect:aRect inContext:cxt];
}

- (void)setDocument:(NSDocument *)newDocument
{
	if( newDocument == _document )
		return;
	
	[_document release];
	_document = [newDocument retain];
}
- (NSDocument *)document
{
	return _document;
}

- (void)currentLayerSettingsChanged;
{
	[_layerSettings release];
	_layerSettings = [[_currentLayer settings] retain];
}

@end
