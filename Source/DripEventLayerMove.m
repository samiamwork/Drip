//
//  DripEventLayerMove.m
//  Drip
//
//  Created by Nur Monson on 9/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEventLayerMove.h"


@implementation DripEventLayerMove

- (id)init
{
	if( (self = [super init]) ) {
		_fromIndex = _toIndex = 0;
	}

	return self;
}

- (id)initWithFromIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex
{
	if( (self = [super init]) ) {
		_fromIndex = fromIndex;
		_toIndex = toIndex;
	}
	
	return self;
}
- (unsigned int)fromIndex
{
	return _fromIndex;
}
- (unsigned int)toIndex
{
	return _toIndex;
}

#define EVENT_LENGTH (EVENT_HEADER_LENGTH+sizeof(UInt32)*2)
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
	if( eventLength != EVENT_LENGTH || eventLength > length || *(unsigned char *)bytes != kDripEventLayerMove )
		return nil;
	bytes++;
	unsigned int fromIndex;
	unsigned int toIndex;
	
	fromIndex = CFSwapInt32BigToHost( *(UInt32 *)bytes );
	bytes += sizeof(UInt32);
	toIndex = CFSwapInt32BigToHost( *(UInt32 *)bytes );
	
	return [[[DripEventLayerMove alloc] initWithFromIndex:fromIndex toIndex:toIndex] autorelease];
}

- (NSData *)data
{
	unsigned char *bytes = (unsigned char*)malloc(EVENT_LENGTH);
	*bytes = EVENT_LENGTH;
	
	unsigned char *ptr = bytes;
	ptr++;
	*ptr = kDripEventLayerMove;
	ptr++;
	*(UInt32 *)ptr = CFSwapInt32HostToBig( _fromIndex );
	ptr += sizeof(UInt32);
	*(UInt32 *)ptr = CFSwapInt32HostToBig( _toIndex );
	
	NSData *theData = [NSData dataWithBytes:bytes length:EVENT_LENGTH];
	free(bytes);
	return theData;
}
@end
