//
//  BrushEraser.h
//  Drip
//
//  Created by Nur Monson on 8/7/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Brush.h"

extern NSString *const kEraserBrushSizeKey;
extern NSString *const kEraserBrushHardnessKey;
extern NSString *const kEraserBrushSpacingKey;
extern NSString *const kEraserBrushOpacityKey;
extern NSString *const kEraserBrushPressureAffectsSizeKey;
extern NSString *const kEraserBrushPressureAffectsFlowKey;

@interface BrushEraser : Brush {
	unsigned char *_eraserScratchData;
	unsigned int _scratchSize;
	CGContextRef _eraserScratchCxt;
}

@end
