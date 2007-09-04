//
//  DripEventBrushDrag.m
//  Drip
//
//  Created by Nur Monson on 9/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEventBrushDrag.h"


@implementation DripEventBrushDrag
- (id)init
{
	if( (self = [super init]) ) {
		_canvasPosition = NSZeroPoint;
		_pressure = 1.0f;
	}
	
	return self;
}

- (id)initWithPosition:(NSPoint)aPosition pressure:(float)thePressure
{
	if( (self = [super init]) ) {
		_canvasPosition = aPosition;
		_pressure = thePressure;
	}
	
	return self;
}

// length + type + data
#define EVENT_LENGTH (1+1+sizeof(CFSwappedFloat32)*3)
+ (id)eventWithData:(NSData *)theData
{
	unsigned char *bytes = (unsigned char*)[theData bytes];
	unsigned char length = *bytes;
	
	bytes++;
	if( length != EVENT_LENGTH || length < [theData length] || bytes[0] != kDripEventBrushDrag )
		return nil;
	bytes++;
	NSPoint position;
	float pressure;
	
	position.x = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	position.y = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	pressure = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );

	return [[[DripEventBrushDrag alloc] initWithPosition:position pressure:pressure] autorelease];
}

- (NSData *)data
{
	unsigned char *bytes = (unsigned char*)malloc(EVENT_LENGTH);
	*bytes = EVENT_LENGTH;

	unsigned char *ptr = bytes;
	ptr++;
	*ptr = kDripEventBrushDrag;
	ptr++;
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_canvasPosition.x);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_canvasPosition.y);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_pressure);

	NSData *theData = [NSData dataWithBytes:bytes length:EVENT_LENGTH];
	free(bytes);
	return theData;
}

- (NSPoint)position
{
	return _canvasPosition;
}

- (float)pressure
{
	return _pressure;
}
@end
