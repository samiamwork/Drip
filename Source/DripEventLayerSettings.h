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
	BOOL _visible;
	unsigned int _layerIndex;
}

- (id)initWithLayerIndex:(unsigned int)layerIndex opacity:(float)opacity visible:(BOOL)isVisible;
- (unsigned int)layerIndex;
- (float)opacity;
- (BOOL)visible;
@end
