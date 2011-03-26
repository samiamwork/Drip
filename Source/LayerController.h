//
//  LayerController.h
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Canvas.h"
#import "SketchView.h"
#import "AnimatingTableView.h"

@interface LayerController : NSObject <NSTableViewDelegate, NSTableViewDataSource> {
	IBOutlet AnimatingTableView *_layerTable;
	IBOutlet NSSlider *_opacitySlider;
	IBOutlet NSButton *_plusButton;
	IBOutlet NSButton *_minusButton;
	IBOutlet NSPopUpButton *_layerBlendModePopUpButton;
	
	SketchView *_sketchView;
	Canvas *_theCanvas;
	
	NSArray *_oldLayers;
	
	Layer *_draggingLayer;
}

- (void)setCanvas:(Canvas *)newCanvas;

- (IBAction)addLayer:(id)sender;
- (IBAction)deleteLayer:(id)sender;
- (IBAction)collapseLayer:(id)sender;
- (IBAction)setOpacity:(id)sender;
- (IBAction)setBlendMode:(id)sender;

- (void)setSketchView:(SketchView *)newSketchView;
- (void)disable;

- (void)layersUpdated;
@end
