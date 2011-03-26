//
//  PaintLayer.m
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "PaintLayer.h"
#import "NSData+gzip.h"
#import "CheckerPattern.h"

@implementation PaintLayer

- (id)init
{
	if( (self = [super init]) ) {
		_width = 0;
		_height = 0;
		_pitch = 0;
		_opacity = 1.0f;
		_visible = YES;
		_blendMode = kCGBlendModeNormal;
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
	[archiver encodeInt32:_blendMode forKey:@"blendMode"];
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
		[self setBlendMode:[unarchiver decodeIntForKey:@"blendMode"]];
		
		_pitch = _width*4;
		_data = calloc(_width*(_height+1), 4);
		
		NSData *newData = [[unarchiver decodeObjectForKey:@"data"] gzipInflate];
		[newData getBytes:_data length:_width*(_height+1)*4];
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
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

- (BOOL)createBitmapContext
{
	//HACK: +1 to fix problem with creating image from sub-region of bitmapcontext
	_data = calloc(_width*(_height+1), 4);
	if( _data == NULL ) {
		[self release];
		return NO;
	}
	
	_pitch = _width*4;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	_cxt = CGBitmapContextCreate(_data, _width, _height, 8, _pitch, colorSpace, kCGImageAlphaPremultipliedFirst);
	if(!_cxt) {
		[self release];
		return NO;
	}
	CGColorSpaceRelease(colorSpace);
	
	return YES;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height
{
	if( (self = [super init]) ) {
		_width = width;
		_height = height;
		_opacity = 1.0f;
		_visible = YES;
		_blendMode = kCGBlendModeNormal;
		if( ![self createBitmapContext] ) {
			[self release];
			return nil;
		}
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
		if( ![self createBitmapContext] ) {
			[self release];
			return nil;
		}
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

- (void)setBlendMode:(CGBlendMode)newBlendMode
{
	_blendMode = newBlendMode;
}
- (CGBlendMode)blendMode
{
	return _blendMode;
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
/*
- (void)changeSettings:(DripEventLayerSettings *)newSettings
{
	[self setOpacity:[newSettings opacity]];
	[self setVisible:[newSettings visible]];
	[self setBlendMode:[newSettings blendMode]];
}
*/
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
		[_thumbnail setFlipped:YES];
		[self updateThumbnail];
	}
	
	return _thumbnail;
}
- (void)updateThumbnail
{
	[_thumbnail lockFocus];
	
	CGRect thumbRect;
	NSSize thumbSize = [_thumbnail size];
	thumbRect.size.width = thumbSize.width;
	thumbRect.size.height = thumbSize.height;
	thumbRect.origin.x = thumbRect.origin.y = 0.0f;
	
	CGContextRef thumbContext = [[NSGraphicsContext currentContext] graphicsPort];
	drawCheckerPatternInContextWithPhase( thumbContext, CGSizeZero, thumbRect, 5.0f );
	
	CGContextSetInterpolationQuality( thumbContext, kCGInterpolationNone );
	CGContextSaveGState( thumbContext );
	CGContextScaleCTM( thumbContext, thumbRect.size.width/(float)_width,thumbRect.size.width/(float)_width);
	[self drawRect:NSMakeRect(0.0f,0.0f,_width,_height) inContext:thumbContext];
	CGContextRestoreGState( thumbContext );
	
	[_thumbnail unlockFocus];
}

- (void)fillLayerWithColor:(NSColor *)aColor
{
	float red, green, blue, alpha;
	[[aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&red green:&green blue:&blue alpha:&alpha];
	CGContextSetRGBFillColor( _cxt, red,green,blue,alpha );
	CGContextFillRect( _cxt, CGRectMake(0.0f,0.0f,(float)_width,(float)_height));
}

- (CGRect)fillLayerWithImage:(CGImageRef )theImage
{
	// put the image in the center of the layer
	unsigned int imageWidth = CGImageGetWidth( theImage );
	unsigned int imageHeight = CGImageGetHeight( theImage );
	
	int dw = (_width - imageWidth)/2;
	int dh = (_height - imageHeight)/2;
	
	CGRect imageRect = CGRectMake( dw, dh, imageWidth, imageHeight );
	CGContextDrawImage( _cxt, imageRect, theImage );
	return imageRect;
}

- (CGImageRef)getImageForRect:(NSRect)aRect
{
	CGColorSpaceRef colorSpace;
	CGImageRef cachedImage;
	CGDataProviderRef directDataProvider;

	aRect.origin.x = (int)aRect.origin.x;
	aRect.origin.y = (int)aRect.origin.y;
	aRect.size.width = (int)aRect.size.width;
	aRect.size.height = (int)aRect.size.height;
	if( NSIsEmptyRect(aRect) )
		return NULL;
	// Create the image
	colorSpace = CGColorSpaceCreateDeviceRGB();
	int yStart = (_height-(int)aRect.origin.y-1) - ((int)aRect.size.height-1);
	int xStart = (int)aRect.origin.x;
	unsigned char* imageDataStart = _data + yStart*_pitch + xStart*4;
	size_t imageDataSize = (size_t)(_height*_pitch) - (size_t)(imageDataStart - _data);
	directDataProvider = CGDataProviderCreateWithData(NULL, imageDataStart, imageDataSize, NULL);
	cachedImage = CGImageCreate((size_t)aRect.size.width,
								(size_t)aRect.size.height,
								8,
								32,
								_pitch,
								colorSpace,
								kCGImageAlphaPremultipliedFirst,
								directDataProvider,
								NULL,  // Decode array
								false, // shouldInterpolate
								kCGRenderingIntentDefault);
	CGDataProviderRelease(directDataProvider);
	CGColorSpaceRelease(colorSpace);
	if(!cachedImage) {
		printf("Could not create cached image!\n");
		return NULL;
	}

	return cachedImage;
}

- (CGImageRef)getImageForRect:(NSRect)aRect withMask:(CGImageRef)theMask
{
	CGImageRef      selfImage;
	CGImageRef      maskedImage;
	CGImageRef      maskedBitmap;
	CGContextRef    bitmap;
	CGColorSpaceRef colorSpace;

	aRect = NSIntegralRect(aRect);

	colorSpace  = CGColorSpaceCreateDeviceRGB();
	selfImage   = [self getImageForRect:aRect];
	maskedImage = CGImageCreateWithMask(selfImage, theMask);
	bitmap      = CGBitmapContextCreate(NULL, aRect.size.width, aRect.size.height, 8, 4*aRect.size.width, colorSpace, kCGImageAlphaPremultipliedFirst);
	CGContextDrawImage(bitmap, CGRectMake(0.0, 0.0, aRect.size.width, aRect.size.height), maskedImage);
	maskedBitmap = CGBitmapContextCreateImage(bitmap);

	CGContextRelease(bitmap);
	CGImageRelease(selfImage);
	CGImageRelease(maskedImage);
	CGColorSpaceRelease(colorSpace);

	return maskedBitmap;
}

- (void)drawRect:(NSRect)aRect inContext:(CGContextRef)aContext
{
	aRect = NSIntersectionRect(aRect,NSMakeRect(0.0f,0.0f,_width,_height));
	if( !_visible )
		return;
	
	CGImageRef cachedImage = [self getImageForRect:aRect];
	if( !cachedImage )
		return;
	
	CGContextSaveGState(aContext);
	CGContextSetAlpha(aContext,_opacity);
	CGContextSetBlendMode(aContext,_blendMode);
	CGContextDrawImage(aContext, *(CGRect *)&aRect, cachedImage);
	CGContextRestoreGState(aContext);

	CFRelease(cachedImage);
}
@end
