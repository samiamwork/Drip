//
//  DripEventBrushDrag.h
//  Drip
//
//  Created by Nur Monson on 9/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DripEvent.h"

@interface DripEventBrushDrag : DripEvent {
	NSPoint _canvasPosition;
	float _pressure;
}

+ (id)eventWithData:(NSData *)theData;
- (id)initWithPosition:(NSPoint)aPosition pressure:(float)thePressure;
- (NSPoint)position;
- (float)pressure;

- (NSData *)data;
@end
