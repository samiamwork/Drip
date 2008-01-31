//
//  CGImageWrapper.h
//  Drip
//
//  Created by Nur Monson on 1/30/08.
//  Copyright 2008 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CGImageWrapper : NSObject {
	CGImageRef _image;
}

- (id)initWithImage:(CGImageRef)theImage;
- (CGImageRef)image;
@end
