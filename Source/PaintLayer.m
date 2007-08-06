//
//  PaintLayer.m
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "PaintLayer.h"


@implementation PaintLayer

- (id)init
{
	if( (self = [super init]) ) {
		_width = 0;
		_height = 0;
		_pitch = 0;
		_data = NULL;
		_cxt = NULL;
	}

	return self;
}

- (void)dealloc
{
	CGContextRelease(_cxt);
	if( _data != NULL )
		free( _data );

	[super dealloc];
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height
{
	if( (self = [super init]) ) {
		_width = width;
		_height = height;
		_data = calloc(_width*_height, 4);
		if( _data == NULL ) {
			[self release];
			return nil;
		}
		
		_pitch = _width*4;
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		_cxt = CGBitmapContextCreate(_data, _width, _height, 8, _pitch, colorSpace, kCGImageAlphaPremultipliedFirst);
		if(!_cxt) {
			[self release];
			return nil;
		}
		CGColorSpaceRelease(colorSpace);
		
		//TEMP: fill with white so we can see it
		CGContextSetRGBFillColor(_cxt,0.0f,1.0f,1.0f,1.0f);
		CGContextFillRect(_cxt,CGRectMake(0.0f,0.0f,(float)_width/2.0f,(float)_height));
		CGContextSetRGBFillColor(_cxt,1.0f,0.0f,1.0f,1.0f);
		CGContextFillRect(_cxt,CGRectMake((float)_width/2.0f,0.0f,(float)_width/2.0f,(float)_height));
		CGContextSetRGBStrokeColor(_cxt,0.0f,0.0f,0.0f,1.0f);
		CGContextStrokeRectWithWidth(_cxt,CGRectMake(0.0f,0.0f,(float)_width,(float)_height),2.0f);
	}
	
	return self;
}

- (id)initWithContentsOfLayers:(NSArray *)layers inRange:(NSRange)range
{
	if( (self = [super init]) ) {
		// we're just grabbing the first one we're passed and copying that
		//because we assume they're all the same size and we also want this
		//one to match.
		_width = [[layers objectAtIndex:range.location] width];
		_height = [[layers objectAtIndex:range.location] height];
		_data = calloc(_width*_height, 4);
		if( _data == NULL ) {
			[self release];
			return nil;
		}
		
		_pitch = _width*4;
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		_cxt = CGBitmapContextCreate(_data, _width, _height, 8, _pitch, colorSpace, kCGImageAlphaPremultipliedFirst);
		if(!_cxt) {
			[self release];
			return nil;
		}
		CGColorSpaceRelease(colorSpace);
		
		NSRect layerRect = NSMakeRect(0.0f,0.0f,(float)_width,(float)_height);
		unsigned int layerIndex;
		for( layerIndex = range.location; layerIndex <= range.location+range.length; layerIndex++ )
			[[layers objectAtIndex:layerIndex] drawRect:layerRect inContext:_cxt];

	}
	
	return self;
}

- (unsigned int)width
{
	return _width;
}
- (unsigned int)height
{
	return _height;
}
- (unsigned char *)data
{
	return _data;
}
- (unsigned int)pitch
{
	return _pitch;
}
- (CGContextRef)cxt
{
	return _cxt;
}

- (void)drawRect:(NSRect)aRect inContext:(CGContextRef)aContext
{
	CGColorSpaceRef colorSpace;
	CGImageRef cachedImage;
	CGContextRef cachedCxt;
	
	colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	cachedCxt = CGBitmapContextCreate(_data + (_height-(int)aRect.origin.y-1)*_pitch + (int)aRect.origin.x*4 - ((int)aRect.size.height-1)*_pitch,
									  (int)aRect.size.width,
									  (int)aRect.size.height,
									  8,
									  _pitch,
									  colorSpace,
									  kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorSpace);
	
	if(!cachedCxt) {
		printf("Could not create bitmap context!\n");
		// PROBLEM!
	}
	aRect.origin.x = (int)aRect.origin.x;
	aRect.origin.y = (int)aRect.origin.y;
	aRect.size.width = (int)aRect.size.width;
	aRect.size.height = (int)aRect.size.height;
	
	if((int)aRect.size.width == 0 || (int)aRect.size.height == 0)
		return;
	
	cachedImage = CGBitmapContextCreateImage(cachedCxt);
	if(!cachedImage) {
		printf("Could not create cached image!\n");
		return;
	}
	
	CGContextDrawImage(aContext, *(CGRect *)&aRect, cachedImage);
	CFRelease(cachedImage);
	CGContextRelease(cachedCxt);
}
@end
