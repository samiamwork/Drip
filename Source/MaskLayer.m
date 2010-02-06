//
//  MaskLayer.m
//  Drip
//
//  Created by Nur Monson on 10/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "MaskLayer.h"


@implementation MaskLayer

- (CGImageRef)getImageForRect:(NSRect)aRect
{
	CGColorSpaceRef colorSpace;
	CGImageRef cachedImage;
	
	aRect.origin.x = (int)aRect.origin.x;
	aRect.origin.y = (int)aRect.origin.y;
	aRect.size.width = (int)aRect.size.width;
	aRect.size.height = (int)aRect.size.height;
	if( NSIsEmptyRect(aRect) )
		return NULL;
	// Create the image
	colorSpace = CGColorSpaceCreateDeviceGray();
	int yStart = (_height-(int)aRect.origin.y-1) - ((int)aRect.size.height-1);
	int xStart = (int)aRect.origin.x;
	unsigned char* imageDataStart = _data + yStart*_pitch + xStart;
	size_t imageDataSize = (size_t)(_height*_pitch) - (size_t)(imageDataStart - _data);
	CGDataProviderRef directDataProvider = CGDataProviderCreateWithData(NULL, imageDataStart, imageDataSize, NULL);
	cachedImage = CGImageCreate((size_t)aRect.size.width,
								(size_t)aRect.size.height,
								8,
								8,
								_pitch,
								colorSpace,
								kCGImageAlphaNone,
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

- (BOOL)createBitmapContext
{
	//HACK: +1 to fix problem with creating image from sub-region of bitmapcontext
	_data = calloc(_width*(_height+1), 1);
	memset(_data, 255, _width*(_height+1));
	if( _data == NULL )
		return NO;
	
	_pitch = _width;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	_cxt = CGBitmapContextCreate(_data, _width, _height, 8, _pitch, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	if(!_cxt)
		return NO;
	
	return YES;
}

@end
