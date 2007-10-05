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
#import "AnimatingTableView.h"

@interface LayerController : NSObject {
	IBOutlet AnimatingTableView *_layerTable;
	IBOutlet NSSlider *_opacitySlider;
	IBOutlet NSButton *_plusButton;
	IBOutlet NSButton *_minusButton;
	IBOutlet NSPopUpButton *_layerBlendModePopUpButton;
	
	ScrollingSketchView *_sketchView;
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

- (void)setScrollingSketchView:(ScrollingSketchView *)newSketchView;
- (void)disable;

- (void)layersUpdated;
@end
