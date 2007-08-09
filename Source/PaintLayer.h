//
//  PaintLayer.h
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PaintLayer : NSObject {
	unsigned int _width;
	unsigned int _height;
	unsigned int _pitch;
	unsigned char *_data;
	CGContextRef _cxt;
	
	NSString *_name;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;
- (id)initWithContentsOfLayers:(NSArray *)layers inRange:(NSRange)range;
- (unsigned int)width;
- (unsigned int)height;
- (unsigned char *)data;
- (unsigned int)pitch;
- (CGContextRef)cxt;

- (NSString *)name;
- (void)setName:(NSString *)newName;

- (void)drawRect:(NSRect)aRect inContext:(CGContextRef)aContext;
@end
