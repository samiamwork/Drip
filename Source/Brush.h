//
//  Brush.h
//  Drip
//
//  Created by Nur Monson on 8/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PaintLayer.h"
#import "DripEventBrushSettings.h"

typedef struct PressurePoint {
	float x;
	float y;
	float pressure;
} PressurePoint;

@interface Brush : NSObject {
	float _RGBAColor[4];
	float *_brushLookup;
	
	float _brushSize;
	float _hardness;
	float _spacing;
	BOOL _pressureAffectsFlow;
	BOOL _pressureAffectsSize;
	
	unsigned char *_dabData;
	CGImageRef _dab;
}

- (void)setSize:(float)newSize;
- (float)size;
- (void)setHardness:(float)newHardness;
- (float)hardness;
- (void)setSpacing:(float)newSpacing;
- (float)spacing;
- (void)setPressureAffectsFlow:(BOOL)willAffectFlow;
- (BOOL)pressureAffectsFlow;
- (void)setPressureAffectsSize:(BOOL)willAffectSize;
- (BOOL)pressureAffectsSize;
- (void)setColor:(NSColor*)aColor;
- (NSColor*)color;

- (void)createBezierCurveWithCrossover:(float)crossover;

- (void)drawDabAtPoint:(NSPoint)aPoint;

- (NSRect)renderPointAt:(PressurePoint)aPoint onLayer:(PaintLayer *)aLayer;
- (NSRect)renderLineFromPoint:(PressurePoint)startPoint toPoint:(PressurePoint *)endPoint onLayer:(PaintLayer *)aLayer;

- (void)changeSettings:(DripEventBrushSettings *)theSettings;
- (DripEventBrushSettings *)settings;
@end
