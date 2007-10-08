//
//  DripInspectors.h
//  Drip
//
//  Created by Nur Monson on 9/7/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScrollingSketchView.h"
#import "Canvas.h"
#import "BrushController.h"
#import "LayerController.h"
#import "DripDocument.h"

@interface DripInspectors : NSWindowController {
	IBOutlet LayerController *_layerController;
	IBOutlet BrushController *_brushController;
	
	IBOutlet NSView *_layerTable;
	IBOutlet NSView *_advancedView;
}

+ (DripInspectors *)sharedController;

- (void)setDripDocument:(DripDocument *)newDocument;
- (void)layersUpdated;

- (IBAction)toggleAdvanced:(id)sender;

@end
