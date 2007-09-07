//
//  DripEventLayerSettings.h
//  Drip
//
//  Created by Nur Monson on 9/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DripEvent.h"


@interface DripEventLayerSettings : DripEvent {
	float _opacity;
}

- (id)initWithOpacity:(float)opacity;
- (float)opacity;
@end
