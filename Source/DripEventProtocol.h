/*
 *  DripEventProtocol.h
 *  Drip
 *
 *  Created by Nur Monson on 11/30/07.
 *  Copyright 2007 theidiotproject. All rights reserved.
 *
 */

#import "Canvas.h"
#import "Artist.h"

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
	kDripEventLayerSettings,
	kDripEventLayerFill,
	kDripEventLayerImageFill
} DripEventType;

@protocol DripEvent
/* Creates an event from bytes. If not enough bytes are present
 * to read at least the event packet (not trailing data)
 */
+ (id)eventWithBytes:(void *)bytes length:(unsigned int)length;
/* The length of the event in network format measured in bytes.
 * This does not include trailing data!!
 */
- (unsigned int)length;
/* If the event requires trailing data this value will be non-zero
 * as long as it still lacks all the data it requires.
 * The event is not valid until this value is zero.
 */
- (unsigned int)bytesNeeded;
/* If the event requires trailing data this is used to append
 * more data.
 * Returns the number of bytes read.
 */
- (unsigned int)addBytes:(void *)bytes length:(unsigned int)length;
/* the network representation of the event (i.e. suitable for sending
 * over a network or storing to disk).
 */
- (NSData *)data;

/* call this to playback the event
 */
- (NSRect)runWithCanvas:(Canvas *)theCanvas artist:(Artist *)theArtist;
@end