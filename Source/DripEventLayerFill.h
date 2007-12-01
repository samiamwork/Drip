//
//  DripEventLayerFill.h
//  Drip
//
//  Created by Nur Monson on 10/13/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DripEventProtocol.h"


@interface DripEventLayerFill : NSObject <DripEvent> {
	NSColor *_color;
}

- (id)initWithColor:(NSColor *)aColor;
- (NSColor *)color;
@end
