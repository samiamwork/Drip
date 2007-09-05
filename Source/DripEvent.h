//
//  DripEvent.h
//  Drip
//
//  Created by Nur Monson on 9/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// length + type
#define EVENT_HEADER_LENGTH (1+1)
typedef enum DripEventType {
	kDripEventBrushDown = 1,
	kDripEventBrushDrag = 2,
	kDripEventBrushSettings = 3,
} DripEventType;

@interface DripEvent : NSObject {
	NSTimeInterval _timestamp;
}

- (NSTimeInterval)timestamp;
- (void)setTimestamp:(NSTimeInterval)newTimestamp;
@end
