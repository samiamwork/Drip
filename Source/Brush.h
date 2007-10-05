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
#import "Layer.h"

typedef struct PressurePoint {
	float x;
	float y;
	float pressure;
} PressurePoint;

@interface Brush : NSObject {
	float _RGBAColor[4];
	float *_brushLookup;
	
	float _resaturation;
	BOOL _pressureAffectsResaturation;
	float _resatColor[3];
	float _leftoverDistance;
	PressurePoint _lastBrushPosition;
	Layer *_paintingLayer;
	
	float _brushSize;
	float _intSize;
	float _hardness;
	float _spacing;
	BOOL _pressureAffectsFlow;
	BOOL _pressureAffectsSize;
	unsigned char *_dabData;
	CGImageRef _dab;
	
	PaintLayer *_workLayer;
	NSRect _strokeRect;
}

- (void)setCanvasSize:(NSSize)newCanvasSize;
- (void)setSize:(float)newSize;
- (float)size;
- (void)setHardness:(float)newHardness;
- (float)hardness;
- (void)setSpacing:(float)newSpacing;
- (float)spacing;
- (void)setResaturation:(float)newResaturation;
- (float)resaturation;
- (void)setPressureAffectsFlow:(BOOL)willAffectFlow;
- (BOOL)pressureAffectsFlow;
- (void)setPressureAffectsSize:(BOOL)willAffectSize;
- (BOOL)pressureAffectsSize;
- (void)setPressureAffectsResaturation:(BOOL)willAffectResaturation;
- (BOOL)pressureAffectsResaturation;
- (void)setColor:(NSColor*)aColor;
- (NSColor*)color;

- (void)createBezierCurveWithCrossover:(float)crossover;

- (void)drawDabAtPoint:(NSPoint)aPoint;

- (NSRect)beginStrokeAtPoint:(PressurePoint)aPoint onLayer:(Layer *)aLayer;
- (NSRect)continueStrokeAtPoint:(PressurePoint)aPoint;
- (void)endStroke;

- (NSRect)renderPointAt:(PressurePoint)aPoint onLayer:(PaintLayer *)aLayer;
- (NSRect)renderLineFromPoint:(PressurePoint)startPoint toPoint:(PressurePoint *)endPoint onLayer:(PaintLayer *)aLayer leftover:(float *)leftoverDistance;

- (void)changeSettings:(DripEventBrushSettings *)theSettings;
- (DripEventBrushSettings *)settings;
@end
