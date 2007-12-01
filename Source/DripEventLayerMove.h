//
//  DripEventLayerMove.h
//  Drip
//
//  Created by Nur Monson on 9/5/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DripEventProtocol.h"

@interface DripEventLayerMove : NSObject <DripEvent> {
	unsigned int _fromIndex;
	unsigned int _toIndex;
}

- (id)initWithFromIndex:(unsigned int)fromIndex toIndex:(unsigned int)toIndex;
- (unsigned int)fromIndex;
- (unsigned int)toIndex;
@end
