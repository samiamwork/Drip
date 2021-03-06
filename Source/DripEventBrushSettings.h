//
//  DripEventBrushSettings.h
//  Drip
//
//  Created by Nur Monson on 9/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DripEventProtocol.h"
#import "Brush.h"

@interface DripEventBrushSettings : NSObject <DripEvent> {
	BrushType _type;
	float _RGBAColor[4];
	float _size;
	float _hardness;
	float _spacing;
	float _resaturation;
	float _strokeOpacity;
	CGBlendMode _blendMode;
	BOOL _pressureAffectsFlow;
	BOOL _pressureAffectsSize;
	BOOL _pressureAffectsResaturation;
}

- (id)initWithType:(BrushType)theType size:(float)theSize hardness:(float)theHardness spacing:(float)theSpacing resaturation:(float)theResaturation strokeOpacity:(float)theStrokeOpacity blendMode:(CGBlendMode)blendMode pressureAffectsFlow:(BOOL)willAffectFlow pressureAffectsSize:(BOOL)willAffectSize pressureAffectsResaturation:(BOOL)willAffectResaturation color:(NSColor *)theColor;
- (id)initWithBrush:(Brush *)theBrush;

- (BrushType)type;
- (float)size;
- (float)hardness;
- (float)spacing;
- (float)resaturation;
- (float)strokeOpacity;
- (CGBlendMode)blendMode;
- (BOOL)pressureAffectsFlow;
- (BOOL)pressureAffectsSize;
- (BOOL)pressureAffectsResaturation;
- (NSColor*)color;
@end
