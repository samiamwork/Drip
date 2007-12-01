//
//  DripEventBrushSettings.m
//  Drip
//
//  Created by Nur Monson on 9/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEventBrushSettings.h"


@implementation DripEventBrushSettings

- (id)init
{
	if( (self = [super init]) ) {
		_type = kBrushTypePaint;
		_RGBAColor[0] = 0.0f;
		_RGBAColor[1] = 0.0f;
		_RGBAColor[2] = 0.0f;
		_RGBAColor[3] = 1.0f;
		_size = 20.0f;
		_hardness = 0.8f;
		_spacing = 0.2f;
		_resaturation = 1.0f;
		_strokeOpacity = 1.0f;
		_blendMode = kCGBlendModeNormal;
		_pressureAffectsFlow = NO;
		_pressureAffectsSize = YES;
		_pressureAffectsResaturation = YES;
	}

	return self;
}

- (id)initWithType:(BrushType)theType size:(float)theSize hardness:(float)theHardness spacing:(float)theSpacing resaturation:(float)theResaturation strokeOpacity:(float)theStrokeOpacity blendMode:(CGBlendMode)blendMode pressureAffectsFlow:(BOOL)willAffectFlow pressureAffectsSize:(BOOL)willAffectSize pressureAffectsResaturation:(BOOL)willAffectResaturation color:(NSColor *)theColor;
{
	if( (self = [super init]) ) {
		_type = theType;
		_size = theSize;
		_spacing = theSpacing;
		_hardness = theHardness;
		_resaturation = theResaturation;
		_strokeOpacity = theStrokeOpacity;
		_blendMode = blendMode;
		_pressureAffectsFlow = willAffectFlow;
		_pressureAffectsSize = willAffectSize;
		_pressureAffectsResaturation = willAffectResaturation;
		
		NSColor *rgbColor = [theColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		[rgbColor getRed:&_RGBAColor[0] green:&_RGBAColor[1] blue:&_RGBAColor[2] alpha:&_RGBAColor[3]];
	}
	
	return self;
}

#define EVENT_LENGTH (EVENT_HEADER_LENGTH+1+sizeof(CFSwappedFloat32)*9+sizeof(UInt32)+1)
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
	if( eventLength != EVENT_LENGTH || eventLength > length || *(unsigned char *)bytes != kDripEventBrushSettings )
		return nil;
	bytes++;
	
	BrushType type = *(unsigned char *)bytes;
	bytes++;
	float rgba[4];
	float size;
	float hardness;
	float spacing;
	float resaturation;
	float strokeOpacity;
	// bit field for pressure expressions
	unsigned char pressureAffects;
	
	// get color
	rgba[0] = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	rgba[1] = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	rgba[2] = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	rgba[3] = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	
	size = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	hardness = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	spacing = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	resaturation = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	strokeOpacity = CFConvertFloat32SwappedToHost( *(CFSwappedFloat32 *)bytes );
	bytes += sizeof(CFSwappedFloat32);
	CGBlendMode blendMode = CFSwapInt32BigToHost( *(UInt32 *)bytes );
	bytes += sizeof( UInt32 );
	
	pressureAffects = *(unsigned char *)bytes;
	
	return [[[DripEventBrushSettings alloc] initWithType:type
													size:size
												hardness:hardness
												 spacing:spacing
											resaturation:resaturation
										   strokeOpacity:strokeOpacity
											   blendMode:blendMode
									 pressureAffectsFlow:(pressureAffects & 1)
									 pressureAffectsSize:(pressureAffects & 2)
							 pressureAffectsResaturation:(pressureAffects & 4)
												   color:[NSColor colorWithCalibratedRed:rgba[0] green:rgba[1] blue:rgba[2] alpha:rgba[3]]] autorelease];
}

- (NSData *)data
{
	unsigned char *bytes = (unsigned char*)malloc(EVENT_LENGTH);
	*bytes = EVENT_LENGTH;
	
	unsigned char *ptr = bytes;
	ptr++;
	*ptr = kDripEventBrushSettings;
	ptr++;
	*ptr = _type;
	ptr++;
	
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_RGBAColor[0]);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_RGBAColor[1]);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_RGBAColor[2]);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_RGBAColor[3]);
	ptr += sizeof(CFSwappedFloat32);
	
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_size);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_hardness);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_spacing);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_resaturation);
	ptr += sizeof(CFSwappedFloat32);
	*(CFSwappedFloat32 *)ptr = CFConvertFloat32HostToSwapped(_strokeOpacity);
	ptr += sizeof(CFSwappedFloat32);
	*(UInt32 *)ptr = CFSwapInt32HostToBig( _blendMode );
	ptr += sizeof(UInt32);
	
	*ptr = (_pressureAffectsSize ? 2:0) | (_pressureAffectsFlow ? 1:0) | (_pressureAffectsResaturation ? 4:0);
	
	NSData *theData = [NSData dataWithBytes:bytes length:EVENT_LENGTH];
	free(bytes);
	return theData;
}

- (BrushType)type
{
	return _type;
}
- (float)size
{
	return _size;
}
- (float)hardness
{
	return _hardness;
}
- (float)spacing
{
	return _spacing;
}
- (float)resaturation
{
	return _resaturation;
}
- (float)strokeOpacity
{
	return _strokeOpacity;
}
- (CGBlendMode)blendMode
{
	return _blendMode;
}
- (BOOL)pressureAffectsFlow
{
	return _pressureAffectsFlow;
}
- (BOOL)pressureAffectsSize
{
	return _pressureAffectsSize;
}
- (BOOL)pressureAffectsResaturation
{
	return _pressureAffectsResaturation;
}
- (NSColor*)color
{
	return [NSColor colorWithCalibratedRed:_RGBAColor[0] green:_RGBAColor[1] blue:_RGBAColor[2] alpha:_RGBAColor[3]];
}

#pragma mark Equality

- (unsigned int)hash
{
	return (*(UInt32 *)&_size ^ *(UInt32 *)&_hardness ^ *(UInt32 *)&_spacing ^ *(UInt32 *)&_resaturation ^ *(UInt32 *)&_strokeOpacity ^ _blendMode ^ *(UInt32 *)&_RGBAColor[0] ^
			*(UInt32 *)&_RGBAColor[1] ^ *(UInt32 *)&_RGBAColor[2] ^ *(UInt32 *)&_RGBAColor[3] ^ (_pressureAffectsFlow ? 1:0 | _pressureAffectsSize ? 2:0 | _pressureAffectsResaturation ? 4:0) ^
			_type);
}

- (BOOL)isEqual:(id)anObject
{
	if( ![anObject isKindOfClass:[DripEventBrushSettings class]] )
		return NO;
	
	DripEventBrushSettings *_settings = (DripEventBrushSettings *)anObject;
	if( _type == _settings->_type &&
		_size == _settings->_size &&
		_hardness == _settings->_hardness &&
		_spacing == _settings->_spacing &&
		_resaturation == _settings->_resaturation &&
		_strokeOpacity == _settings->_strokeOpacity &&
		_blendMode == _settings->_blendMode &&
		_RGBAColor[0] == _settings->_RGBAColor[0] &&
		_RGBAColor[1] == _settings->_RGBAColor[1] &&
		_RGBAColor[2] == _settings->_RGBAColor[2] &&
		_RGBAColor[3] == _settings->_RGBAColor[3] &&
		_pressureAffectsFlow == _settings->_pressureAffectsFlow &&
		_pressureAffectsSize == _settings->_pressureAffectsSize )
		return YES;
	
	return NO;
}
@end
