//
//  DripEventLayerCollapse.m
//  Drip
//
//  Created by Nur Monson on 9/19/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEventLayerCollapse.h"


@implementation DripEventLayerCollapse

#define EVENT_LENGTH (EVENT_HEADER_LENGTH)
+ (id)eventWithBytes:(void *)bytes length:(unsigned int)length
{
	unsigned char eventLength = *(unsigned char *)bytes;
	bytes++;
	if( eventLength != EVENT_LENGTH || eventLength > length || *(unsigned char *)bytes != kDripEventLayerCollapse )
		return nil;
	
	return [[[DripEventLayerCollapse alloc] init] autorelease];
}
- (NSData *)data
{
	unsigned char *bytes = (unsigned char*)malloc(EVENT_LENGTH);
	*bytes = EVENT_LENGTH;
	
	unsigned char *ptr = bytes;
	ptr++;
	*ptr = kDripEventLayerCollapse;
	
	NSData *theData = [NSData dataWithBytes:bytes length:EVENT_LENGTH];
	free(bytes);
	return theData;
}

@end
