//
//  DripEventBrushSettings.h
//  Drip
//
//  Created by Nur Monson on 9/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DripEvent.h"


typedef enum BrushType {
	kBrushTypePaint = 1,
	kBrushTypeEraser
} BrushType;

@interface DripEventBrushSettings : DripEvent {
	BrushType _type;
	float _RGBAColor[4];
	float _size;
	float _hardness;
	float _spacing;
	float _resaturation;
	BOOL _pressureAffectsFlow;
	BOOL _pressureAffectsSize;
	BOOL _pressureAffectsResaturation;
}

- (id)initWithType:(BrushType)theType size:(float)theSize hardness:(float)theHardness spacing:(float)theSpacing resaturation:(float)theResaturation pressureAffectsFlow:(BOOL)willAffectFlow pressureAffectsSize:(BOOL)willAffectSize pressureAffectsResaturation:(BOOL)willAffectResaturation color:(NSColor *)theColor;

- (BrushType)type;
- (float)size;
- (float)hardness;
- (float)spacing;
- (float)resaturation;
- (BOOL)pressureAffectsFlow;
- (BOOL)pressureAffectsSize;
- (BOOL)pressureAffectsResaturation;
- (NSColor*)color;
@end
