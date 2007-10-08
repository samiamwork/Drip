//
//  Layer.h
//  Drip
//
//  Created by Nur Monson on 10/3/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PaintLayer.h"
#import "MaskLayer.h"

@interface Layer : NSObject {
	PaintLayer *_mainPaintLayer;
	MaskLayer *_mainMaskLayer;
	
	NSMutableArray *_brushPaintLayers;
	NSMutableArray *_brushMaskLayers;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;
- (id)initWithContentsOfLayers:(NSArray *)layers inRange:(NSRange)range;

- (void)setMainPaintLayer:(PaintLayer *)newPaintLayer;
- (PaintLayer *)mainPaintLayer;

- (void)attachLayer:(PaintLayer *)aLayer;
- (void)detachLayer:(PaintLayer *)aLayer;
- (void)commitLayer:(PaintLayer *)aLayer rect:(NSRect)aRect;
- (void)drawRect:(NSRect)aRect inContext:(CGContextRef)aContext;

- (NSString *)name;
- (void)setName:(NSString *)newName;
- (float)opacity;
- (void)setOpacity:(float)newOpacity;
- (BOOL)visible;
- (void)setVisible:(BOOL)isVisible;
- (void)toggleVisible;
- (void)setBlendMode:(CGBlendMode)newBlendMode;
- (CGBlendMode)blendMode;

- (NSImage *)thumbnail;
- (void)updateThumbnail;
@end