//
//  TIPBrush.h
//  sketchChat
//
//  Created by Nur Monson on 3/25/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPPressurePoint.h"
#import "TIPLayer.h"

/*!
    @class
    @abstract    The base brush class for drawing
    @discussion  This class manages brush settings and rendering behavior for a brush.
	subclass this class to create a brush with different behavior.
*/


@interface TIPBrush : NSObject {
	float bezierCoordinates[1000+1];
	float mainSize;
	float tipSize;
	BOOL pressureAffectsOpacity;
	BOOL pressureAffectsSize;
	BOOL smooth;
}

- (void)changeBrushWithMainSize:(float)mSize TipSize:(float)tSize;
- (NSRect)renderPointAt:(TIPPressurePoint)loc OnLayer:(TIPLayer*)l WithColor:(float*)rgba;
- (NSRect)renderLineFrom:(TIPPressurePoint)start To:(TIPPressurePoint*)end OnLayer:(TIPLayer*)l WithColor:(float*)rgba;

- (int)brushSize;
- (float*)brushLookup;

- (BOOL)pressureAffectsOpacity;
- (BOOL)pressureAffectsSize;
- (void)setPressureAffectsOpacity:(BOOL)state;
- (void)setPressureAffectsSize:(BOOL)state;

- (float)mainSize;
- (void)setMainSize:(float)size;
- (float)tipSize;
- (void)setTipSize:(float)size;
- (BOOL)smooth;
- (void)setSmooth:(BOOL)b;

@end
