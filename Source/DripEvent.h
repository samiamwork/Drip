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
	kDripEventBrushDrag,
	kDripEventBrushSettings,
	// never sent across network (i.e. not allowed)
	kDripEventLayerAdd,
	kDripEventLayerDelete,
	kDripEventLayerMove,
	kDripEventLayerSettings
} DripEventType;

@interface DripEvent : NSObject {
	NSTimeInterval _timestamp;
}

+ (id)eventWithBytes:(void *)bytes length:(unsigned int)length;
- (NSData *)data;

- (NSTimeInterval)timestamp;
- (void)setTimestamp:(NSTimeInterval)newTimestamp;
@end
