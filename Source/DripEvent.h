//
//  DripEvent.h
//  Drip
//
//  Created by Nur Monson on 9/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum DripEventType {
	kDripEventBrushDown = 1,
	kDripEventBrushDrag = 2,
	kDripEventBrushSettings = 3,
} DripEventType;

@interface DripEvent : NSObject {
	NSTimeInterval _timestamp;
}

- (NSTimeInterval)timestamp;
@end
