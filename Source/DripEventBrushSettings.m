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
		_pressureAffectsFlow = NO;
		_pressureAffectsSize = YES;
	}

	return self;
}

- (id)initWithType:(BrushType)theType size:(float)theSize hardness:(float)theHardness spacing:(float)theSpacing pressureAffectsFlow:(BOOL)willAffectFlow pressureAffectsSize:(BOOL)willAffectSize color:(NSColor *)theColor
{
	if( (self = [super init]) ) {
		_type = theType;
		_size = theSize;
		_spacing = theSpacing;
		_hardness = theHardness;
		_pressureAffectsFlow = willAffectFlow;
		_pressureAffectsSize = willAffectSize;
		
		NSColor *rgbColor = [theColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		[rgbColor getRed:&_RGBAColor[0] green:&_RGBAColor[1] blue:&_RGBAColor[2] alpha:&_RGBAColor[3]];
	}
	
	return self;
}

// length + event type + data
#define EVENT_LENGTH (1+1+1+sizeof(CFSwappedFloat32)*7+1)
+ (id)eventWithData:(NSData *)theData
{
	unsigned char *bytes = (unsigned char*)[theData bytes];
	unsigned char length = *bytes;
	
	bytes++;
	if( length != EVENT_LENGTH || length < [theData length] || bytes[0] != kDripEventBrushSettings )
		return nil;
	bytes++;
	
	BrushType type = *bytes;
	bytes++;
	float rgba[4];
	float size;
	float hardness;
	float spacing;
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
	
	pressureAffects = *bytes;
	
	return [[[DripEventBrushSettings alloc] initWithType:type
													size:size
												hardness:hardness
												 spacing:spacing
									 pressureAffectsFlow:(pressureAffects & 1)
									 pressureAffectsSize:(pressureAffects & 2)
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
	
	*ptr = (_pressureAffectsSize ? 2:0) | (_pressureAffectsFlow ? 1:0);
	
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
- (BOOL)pressureAffectsFlow
{
	return _pressureAffectsFlow;
}
- (BOOL)pressureAffectsSize
{
	return _pressureAffectsSize;
}
- (NSColor*)color
{
	return [NSColor colorWithCalibratedRed:_RGBAColor[0] green:_RGBAColor[1] blue:_RGBAColor[2] alpha:_RGBAColor[3]];
}
@end
