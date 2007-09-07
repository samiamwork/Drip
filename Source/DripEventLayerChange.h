//
//  DripEventLayerChange.h
//  Drip
//
//  Created by Nur Monson on 9/7/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DripEvent.h"


@interface DripEventLayerChange : DripEvent {
	unsigned int _layerIndex;
}

- (id)initWithLayerIndex:(unsigned int)layerIndex;
- (unsigned int)layerIndex;
@end
