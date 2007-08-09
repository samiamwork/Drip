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
		
		_width = 0;
		_height = 0;
	}

	return self;
}

- (void)dealloc
{
	[_layers release];
	[_topLayer release];
	[_bottomLayer release];

	[super dealloc];
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
	}
	
	return self;
}

- (NSSize)size
{
	return NSMakeSize((float)_width,(float)_height);
}

- (void)addLayer
{
	unsigned int currentIndex = [_layers indexOfObject:_currentLayer];
	//assume that it exists
	if( currentIndex == NSNotFound ) {
		printf("currentLayer not found! Serious!\n");
		return;
	}

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
	
	[_layers removeObjectAtIndex:deleteIndex];
	
	if( deleteIndex != 0 )
		deleteIndex--;
	
	[self setCurrentLayer:[_layers objectAtIndex:deleteIndex]];
}

- (NSArray *)layers
{
	return [NSArray arrayWithArray:_layers];
}

- (void)setCurrentLayer:(PaintLayer *)aLayer
{
	if( aLayer == _currentLayer )
		return;
	
	unsigned int targetIndex = [_layers indexOfObject:aLayer];
	if( targetIndex == NSNotFound )
		return;
	
	[_bottomLayer release];
	_bottomLayer = nil;
	[_topLayer release];
	_topLayer = nil;
	_currentLayer = [_layers objectAtIndex:targetIndex];
	
	if( targetIndex > 0 )
		_bottomLayer = [[PaintLayer alloc] initWithContentsOfLayers:_layers inRange:NSMakeRange(0,targetIndex-1)];
	if( targetIndex < [_layers count]-1 )
		_topLayer = [[PaintLayer alloc] initWithContentsOfLayers:_layers inRange:NSMakeRange(targetIndex+1,[_layers count]-2)];
}

- (PaintLayer *)currentLayer
{
	return _currentLayer;
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
@end
