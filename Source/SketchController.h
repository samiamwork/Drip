//
//  SketchController.h
//  Drip
//
//  Created by Nur Monson on 8/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BrushController.h"
#import "ScrollingSketchView.h"

@interface SketchController : NSObject {
	IBOutlet ScrollingSketchView *_sketchView;
	IBOutlet BrushController *_brushController;
	
	Brush *_paintBrush;
}

- (IBAction)selectBrush:(id)sender;
@end
