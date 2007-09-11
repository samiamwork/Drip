//
//  PaintLayer.m
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "PaintLayer.h"
#import "NSData+gzip.h"

@implementation PaintLayer

- (id)init
{
	if( (self = [super init]) ) {
		_width = 0;
		_height = 0;
		_pitch = 0;
		_opacity = 1.0f;
		_visible = YES;
		_data = NULL;
		_cxt = NULL;
		
		_thumbnail = nil;
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
	[_thumbnail release];

	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	if( ![encoder isKindOfClass:[NSKeyedArchiver class]] )
		return;
	
	NSKeyedArchiver *archiver = (NSKeyedArchiver *)encoder;
	[archiver encodeInt32:(int)_width forKey:@"width"];
	[archiver encodeInt32:(int)_height forKey:@"height"];
	[archiver encodeFloat:_opacity forKey:@"opacity"];
	[archiver encodeBool:_visible forKey:@"visible"];
	[archiver encodeObject:_name forKey:@"name"];
	NSData *compressedData = [[NSData dataWithBytes:_data length:_width*(_height+1)*4] gzipDeflate];
	[archiver encodeObject:compressedData forKey:@"data"];
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
		[self setOpacity:[unarchiver decodeFloatForKey:@"opacity"]];
		[self setVisible:[unarchiver decodeBoolForKey:@"visible"]];
		
		_pitch = _width*4;
		_data = calloc(_width*(_height+1), 4);
		
		NSData *newData = [[unarchiver decodeObjectForKey:@"data"] gzipInflate];
		[newData getBytes:_data length:_width*(_height+1)*4];
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
		_cxt = CGBitmapContextCreate(_data, _width, _height, 8, _pitch, colorSpace, kCGImageAlphaPremultipliedFirst);
		if(!_cxt) {
			[self release];
			return nil;
		}
		CGColorSpaceRelease(colorSpace);
		CGContextSetInterpolationQuality(_cxt,kCGInterpolationHigh);
	}
	
	return self;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height
{
	if( (self = [super init]) ) {
		_width = width;
		_height = height;
		_opacity = 1.0f;
		_visible = YES;
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
		CGContextSetInterpolationQuality(_cxt,kCGInterpolationHigh);
		
		_thumbnail = nil;
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
		_opacity = 1.0f;
		_visible = YES;
		
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
		CGContextSetInterpolationQuality(_cxt,kCGInterpolationHigh);
		
		NSRect layerRect = NSMakeRect(0.0f,0.0f,(float)_width,(float)_height);
		unsigned int layerIndex;
		for( layerIndex = range.location; layerIndex < range.location+range.length; layerIndex++ )
			[[layers objectAtIndex:layerIndex] drawRect:layerRect inContext:_cxt];

		_thumbnail = nil;
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

- (float)opacity
{
	return _opacity;
}
- (void)setOpacity:(float)newOpacity
{
	if( newOpacity < 0.0f )
		newOpacity = 0.0f;
	else if( newOpacity > 1.0f )
		newOpacity = 1.0f;
	
	if( newOpacity == _opacity )
		return;
	
	_opacity = newOpacity;
}

- (BOOL)visible
{
	return _visible;
}
- (void)setVisible:(BOOL)isVisible
{
	_visible = isVisible;
}
- (void)toggleVisible
{
	if( _visible )
		[self setVisible:NO];
	else
		[self setVisible:YES];
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

- (void)changeSettings:(DripEventLayerSettings *)newSettings
{
	[self setOpacity:[newSettings opacity]];
	[self setVisible:[newSettings visible]];
}

- (NSImage *)thumbnail
{
	if( _thumbnail == nil ) {
		// max thumbnail size of 50x50
		NSSize thumbSize = NSMakeSize(50.0f,50.0f);
		if( _width > _height )
			thumbSize.height = ((float)_height*50.0f)/(float)_width;
		else if( _width < _height )
			thumbSize.width = ((float)_width*50.0f)/(float)_height;

		_thumbnail = [[NSImage alloc] initWithSize:thumbSize];
		[self updateThumbnail];
	}
	
	return _thumbnail;
}
- (void)updateThumbnail
{
	[_thumbnail lockFocus];
	
	CGRect thumbRect;
	thumbRect.size.width = [_thumbnail size].width;
	thumbRect.size.height = [_thumbnail size].height;
	thumbRect.origin.x = thumbRect.origin.y = 0.0f;
	
	CGContextRef thumbContext = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetRGBFillColor(thumbContext,1.0f,1.0f,1.0f,1.0f);
	CGContextFillRect( thumbContext, thumbRect );
	
	CGContextSetInterpolationQuality( thumbContext, kCGInterpolationNone );
	CGContextSaveGState( thumbContext );
	CGContextScaleCTM( thumbContext, thumbRect.size.width/(float)_width,thumbRect.size.width/(float)_width);
	[self drawRect:NSMakeRect(0.0f,0.0f,_width,_height) inContext:thumbContext];
	CGContextRestoreGState( thumbContext );
	
	[_thumbnail unlockFocus];
}

- (void)drawRect:(NSRect)aRect inContext:(CGContextRef)aContext
{
	if( !_visible )
		return;
	
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
	
	CGContextSaveGState(aContext);
	CGContextSetAlpha(aContext,_opacity);
	CGContextDrawImage(aContext, *(CGRect *)&aRect, cachedImage);
	CGContextRestoreGState(aContext);
	CFRelease(cachedImage);
	CGContextRelease(cachedCxt);
}
@end
