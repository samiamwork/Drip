//
//  Canvas.h
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PaintLayer.h"

@interface Canvas : NSObject {
	PaintLayer *_topLayer;
	PaintLayer *_bottomLayer;
	PaintLayer *_currentLayer;
	
	NSMutableArray *_layers;
	
	unsigned int _width;
	unsigned int _height;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;
- (void)addLayer;
- (void)setCurrentLayer:(PaintLayer *)aLayer;
- (NSSize)size;

- (void)drawRect:(NSRect)aRect;
@end
