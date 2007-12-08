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
		CGContextSetInterpolationQuality( [_mainPaintLayer cxt], kCGInterpolationNone );
		_scratchMaskLayer = [[MaskLayer alloc] initWithWidth:[_mainPaintLayer width] height:[_mainPaintLayer height]];
		CGContextSetInterpolationQuality( [_scratchMaskLayer cxt], kCGInterpolationNone );
		_scratchPaintLayer = [[PaintLayer alloc] initWithWidth:[_mainPaintLayer width] height:[_mainPaintLayer height]];
		CGContextSetInterpolationQuality( [_scratchPaintLayer cxt], kCGInterpolationNone );
	}
	
	return self;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;
{
	if( (self = [super init]) ) {
		_mainPaintLayer = [[PaintLayer alloc] initWithWidth:width height:height];
		CGContextSetInterpolationQuality( [_mainPaintLayer cxt], kCGInterpolationNone );
		_scratchMaskLayer = [[MaskLayer alloc] initWithWidth:width height:height];
		CGContextSetInterpolationQuality( [_scratchMaskLayer cxt], kCGInterpolationNone );
		_scratchPaintLayer = [[PaintLayer alloc] initWithWidth:[_mainPaintLayer width] height:[_mainPaintLayer height]];
		CGContextSetInterpolationQuality( [_scratchPaintLayer cxt], kCGInterpolationNone );
		
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
		_scratchMaskLayer = [[MaskLayer alloc] initWithWidth:[_mainPaintLayer width] height:[_mainPaintLayer height]];
		_scratchPaintLayer = [[PaintLayer alloc] initWithWidth:[_mainPaintLayer width] height:[_mainPaintLayer height]];
		
		_brushMaskLayers = [[NSMutableArray alloc] init];
		_brushPaintLayers = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[_scratchPaintLayer release];
	[_mainPaintLayer release];
	[_scratchMaskLayer release];
	
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
	[_scratchMaskLayer release];
	_scratchMaskLayer = [[MaskLayer alloc] initWithWidth:[_mainPaintLayer width] height:[_mainPaintLayer height]];
	[_scratchPaintLayer release];
	_scratchPaintLayer = [[PaintLayer alloc] initWithWidth:[_mainPaintLayer width] height:[_mainPaintLayer height]];
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

	if( [aLayer isKindOfClass:[MaskLayer class]] ) {
		
		[aLayer drawRect:aRect inContext:[_scratchMaskLayer cxt]];
		CGImageRef cachedMask = [_scratchMaskLayer getImageForRect:aRect];
		CGImageRef cachedImage = [_mainPaintLayer getImageForRect:aRect];
		CGImageRef maskedImage = CGImageCreateWithMask(cachedImage,cachedMask);
		CGContextClearRect( [_mainPaintLayer cxt],*(CGRect *)&aRect );
		CGContextDrawImage( [_mainPaintLayer cxt],*(CGRect *)&aRect, maskedImage);
		
		CGImageRelease( cachedMask );
		CGImageRelease( cachedImage );
		CGImageRelease( maskedImage );
		
		// clear the work layers
		CGContextSaveGState( [_scratchMaskLayer cxt] );
		CGContextSetRGBFillColor( [_scratchMaskLayer cxt], 1.0f,1.0f,1.0f,1.0f);
		CGContextFillRect([_scratchMaskLayer cxt], *(CGRect *)&aRect);
		CGContextRestoreGState( [_scratchMaskLayer cxt] );
		
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
	
	NSEnumerator *layerEnumerator;
	
	// composite all mask layers together and mask the main layer with the composite mask
	CGImageRef mainLayerImage = [_mainPaintLayer getImageForRect:aRect];
	if( [_brushMaskLayers count] == 0 ) {
		CGContextSaveGState( aContext );
		CGContextSetAlpha( aContext, [_scratchPaintLayer opacity] );
		CGContextDrawImage( aContext, *(CGRect *)&aRect, mainLayerImage );
		CGContextRestoreGState( aContext );
	} else {
		layerEnumerator = [_brushMaskLayers objectEnumerator];
		MaskLayer *aMaskLayer;
		while( (aMaskLayer = [layerEnumerator nextObject]) )
			[aMaskLayer drawRect:aRect inContext:[_scratchMaskLayer cxt]];

		CGImageRef newMaskImage = [_scratchMaskLayer getImageForRect:aRect];
		CGImageRef newMaskedImage = CGImageCreateWithMask( mainLayerImage, newMaskImage );
		
		CGImageRelease( newMaskImage );
		CGImageRelease( mainLayerImage );
		CGContextDrawImage( [_scratchPaintLayer cxt], *(CGRect *)&aRect, newMaskedImage );
		CGImageRelease( newMaskedImage );
		
		// clear mask layer
		CGContextSaveGState( [_scratchMaskLayer cxt] );
		CGContextSetRGBFillColor( [_scratchMaskLayer cxt], 1.0f,1.0f,1.0f,1.0f);
		CGContextFillRect([_scratchMaskLayer cxt], *(CGRect *)&aRect);
		CGContextRestoreGState( [_scratchMaskLayer cxt] );
	}
	
	if( [_brushPaintLayers count] != 0 ) {
		layerEnumerator = [_brushPaintLayers objectEnumerator];
		PaintLayer *aLayer;
		while( (aLayer = [layerEnumerator nextObject]) )
			[aLayer drawRect:aRect inContext:[_scratchPaintLayer cxt]];
		[_scratchPaintLayer drawRect:aRect inContext:aContext];
		
		// clear scratch layer
		CGContextClearRect( [_scratchPaintLayer cxt], *(CGRect *)&aRect );
	}
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
	[_scratchPaintLayer setOpacity:newOpacity];
}
- (BOOL)visible
{
	return [_mainPaintLayer visible];
}
- (void)setVisible:(BOOL)isVisible
{
	[_mainPaintLayer setVisible:isVisible];
	[_scratchPaintLayer setVisible:isVisible];
}
- (void)toggleVisible
{
	[_mainPaintLayer toggleVisible];
}
- (void)setBlendMode:(CGBlendMode)newBlendMode
{
	[_mainPaintLayer setBlendMode:newBlendMode];
	[_scratchPaintLayer setBlendMode:newBlendMode];
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

- (void)fillLayerWithColor:(NSColor *)aColor
{
	[_mainPaintLayer fillLayerWithColor:aColor];
}

- (CGRect)fillLayerWithImage:(CGImageRef )theImage
{
	return [_mainPaintLayer fillLayerWithImage:theImage];
}
/*
- (void)changeSettings:(DripEventLayerSettings *)newSettings
{
	[self setOpacity:[newSettings opacity]];
	[self setVisible:[newSettings opacity]];
	[self setBlendMode:[newSettings blendMode]];
}
 */
@end
