//
//  BrushEraser.h
//  Drip
//
//  Created by Nur Monson on 8/7/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Brush.h"

@interface BrushEraser : Brush {
	unsigned char *_eraserScratchData;
	unsigned int _scratchSize;
	CGContextRef _eraserScratchCxt;
}

@end
