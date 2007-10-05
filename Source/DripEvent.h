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
	kDripEventStrokeBegin = 1,
	kDripEventStrokeContinue,
	kDripEventStrokeEnd,
	kDripEventBrushSettings,
	kDripEventLayerChange,
	// never sent across network (i.e. not allowed)
	kDripEventLayerAdd,
	kDripEventLayerDelete,
	kDripEventLayerCollapse,
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
