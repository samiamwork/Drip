//
//  DripEventLayerSettings.h
//  Drip
//
//  Created by Nur Monson on 9/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DripEventProtocol.h"


@interface DripEventLayerSettings : NSObject <DripEvent> {
	float _opacity;
	BOOL _visible;
	CGBlendMode _blendMode;
	unsigned int _layerIndex;
}

- (id)initWithLayerIndex:(unsigned int)layerIndex opacity:(float)opacity visible:(BOOL)isVisible blendMode:(CGBlendMode)blendMode;
- (void)setLayerIndex:(unsigned int)layerIndex;
- (unsigned int)layerIndex;
- (float)opacity;
- (BOOL)visible;
- (CGBlendMode)blendMode;
@end
