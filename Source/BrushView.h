//
//  BrushView.h
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPBrush.h"

@interface BrushView : NSView {
	TIPBrush *_currentBrush;
}

- (TIPBrush *)currentBrush;
- (void)setCurrentBrush:(TIPBrush *)newBrush;
@end
