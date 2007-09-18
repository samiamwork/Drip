//
//  DripEventLayerSettings.m
//  Drip
//
//  Created by Nur Monson on 9/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEventLayerSettings.h"


@implementation DripEventLayerSettings

- (id)initWithLayerIndex:(unsigned int)layerIndex opacity:(float)opacity visible:(BOOL)isVisible blendMode:(CGBlendMode)blendMode;
{
	if( (self = [super init]) ) {
		_layerIndex = layerIndex;
		_opacity = opacity;
		_visible = isVisible;
		_blendMode = blendMode;
	}
	
	return self;
}

- (unsigned int)layerIndex
{
	return _layerIndex;
}
- (float)opacity
{
	return _opacity;
}
- (BOOL)visible
{
	return _visible;
}
- (CGBlendMode)blendMode
{
	return _blendMode;
}

#define EVENT_LENGTH (EVENT_HEADER_LENGTH+sizeof(UInt32)*2+sizeof(CFSwappedFloat32)+1)
+ (id)eventWithBytes:(void *)bytes length:(unsigned int)length
{
	unsigned char eventLength = *(unsigned char *)bytes;
	bytes++;
	if( eventLength != EVENT_LENGTH || eventLength > length || *(unsigned char *)bytes != kDripEventLayerSettings )
		return nil;
	bytes++;
	
	unsigned int layerIndex = CFSwapInt32BigToHost( *(UInt32 *)bytes );
	bytes += sizeof( UInt32 );
	CGBlendMode blendMode = CFSwapInt32BigToHost( *(UInt32 *)bytes );
	bytes += sizeof( UInt32 );
	float opacity = CFConvertFloatSwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof( CFSwappedFloat32 );
	BOOL visible = *(unsigned char *)bytes & 1;
	
	return [[[DripEventLayerSettings alloc] initWithLayerIndex:layerIndex opacity:opacity visible:visible blendMode:blendMode] autorelease];
}

- (NSData *)data
{
	unsigned char *bytes = (unsigned char*)malloc(EVENT_LENGTH);
	*bytes = EVENT_LENGTH;
	
	unsigned char *ptr = bytes;
	ptr++;
	*ptr = kDripEventLayerSettings;
	ptr++;
	*(UInt32 *)ptr = CFSwapInt32HostToBig( _layerIndex );
	ptr += sizeof( UInt32 );
	*(UInt32 *)ptr = CFSwapInt32HostToBig( _blendMode );
	ptr += sizeof( UInt32 );
	*(CFSwappedFloat32 *)ptr = CFConvertFloatHostToSwapped( _opacity );
	ptr += sizeof(CFSwappedFloat32);
	*ptr = ((_visible ? 1 : 0) << 0);
		
	NSData *theData = [NSData dataWithBytes:bytes length:EVENT_LENGTH];
	free(bytes);
	return theData;
}

@end
