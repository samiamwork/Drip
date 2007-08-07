//
//  BrushController.h
//  Drip
//
//  Created by Nur Monson on 8/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Brush.h"
#import "BrushView.h"

@interface BrushController : NSObject {
	IBOutlet NSSlider *_brushSizeSlider;
	IBOutlet NSTextField *_brushSizeText;
	IBOutlet BrushView *_brushView;
	IBOutlet NSColorWell *_colorWell;
	
	Brush *_currentBrush;
}

- (IBAction)colorChanged:(id)sender;

- (IBAction)changeSize:(id)sender;
- (void)setBrush:(Brush*)brush;
@end
