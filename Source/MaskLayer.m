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
	CGContextRef cachedCxt;
	
	aRect.origin.x = (int)aRect.origin.x;
	aRect.origin.y = (int)aRect.origin.y;
	aRect.size.width = (int)aRect.size.width;
	aRect.size.height = (int)aRect.size.height;
	
	if( NSIsEmptyRect(aRect) )
		return NULL;
	
	colorSpace = CGColorSpaceCreateDeviceGray();
	cachedCxt = CGBitmapContextCreate(_data + (_height-(int)aRect.origin.y-1)*_pitch + (int)aRect.origin.x - ((int)aRect.size.height-1)*_pitch,
									  //_height*_pitch - (((int)aRect.origin.y+(int)aRect.size.height)*_pitch + (_pitch - (int)aRect.origin.x*4)),
									  (int)aRect.size.width,
									  (int)aRect.size.height,
									  8,
									  _pitch,
									  colorSpace,
									  kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	if(!cachedCxt) {
		printf("Could not create bitmap context (mask)!\n");
		// PROBLEM!
		return NULL;
	}
	
	cachedImage = CGBitmapContextCreateImage(cachedCxt);
	if(!cachedImage) {
		printf("Could not create cached image!\n");
		return NULL;
	}
	
	CGContextRelease(cachedCxt);
	
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
