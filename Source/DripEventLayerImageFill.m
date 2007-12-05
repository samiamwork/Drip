//
//  DripEventLayerImageFill.m
//  Drip
//
//  Created by Nur Monson on 12/3/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEventLayerImageFill.h"


@implementation DripEventLayerImageFill

- (id)init
{
	if( (self = [super init]) ) {
		_imageData = nil;
		_imageDataLoading = nil;
		_imageBytesNeeded = 0;
		_image = NULL;
	}

	return self;
}

- (void)dealloc
{
	[_imageData release];
	[_imageDataLoading release];
	CGImageRelease( _image );

	[super dealloc];
}

- (void)loadImage
{
	if( !_imageData )
		return;
	
	CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)_imageData, NULL);
	if( !imageSource )
		return;
	
	_image = CGImageSourceCreateImageAtIndex(imageSource, 0,  NULL);
	CFRelease(imageSource);
}

- (id)initWithImageData:(NSData *)theImageData
{
	if( (self = [self init]) ) {
		if( !theImageData ) {
			[self release];
			return nil;
		}
		
		_imageData = [theImageData retain];
		[self loadImage];
		if( !_image ) {
			[self release];
			return nil;
		}
	}

	return self;
}

- (id)initWithImageDataLength:(unsigned int)theImageDataLength
{
	if( (self = [self init]) ) {
		_imageBytesNeeded = theImageDataLength;
		_imageDataLoading = [[NSMutableData alloc] init];
	}
	
	return self;
}

- (CGImageRef)image
{
	return _image;
}

#pragma mark DripEvent Protocol

#define EVENT_LENGTH (EVENT_HEADER_LENGTH+sizeof(unsigned int))
+ (id)eventWithBytes:(void *)bytes length:(unsigned int)length
{
	unsigned char eventLength = *(unsigned char *)bytes;
	bytes++;
	if( eventLength != EVENT_LENGTH || eventLength > length || *(unsigned char *)bytes != kDripEventLayerImageFill )
		return nil;
	bytes++;
	
	unsigned int dataLength = CFSwapInt32BigToHost( *(UInt32 *)bytes );
	
	return [[[DripEventLayerImageFill alloc] initWithImageDataLength:dataLength] autorelease];
}

- (unsigned int)length
{
	return EVENT_LENGTH;
}

- (unsigned int)bytesNeeded
{
	return _imageBytesNeeded;
}

- (unsigned int)addBytes:(void *)bytes length:(unsigned int)length
{
	unsigned int bytesToCopy = _imageBytesNeeded;
	
	if(length < _imageBytesNeeded) {
		bytesToCopy = length;
		_imageBytesNeeded -= length;
	} else
		_imageBytesNeeded = 0;
	
	[_imageDataLoading appendBytes:bytes length:bytesToCopy];
	
	if( !_imageBytesNeeded ) {
		// no need to copy the data, just assigne it to the non-mutable variable and be done
		[_imageData release];
		_imageData = _imageDataLoading;
		_imageDataLoading = NULL;
		
		[self loadImage];
	}
	
	return bytesToCopy;
}

- (NSData *)data
{
	if( _imageDataLoading )
		return nil;
	
	if( !_image && _imageData )
		[self loadImage];
	if( !_image )
		return nil;
	
	
	
	// Compress the image as png data and return the smaller of the two: PNG or original.
	NSMutableData *pngData = [[NSMutableData alloc] init];
	CGImageDestinationRef imageDest = CGImageDestinationCreateWithData((CFMutableDataRef)pngData, CFSTR("public.png"), 1, NULL);
	CGImageDestinationAddImage( imageDest, _image, NULL);
	CGImageDestinationFinalize( imageDest );
	CFRelease( imageDest );
	
	if( [pngData length] < [_imageData length] && [pngData length] != 0 ) {
		[_imageData release];
		_imageData = pngData;
	} else
		[pngData release];
	
	unsigned int totalEventLength = EVENT_LENGTH + [_imageData length];
	unsigned char *bytes = (unsigned char*)malloc( totalEventLength );
	*bytes = EVENT_LENGTH;
	
	unsigned char *ptr = bytes;
	ptr++;
	*ptr = kDripEventLayerImageFill;
	ptr++;
	*(UInt32 *)ptr = CFSwapInt32HostToBig( [_imageData length] );
	ptr += sizeof(UInt32);
	
	memcpy(ptr, [_imageData bytes], [_imageData length]);
	NSData *theData = [NSData dataWithBytesNoCopy:bytes length:totalEventLength];
	return theData;
}

- (NSRect)runWithCanvas:(Canvas *)theCanvas artist:(Artist *)theArtist
{
	CGRect affectedRect = [theCanvas fillCurrentLayerWithImage:_imageData];
	return *(NSRect *)&affectedRect;
}

@end
