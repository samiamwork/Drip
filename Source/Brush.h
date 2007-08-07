//
//  Brush.h
//  Drip
//
//  Created by Nur Monson on 8/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PaintLayer.h"

typedef struct PressurePoint {
	float x;
	float y;
	float pressure;
} PressurePoint;

@interface Brush : NSObject {
	float _RGBAColor[4];
	float *_brushLookup;
	
	float _brushSize;
}

- (void)setSize:(float)newSize;
- (float)size;
- (void)setColor:(NSColor*)aColor;
- (NSColor*)color;

- (void)createBezierCurveWithCrossover:(float)crossover;

- (NSRect)renderPointAt:(PressurePoint)aPoint onLayer:(PaintLayer *)aLayer;
- (NSRect)renderLineFromPoint:(PressurePoint)startPoint toPoint:(PressurePoint *)endPoint onLayer:(PaintLayer *)aLayer;
@end
