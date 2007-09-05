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
	BOOL _pressureAffectsFlow;
	BOOL _pressureAffectsSize;
}

- (id)initWithType:(BrushType)theType size:(float)theSize hardness:(float)theHardness spacing:(float)theSpacing pressureAffectsFlow:(BOOL)willAffectFlow pressureAffectsSize:(BOOL)willAffectSize color:(NSColor *)theColor;

- (BrushType)type;
- (float)size;
- (float)hardness;
- (float)spacing;
- (BOOL)pressureAffectsFlow;
- (BOOL)pressureAffectsSize;
- (NSColor*)color;
@end