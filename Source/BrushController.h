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
#import "DripDocument.h"

extern NSString *const DripPenEnteredNotification;

@interface BrushController : NSObject {
	IBOutlet NSSlider *_brushSizeSlider;
	IBOutlet NSTextField *_brushSizeText;
	IBOutlet NSSlider *_brushHardnessSlider;
	IBOutlet NSTextField *_brushHardnessText;
	IBOutlet NSSlider *_brushSpacingSlider;
	IBOutlet NSTextField *_brushSpacingText;
	IBOutlet NSSlider *_brushResaturationSlider;
	IBOutlet NSTextField *_brushStrokeOpacityText;
	IBOutlet NSSlider *_brushStrokeOpacitySlider;
	IBOutlet NSTextField *_brushResaturationText;
	IBOutlet NSButton *_sizeExpressionCheckbox;
	IBOutlet NSButton *_flowExpressionCheckbox;
	IBOutlet NSButton *_resaturationExpressionCheckbox;
	IBOutlet NSPopUpButton *_blendModePopUp;
	IBOutlet BrushView *_brushView;
	IBOutlet NSColorWell *_colorWell;
	IBOutlet NSMatrix *_brushSelector;
	
	ScrollingSketchView *_sketchView;
	Brush *_currentBrush;
	
	Brush *_paintBrush;
	BrushEraser *_eraserBrush;
	
	DripDocument *_currentDocument;
}

- (IBAction)colorChanged:(id)sender;

- (IBAction)changeSize:(id)sender;
- (IBAction)changeHardness:(id)sender;
- (IBAction)changeSpacing:(id)sender;
- (IBAction)changeResaturation:(id)sender;
- (IBAction)changeStrokeOpacity:(id)sender;
- (IBAction)changeSizeExpression:(id)sender;
- (IBAction)changeFlowExpression:(id)sender;
- (IBAction)changeResaturationExpression:(id)sender;
- (IBAction)changeBlendMode:(id)sender;
- (void)setBrush:(Brush*)brush;

- (IBAction)selectBrush:(id)sender;

- (void)setScrollingSketchView:(ScrollingSketchView *)newSketchView;
- (void)disable;

- (void)setDripDocument:(DripDocument *)newDocument;
@end
