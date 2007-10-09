//
//  Layer.m
//  Drip
//
//  Created by Nur Monson on 10/3/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "Layer.h"


@implementation Layer

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if( ![encoder isKindOfClass:[NSKeyedArchiver class]] )
		return;
	
	NSKeyedArchiver *archiver = (NSKeyedArchiver *)encoder;
	[archiver encodeObject:_mainPaintLayer forKey:@"paintLayer"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if( (self = [super init]) ) {
		if( ![decoder isKindOfClass:[NSKeyedUnarchiver class]] ) {
			[self release];
			return nil;
		}
		
		_brushPaintLayers = [[NSMutableArray alloc] init];
		_brushMaskLayers = [[NSMutableArray alloc] init];
		
		_mainPaintLayer = [[decoder decodeObjectForKey:@"paintLayer"] retain];
		_mainMaskLayer = [[MaskLayer alloc] initWithWidth:[_mainPaintLayer width] height:[_mainPaintLayer height]];
	}
	
	return self;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;
{
	if( (self = [super init]) ) {
		_mainPaintLayer = [[PaintLayer alloc] initWithWidth:width height:height];
		_mainMaskLayer = [[MaskLayer alloc] initWithWidth:width height:height];
		
		_brushPaintLayers = [[NSMutableArray alloc] init];
		_brushMaskLayers = [[NSMutableArray alloc] init];
	}

	return self;
}

- (id)initWithContentsOfLayers:(NSArray *)layers inRange:(NSRange)range
{
	if( (self = [super init]) ) {
		NSMutableArray *paintLayers = [[NSMutableArray alloc] init];
		unsigned int layerIndex;
		for( layerIndex = range.location; layerIndex < range.location+range.length; layerIndex++ )
			[paintLayers addObject:[[layers objectAtIndex:layerIndex] mainPaintLayer]];
		
		_mainPaintLayer = [[PaintLayer alloc] initWithContentsOfLayers:paintLayers inRange:NSMakeRange(0,[paintLayers count])];
		_mainMaskLayer = [[MaskLayer alloc] initWithWidth:[_mainPaintLayer width] height:[_mainPaintLayer height]];
		
		_brushMaskLayers = [[NSMutableArray alloc] init];
		_brushPaintLayers = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[_mainPaintLayer release];
	[_mainMaskLayer release];
	
	[_brushPaintLayers release];
	[_brushMaskLayers release];

	[super dealloc];
}

- (void)setMainPaintLayer:(PaintLayer *)newPaintLayer
{
	if( newPaintLayer == _mainPaintLayer )
		return;
	
	[_mainPaintLayer release];
	_mainPaintLayer = [newPaintLayer retain];
	[_mainMaskLayer release];
	_mainMaskLayer = [[MaskLayer alloc] initWithWidth:[_mainPaintLayer width] height:[_mainPaintLayer height]];
}
- (PaintLayer *)mainPaintLayer
{
	return _mainPaintLayer;
}

- (void)attachLayer:(PaintLayer *)aLayer
{
	if( [aLayer isKindOfClass:[MaskLayer class]] )
		[_brushMaskLayers addObject:aLayer];
	else
		[_brushPaintLayers addObject:aLayer];
}
- (void)detachLayer:(PaintLayer *)aLayer
{
	if( [aLayer isKindOfClass:[MaskLayer class]] )
		[_brushMaskLayers removeObject:aLayer];
	else
		[_brushPaintLayers removeObject:aLayer];
}

- (void)commitLayer:(PaintLayer *)aLayer rect:(NSRect)aRect
{
	aRect = NSIntersectionRect(aRect,NSMakeRect(0.0f,0.0f,(float)[_mainPaintLayer width],(float)[_mainPaintLayer height]));
	// TODO:behave different if it is a mask
	if( [aLayer isKindOfClass:[MaskLayer class]] ) {
		
		[aLayer drawRect:aRect inContext:[_mainMaskLayer cxt]];
		CGImageRef cachedMask = [_mainMaskLayer getImageForRect:aRect];
		CGImageRef cachedImage = [_mainPaintLayer getImageForRect:aRect];
		CGImageRef maskedImage = CGImageCreateWithMask(cachedImage,cachedMask);
		CGContextClearRect( [_mainPaintLayer cxt],*(CGRect *)&aRect );
		CGContextDrawImage( [_mainPaintLayer cxt],*(CGRect *)&aRect, maskedImage);
		
		CGImageRelease( cachedMask );
		CGImageRelease( cachedImage );
		CGImageRelease( maskedImage );
		
		// clear the work layers
		CGContextSaveGState( [_mainMaskLayer cxt] );
		CGContextSetRGBFillColor( [_mainMaskLayer cxt], 1.0f,1.0f,1.0f,1.0f);
		CGContextFillRect([_mainMaskLayer cxt], *(CGRect *)&aRect);
		CGContextRestoreGState( [_mainMaskLayer cxt] );
		
		CGContextSaveGState( [aLayer cxt] );
		CGContextSetRGBFillColor([aLayer cxt],1.0f,1.0f,1.0f,1.0f);
		CGContextFillRect([aLayer cxt], *(CGRect *)&aRect);
		CGContextRestoreGState( [aLayer cxt] );
	} else {
		[aLayer drawRect:aRect inContext:[_mainPaintLayer cxt]];
		// clean up the working layer for the next stroke
		CGContextClearRect([aLayer cxt],*(CGRect *)&aRect);
	}
	

	[self detachLayer:aLayer];
}

- (void)drawRect:(NSRect)aRect inContext:(CGContextRef)aContext
{
	if( ![_mainPaintLayer visible] )
		return;
	
	//[_mainPaintLayer drawRect:aRect inContext:aContext];
	
	CGImageRef mainLayerImage = [_mainPaintLayer getImageForRect:aRect];
	NSEnumerator *layerEnumerator = [_brushMaskLayers objectEnumerator];
	MaskLayer *aMaskLayer;
	while( (aMaskLayer = [layerEnumerator nextObject]) )
		[aMaskLayer drawRect:aRect inContext:[_mainMaskLayer cxt]];

	CGImageRef newMaskImage = [_mainMaskLayer getImageForRect:aRect];
	CGImageRef newMaskedImage = CGImageCreateWithMask( mainLayerImage, newMaskImage );
	
	CGImageRelease( newMaskImage );
	CGImageRelease( mainLayerImage );
	CGContextDrawImage( aContext, *(CGRect *)&aRect, newMaskedImage );
	CGImageRelease( newMaskedImage );
	
	CGContextSaveGState( [_mainMaskLayer cxt] );
	CGContextSetRGBFillColor( [_mainMaskLayer cxt], 1.0f,1.0f,1.0f,1.0f);
	CGContextFillRect([_mainMaskLayer cxt], *(CGRect *)&aRect);
	CGContextRestoreGState( [_mainMaskLayer cxt] );
	
	layerEnumerator = [_brushPaintLayers objectEnumerator];
	PaintLayer *aLayer;
	while( (aLayer = [layerEnumerator nextObject]) )
		[aLayer drawRect:aRect inContext:aContext];
}

#pragma mark convenience methods

- (NSString *)name
{
	return [_mainPaintLayer name];
}
- (void)setName:(NSString *)newName
{
	[_mainPaintLayer setName:newName];
}
- (float)opacity
{
	return [_mainPaintLayer opacity];
}
- (void)setOpacity:(float)newOpacity
{
	[_mainPaintLayer setOpacity:newOpacity];
}
- (BOOL)visible
{
	return [_mainPaintLayer visible];
}
- (void)setVisible:(BOOL)isVisible
{
	[_mainPaintLayer setVisible:isVisible];
}
- (void)toggleVisible
{
	[_mainPaintLayer toggleVisible];
}
- (void)setBlendMode:(CGBlendMode)newBlendMode
{
	[_mainPaintLayer setBlendMode:newBlendMode];
}
- (CGBlendMode)blendMode
{
	return [_mainPaintLayer blendMode];
}

- (NSImage *)thumbnail
{
	return [_mainPaintLayer thumbnail];
}
- (void)updateThumbnail
{
	[_mainPaintLayer updateThumbnail];
}
@end
