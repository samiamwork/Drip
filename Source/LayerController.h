//
//  LayerController.h
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Canvas.h"
#import "ScrollingSketchView.h"

@interface LayerController : NSObject {
	IBOutlet NSTableView *_layerTable;
	IBOutlet ScrollingSketchView *_sketchView;
	Canvas *_theCanvas;
	
	PaintLayer *_draggingLayer;
}

- (void)setCanvas:(Canvas *)newCanvas;

- (IBAction)addLayer:(id)sender;
- (IBAction)deleteLayer:(id)sender;
@end
