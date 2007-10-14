//
//  DripEventLayerFill.m
//  Drip
//
//  Created by Nur Monson on 10/13/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEventLayerFill.h"


@implementation DripEventLayerFill

- (id)init
{
	if( (self = [super init]) ) {
		_color = nil;
	}

	return self;
}

- (id)initWithColor:(NSColor *)aColor
{
	if( (self = [super init]) ) {
		_color = [aColor retain];
	}
	
	return self;
}

#define EVENT_LENGTH (EVENT_HEADER_LENGTH+sizeof(CFSwappedFloat32)*4)
+ (id)eventWithBytes:(void *)bytes length:(unsigned int)length
{
	unsigned char eventLength = *(unsigned char *)bytes;
	bytes++;
	if( eventLength != EVENT_LENGTH || eventLength > length || *(unsigned char *)bytes != kDripEventLayerFill )
		return nil;
	bytes++;
	
	float red, green, blue, alpha;

	// get color
	red = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	green = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	blue = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	alpha = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	
	return [[[DripEventLayerFill alloc] initWithColor:[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha]] autorelease];
}

- (NSData *)data
{
	unsigned char *bytes = (unsigned char*)malloc(EVENT_LENGTH);
	*bytes = EVENT_LENGTH;
	
	unsigned char *ptr = bytes;
	ptr++;
	*ptr = kDripEventLayerFill;
	ptr++;
	
	float red, green, blue, alpha;
	[[_color colorUsingColorSpaceName:NSCalibratedRGBColorSpace] getRed:&red green:&green blue:&blue alpha:&alpha];
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(red);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(green);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(blue);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(alpha);
	ptr += sizeof(CFSwappedFloat32);
	
	NSData *theData = [NSData dataWithBytes:bytes length:EVENT_LENGTH];
	free(bytes);
	return theData;
}

- (NSColor *)color
{
	return _color;
}

@end
