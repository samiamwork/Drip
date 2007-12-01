//
//  DripEventLayerChange.m
//  Drip
//
//  Created by Nur Monson on 9/7/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEventLayerChange.h"


@implementation DripEventLayerChange

- (id)initWithLayerIndex:(unsigned int)layerIndex
{
	if( (self = [super init]) ) {
		_layerIndex = layerIndex;
	}
	
	return self;
}
- (unsigned int)layerIndex
{
	return _layerIndex;
}

#define EVENT_LENGTH (EVENT_HEADER_LENGTH+sizeof(UInt32))
- (unsigned int)length
{
	return EVENT_LENGTH;
}
- (unsigned int)bytesNeeded
{
	return 0;
}
- (unsigned int)addBytes:(void *)bytes length:(unsigned int)length
{
	return 0;
}

+ (id)eventWithBytes:(void *)bytes length:(unsigned int)length
{
	unsigned char eventLength = *(unsigned char *)bytes;
	bytes++;
	if( eventLength != EVENT_LENGTH || eventLength > length || *(unsigned char *)bytes != kDripEventLayerChange )
		return nil;
	bytes++;
	
	unsigned int layerIndex = CFSwapInt32BigToHost( *(UInt32 *)bytes );
	
	return [[[DripEventLayerChange alloc] initWithLayerIndex:layerIndex] autorelease];
}

- (NSData *)data
{
	unsigned char *bytes = (unsigned char*)malloc(EVENT_LENGTH);
	*bytes = EVENT_LENGTH;
	
	unsigned char *ptr = bytes;
	ptr++;
	*ptr = kDripEventLayerChange;
	ptr++;
	*(UInt32 *)ptr = CFSwapInt32HostToBig( _layerIndex );
		
	NSData *theData = [NSData dataWithBytes:bytes length:EVENT_LENGTH];
	free(bytes);
	return theData;
}

@end
