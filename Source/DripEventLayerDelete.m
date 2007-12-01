//
//  DripEventLayerDelete.m
//  Drip
//
//  Created by Nur Monson on 9/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEventLayerDelete.h"


@implementation DripEventLayerDelete

#define EVENT_LENGTH (EVENT_HEADER_LENGTH)
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
	if( eventLength != EVENT_LENGTH || eventLength > length || *(unsigned char *)bytes != kDripEventLayerDelete )
		return nil;
	
	return [[[DripEventLayerDelete alloc] init] autorelease];
}
- (NSData *)data
{
	unsigned char *bytes = (unsigned char*)malloc(EVENT_LENGTH);
	*bytes = EVENT_LENGTH;
	
	unsigned char *ptr = bytes;
	ptr++;
	*ptr = kDripEventLayerDelete;
	
	NSData *theData = [NSData dataWithBytes:bytes length:EVENT_LENGTH];
	free(bytes);
	return theData;
}

@end
