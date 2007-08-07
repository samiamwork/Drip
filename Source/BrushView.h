//
//  BrushView.h
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Brush.h"

@interface BrushView : NSView {
	Brush *_currentBrush;
}

- (Brush *)brush;
- (void)setBrush:(Brush *)newBrush;
@end
