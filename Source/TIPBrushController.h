/* TIPBrushController */

#import <Cocoa/Cocoa.h>
#import "TIPBrush.h"
#import "BrushView.h"

@interface TIPBrushController : NSObject
{
    IBOutlet NSSlider *brushFlowSlider;
    IBOutlet NSTextField *brushFlowText;
    IBOutlet NSImageView *brushImage;
    IBOutlet NSSlider *brushMainSizeSlider;
    IBOutlet NSTextField *brushMainSizeText;
    IBOutlet NSSlider *brushOpacitySlider;
    IBOutlet NSTextField *brushOpacityText;
    IBOutlet NSButton *brushPressureOpacityCheckbox;
    IBOutlet NSButton *brushPressureSizeCheckbox;
    IBOutlet NSPopUpButton *brushShape;
    IBOutlet NSSlider *brushTipSizeSlider;
    IBOutlet NSTextField *brushTipSizeText;
	IBOutlet BrushView *_brushView;
	
	TIPBrush *currentBrush;
}
- (IBAction)changeBrushShape:(id)sender;
- (IBAction)changeFlow:(id)sender;
- (IBAction)changeMainSize:(id)sender;
- (IBAction)changeOpacity:(id)sender;
- (IBAction)changePressureOpacity:(id)sender;
- (IBAction)changePressureSize:(id)sender;
- (IBAction)changeTipSize:(id)sender;

- (void)setBrush:(TIPBrush*)brush;
@end
