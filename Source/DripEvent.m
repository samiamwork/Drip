//
//  DripEvent.m
//  Drip
//
//  Created by Nur Monson on 9/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripEvent.h"

@implementation DripEvent

- (id)init
{
	if( (self = [super init]) ) {
		[self release];
		return nil;
	}

	return self;
}

+ (id)eventWithBytes:(void *)bytes length:(unsigned int)length
{
	if( length < EVENT_HEADER_LENGTH )
		return nil;
	
	id newEvent = nil;
	switch( ((char *)bytes)[1] ) {
		case kDripEventStrokeBegin:
			newEvent = [DripEventStrokeBegin eventWithBytes:bytes length:length];
			break;
		case kDripEventStrokeContinue:
			newEvent = [DripEventStrokeContinue eventWithBytes:bytes length:length];
			break;
		case kDripEventStrokeEnd:
			newEvent = [DripEventStrokeEnd eventWithBytes:bytes length:length];
			break;
		case kDripEventBrushSettings:
			newEvent = [DripEventBrushSettings eventWithBytes:bytes length:length];
			break;
		case kDripEventLayerChange:
			newEvent = [DripEventLayerChange eventWithBytes:bytes length:length];
			break;
		case kDripEventLayerAdd:
			newEvent = [DripEventLayerAdd eventWithBytes:bytes length:length];
			break;
		case kDripEventLayerDelete:
			newEvent = [DripEventLayerDelete eventWithBytes:bytes length:length];
			break;
		case kDripEventLayerCollapse:
			newEvent = [DripEventLayerCollapse eventWithBytes:bytes length:length];
			break;
		case kDripEventLayerMove:
			newEvent = [DripEventLayerMove eventWithBytes:bytes length:length];
			break;
		case kDripEventLayerSettings:
			newEvent = [DripEventLayerSettings eventWithBytes:bytes length:length];
			break;
		case kDripEventLayerFill:
			newEvent = [DripEventLayerFill eventWithBytes:bytes length:length];
			break;
		default:
			printf("unknown event! (%d)\n", ((unsigned char *)bytes)[1]);
			return nil;
	}
	
	return newEvent;
}

- (unsigned int)length
{
	[NSException raise:NSInvalidArgumentException format:@"-length only defined for abstract class."];
	return 0;
}
- (unsigned int)bytesNeeded
{
	[NSException raise:NSInvalidArgumentException format:@"-bytesNeeded only defined for abstract class."];
	return 0;
}
- (unsigned int)addBytes:(void *)bytes length:(unsigned int)length
{
	[NSException raise:NSInvalidArgumentException format:@"-addBytes:length: only defined for abstract class."];
	return 0;
}
- (NSData *)data
{
	[NSException raise:NSInvalidArgumentException format:@"-data only defined for abstract class."];
	return nil;
}

@end
