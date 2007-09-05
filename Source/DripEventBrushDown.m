//
//  DripEventBrushDown.m
//  Drip
//
//  Created by Nur Monson on 9/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEventBrushDown.h"


@implementation DripEventBrushDown

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

#define EVENT_LENGTH (EVENT_HEADER_LENGTH+sizeof(CFSwappedFloat32)*3)
+ (id)eventWithBytes:(void *)bytes length:(unsigned int)length
{
	unsigned char eventLength = *(unsigned char *)bytes;
	bytes++;
	if( eventLength != EVENT_LENGTH || eventLength > length || *(unsigned char *)bytes != kDripEventBrushDown )
		return nil;
	bytes++;
	NSPoint position;
	float pressure;
	
	position.x = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	position.y = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	pressure = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	
	return [[[DripEventBrushDown alloc] initWithPosition:position pressure:pressure] autorelease];
}

- (NSData *)data
{
	unsigned char *bytes = (unsigned char*)malloc(EVENT_LENGTH);
	*bytes = EVENT_LENGTH;
	
	unsigned char *ptr = bytes;
	ptr++;
	*ptr = kDripEventBrushDown;
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
