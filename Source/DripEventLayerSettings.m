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
- (void)setLayerIndex:(unsigned int)layerIndex
{
	_layerIndex = layerIndex;
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

- (NSRect)runWithCanvas:(Canvas *)theCanvas artist:(Artist *)theArtist
{
	Layer *aLayer = [[theCanvas layers] objectAtIndex:_layerIndex];
	[aLayer setBlendMode:_blendMode];
	[aLayer setOpacity:_opacity];
	[aLayer setVisible:_visible];
	
	// TODO: stop going behind the canvas's back to change layer settings (relevant anymore?).
	// generally when we're playing back we are not also recording so it does not matter
	// that we go behind the canvas's back.
	//[theCanvas settingsChangedForLayer:aLayer];
	
	return NSMakeRect(0.0f,0.0f,[theCanvas size].width,[theCanvas size].height);
}

@end
