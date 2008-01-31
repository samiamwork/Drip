//
//  Brush.h
//  Drip
//
//  Created by Nur Monson on 8/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PaintLayer.h"
#import "Layer.h"

typedef enum BrushType {
	kBrushTypePaint = 1,
	kBrushTypeEraser
} BrushType;

extern NSString *const kPaintBrushSizeKey;
extern NSString *const kPaintBrushHardnessKey;
extern NSString *const kPaintBrushSpacingKey;
extern NSString *const kPaintBrushResaturationKey;
extern NSString *const kPaintBrushOpacityKey;
extern NSString *const kPaintBrushPressureAffectsSizeKey;
extern NSString *const kPaintBrushPressureAffectsFlowKey;
extern NSString *const kPaintBrushPressureAffectsResaturationKey;
extern NSString *const kPaintBrushColorKey;


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
	
	NSMutableArray *_strokeEvents;
	
	float _brushSize;
	float _intSize;
	float _hardness;
	float _spacing;
	float _strokeOpacity;
	CGBlendMode _blendMode;
	BOOL _pressureAffectsFlow;
	BOOL _pressureAffectsSize;
	unsigned char *_dabData;
	CGImageRef _dab;
	
	PaintLayer *_workLayer;
	NSRect _strokeRect;
	//
	BOOL _settingsHaveChanged;
}

- (void)setCanvasSize:(NSSize)newCanvasSize;
- (void)setSize:(float)newSize;
- (float)size;
- (BOOL)usesSize;
- (void)setHardness:(float)newHardness;
- (float)hardness;
- (BOOL)usesHardness;
- (void)setSpacing:(float)newSpacing;
- (float)spacing;
- (BOOL)usesSpacing;
- (void)setResaturation:(float)newResaturation;
- (float)resaturation;
- (BOOL)usesResaturation;
- (void)setStrokeOpacity:(float)newStrokeOpacity;
- (float)strokeOpacity;
- (BOOL)usesStrokeOpacity;
- (void)setBlendMode:(CGBlendMode)newBlendMode;
- (CGBlendMode)blendMode;
- (BOOL)usesBlendMode;
- (void)setPressureAffectsFlow:(BOOL)willAffectFlow;
- (BOOL)pressureAffectsFlow;
- (BOOL)usesPressureAffectsFlow;
- (void)setPressureAffectsSize:(BOOL)willAffectSize;
- (BOOL)pressureAffectsSize;
- (BOOL)usesPressureAffectsSize;
- (void)setPressureAffectsResaturation:(BOOL)willAffectResaturation;
- (BOOL)pressureAffectsResaturation;
- (BOOL)usesPressureAffectsResaturation;
- (void)setColor:(NSColor*)aColor;
- (NSColor*)color;
- (BOOL)usesColor;

- (BrushType)type;


- (void)drawDabAtPoint:(NSPoint)aPoint;

- (NSRect)beginStrokeAtPoint:(PressurePoint)aPoint onLayer:(Layer *)aLayer;
- (NSRect)continueStrokeAtPoint:(PressurePoint)aPoint;
- (NSRect)endStroke;
// returns an array of all stored stroke data and removes it from the internal store.
// if you want to keep the data around you need to retain it.
- (NSArray*)popStrokeEvents;

- (NSRect)renderPointAt:(PressurePoint)aPoint onLayer:(PaintLayer *)aLayer;
- (NSRect)renderLineFromPoint:(PressurePoint)startPoint toPoint:(PressurePoint *)endPoint onLayer:(PaintLayer *)aLayer leftover:(float *)leftoverDistance;

// returns TRUE if the settings have changed since the last time this method was called
// and FALSE otherwise.
// returns TRUE the first time it's called.
// TODO: how does undo affect this method's behavior?
- (BOOL)didSettingsChange;
- (void)saveSettings;
- (void)loadSettings;
@end
