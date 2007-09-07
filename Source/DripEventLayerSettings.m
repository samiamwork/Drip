//
//  DripEventLayerSettings.m
//  Drip
//
//  Created by Nur Monson on 9/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEventLayerSettings.h"


@implementation DripEventLayerSettings

- (id)initWithOpacity:(float)opacity
{
	if( (self = [super init]) ) {
		_opacity = opacity;
	}
	
	return self;
}

- (float)opacity
{
	return _opacity;
}

#define EVENT_LENGTH (EVENT_HEADER_LENGTH+sizeof(CFSwappedFloat32))
+ (id)eventWithBytes:(void *)bytes length:(unsigned int)length
{
	unsigned char eventLength = *(unsigned char *)bytes;
	bytes++;
	if( eventLength != EVENT_LENGTH || eventLength > length || *(unsigned char *)bytes != kDripEventLayerSettings )
		return nil;
	bytes++;
	
	float opacity = CFConvertFloatSwappedToHost( *(CFSwappedFloat32 *)bytes );
	
	return [[[DripEventLayerSettings alloc] initWithOpacity:opacity] autorelease];
}

- (NSData *)data
{
	unsigned char *bytes = (unsigned char*)malloc(EVENT_LENGTH);
	*bytes = EVENT_LENGTH;
	
	unsigned char *ptr = bytes;
	ptr++;
	*ptr = kDripEventLayerSettings;
	ptr++;
	*(CFSwappedFloat32 *)ptr = CFConvertFloatHostToSwapped( _opacity );
		
	NSData *theData = [NSData dataWithBytes:bytes length:EVENT_LENGTH];
	free(bytes);
	return theData;
}

@end
