//
//  PaintLayer.h
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PaintLayer : NSObject <NSCoding> {
	unsigned int _width;
	unsigned int _height;
	unsigned int _pitch;
	float _opacity;
	BOOL _visible;
	CGBlendMode _blendMode;
	
	unsigned char *_data;
	CGContextRef _cxt;
	
	NSString *_name;
	NSImage *_thumbnail;
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
- (float)opacity;
- (void)setOpacity:(float)newOpacity;
- (BOOL)visible;
- (void)setVisible:(BOOL)isVisible;
- (void)toggleVisible;
- (void)setBlendMode:(CGBlendMode)newBlendMode;
- (CGBlendMode)blendMode;

- (CGImageRef)getImageForRect:(NSRect)aRect;
- (CGImageRef)getImageForRect:(NSRect)aRect withMask:(CGImageRef)theMask;
- (void)drawRect:(NSRect)aRect inContext:(CGContextRef)aContext;

//- (DripEventLayerSettings *)settings;
//- (void)changeSettings:(DripEventLayerSettings *)newSettings;

- (NSImage *)thumbnail;
- (void)updateThumbnail;

- (void)fillLayerWithColor:(NSColor *)aColor;
- (CGRect)fillLayerWithImage:(CGImageRef )theImage;
@end
