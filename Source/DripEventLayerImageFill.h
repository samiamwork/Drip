//
//  DripEventLayerImageFill.h
//  Drip
//
//  Created by Nur Monson on 12/3/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <Quartz/Quartz.h>
#import "DripEventProtocol.h"


@interface DripEventLayerImageFill : NSObject <DripEvent> {
	NSData *_imageData;
	CGImageRef _image;
	
	NSMutableData *_imageDataLoading;
	unsigned int _imageBytesNeeded;
}

- (id)initWithImageData:(NSData *)theImageData;
- (id)initWithImageDataLength:(unsigned int)theImageDataLength;
- (CGImageRef)image;
@end
