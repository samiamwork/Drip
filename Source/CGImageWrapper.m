//
//  CGImageWrapper.m
//  Drip
//
//  Created by Nur Monson on 1/30/08.
//  Copyright 2008 theidiotproject. All rights reserved.
//

#import "CGImageWrapper.h"


@implementation CGImageWrapper
- (id)init
{
	if( (self = [super init]) ) {
		[self release];
		return nil;
	}

	return self;
}
- (id)initWithImage:(CGImageRef)theImage
{
	if( (self = [super init]) )
		_image = CGImageRetain(theImage);
	
	return self;
}

- (void)dealloc
{
	CGImageRelease( _image );
	[super dealloc];
}

- (CGImageRef)image
{
	return _image;
}
@end
