//
//  SketchController.h
//  Drip
//
//  Created by Nur Monson on 8/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPBrushPaint.h"
#import "TIPBrushEraser.h"
#import "TIPBrushController.h"
#import "SketchView.h"

@interface SketchController : NSObject {
	IBOutlet TIPBrushController *_brushController;
	IBOutlet NSScrollView *_scrollView;
	IBOutlet NSColorWell *_colorWell;
	TIPBrush *_paintBrush;
	TIPBrush *_eraser;
}

- (IBAction)colorChanged:(id)sender;
- (IBAction)selectBrush:(id)sender;
@end
