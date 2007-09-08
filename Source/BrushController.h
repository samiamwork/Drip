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
#import "ScrollingSketchView.h"

@interface BrushController : NSObject {
	IBOutlet NSSlider *_brushSizeSlider;
	IBOutlet NSTextField *_brushSizeText;
	IBOutlet NSSlider *_brushHardnessSlider;
	IBOutlet NSTextField *_brushHardnessText;
	IBOutlet NSSlider *_brushSpacingSlider;
	IBOutlet NSTextField *_brushSpacingText;
	IBOutlet NSButton *_sizeExpressionCheckbox;
	IBOutlet NSButton *_flowExpressionCheckbox;
	IBOutlet BrushView *_brushView;
	IBOutlet NSColorWell *_colorWell;
	IBOutlet NSMatrix *_brushSelector;
	
	ScrollingSketchView *_sketchView;
	Brush *_currentBrush;
	
	Brush *_paintBrush;
	BrushEraser *_eraserBrush;
}

- (IBAction)colorChanged:(id)sender;

- (IBAction)changeSize:(id)sender;
- (IBAction)changeHardness:(id)sender;
- (IBAction)changeSpacing:(id)sender;
- (IBAction)changeSizeExpression:(id)sender;
- (IBAction)changeFlowExpression:(id)sender;
- (void)setBrush:(Brush*)brush;

- (IBAction)selectBrush:(id)sender;

- (void)setNewBrush:(Brush *)newBrush eraser:(BrushEraser *)newEraser;
- (void)setScrollingSketchView:(ScrollingSketchView *)newSketchView;
- (void)disable;
@end
