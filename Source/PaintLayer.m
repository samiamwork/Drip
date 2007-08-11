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
		
		_name = [[NSString alloc] initWithString:@"Unnamed"];
	}

	return self;
}

- (void)dealloc
{
	CGContextRelease(_cxt);
	if( _data != NULL )
		free( _data );
	[_name release];

	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if( ![encoder isKindOfClass:[NSKeyedArchiver class]] )
		return;
	
	NSKeyedArchiver *archiver = (NSKeyedArchiver *)encoder;
	[archiver encodeInt32:(int)_width forKey:@"width"];
	[archiver encodeInt32:(int)_height forKey:@"height"];
	[archiver encodeObject:_name forKey:@"name"];
	[archiver encodeObject:[NSData dataWithBytes:_data length:_width*(_height+1)*4] forKey:@"data"];
	
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
		[self setName:[unarchiver decodeObjectForKey:@"name"]];
		
		_pitch = _width*4;
		_data = calloc(_width*(_height+1), 4);
		
		NSData *newData = [unarchiver decodeObjectForKey:@"data"];
		[newData getBytes:_data length:_width*(_height+1)*4];
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		_cxt = CGBitmapContextCreate(_data, _width, _height, 8, _pitch, colorSpace, kCGImageAlphaPremultipliedFirst);
		if(!_cxt) {
			[self release];
			return nil;
		}
		CGColorSpaceRelease(colorSpace);
	}
	
	return self;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height
{
	if( (self = [super init]) ) {
		_width = width;
		_height = height;
		//HACK: +1 to fix problem with creating image from sub-region of bitmapcontext
		_data = calloc(_width*(_height+1), 4);
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
		
		_name = [[NSString alloc] initWithString:@"Unnamed"];
	}
	
	return self;
}

- (id)initWithContentsOfLayers:(NSArray *)layers inRange:(NSRange)range
{
	if( (self = [super init]) ) {
		// we're just grabbing the first one we're passed and copying that
		//because we assume they're all the same size and we also want this
		//one to match.
		PaintLayer *sampleLayer = [layers objectAtIndex:range.location];
		_width = [sampleLayer width];
		_height = [sampleLayer height];
		
		_data = calloc(_width*(_height+1), 4);
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

		_name = [[NSString alloc] initWithString:@"Composite"];
	}
	
	return self;
}

- (NSString *)name
{
	return _name;
}
- (void)setName:(NSString *)newName
{
	if( newName == _name )
		return;
	
	[_name release];
	_name = [newName retain];
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
	
	aRect.origin.x = (int)aRect.origin.x;
	aRect.origin.y = (int)aRect.origin.y;
	aRect.size.width = (int)aRect.size.width;
	aRect.size.height = (int)aRect.size.height;
	
	colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	cachedCxt = CGBitmapContextCreate(_data + (_height-(int)aRect.origin.y-1)*_pitch + (int)aRect.origin.x*4 - ((int)aRect.size.height-1)*_pitch,
									  //_height*_pitch - (((int)aRect.origin.y+(int)aRect.size.height)*_pitch + (_pitch - (int)aRect.origin.x*4)),
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
