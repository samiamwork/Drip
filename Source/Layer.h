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
	PaintLayer *_scratchPaintLayer;
	MaskLayer *_scratchMaskLayer;
	PaintLayer *_mainPaintLayer;
	
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

//- (void)changeSettings:(DripEventLayerSettings *)newSettings;

- (NSImage *)thumbnail;
- (void)updateThumbnail;
- (void)fillLayerWithColor:(NSColor *)aColor;
- (CGRect)fillLayerWithImage:(CGImageRef )theImage;
@end
