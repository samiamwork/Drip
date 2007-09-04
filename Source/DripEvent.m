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
		_timestamp = [NSDate timeIntervalSinceReferenceDate];
	}

	return self;
}

@end
