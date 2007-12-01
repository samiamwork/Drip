//
//  DripEvent.h
//  Drip
//
//  Created by Nur Monson on 9/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DripEventProtocol.h"

#import "DripEventStrokeBegin.h"
#import "DripEventStrokeContinue.h"
#import "DripEventStrokeEnd.h"
#import "DripEventBrushSettings.h"
#import "DripEventLayerChange.h"
#import "DripEventLayerAdd.h"
#import "DripEventLayerDelete.h"
#import "DripEventLayerCollapse.h"
#import "DripEventLayerMove.h"
#import "DripEventLayerSettings.h"
#import "DripEventLayerFill.h"


@interface DripEvent : NSObject <DripEvent> {

}

@end
