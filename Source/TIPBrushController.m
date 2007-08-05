#import "TIPBrushController.h"

@implementation TIPBrushController

- (IBAction)changeBrushShape:(id)sender
{
	int tag = [[sender selectedItem] tag];
	
	if(tag == 0) {
		[currentBrush setSmooth:YES];
	} else {
		[currentBrush setSmooth:NO];
	}
}

- (IBAction)changeFlow:(id)sender
{
}

- (IBAction)changeMainSize:(id)sender
{
	[currentBrush setMainSize:[sender intValue]];
	[brushMainSizeText setIntValue:[currentBrush mainSize]];
	[_brushView setNeedsDisplay:YES];
}

- (IBAction)changeOpacity:(id)sender
{
}

- (IBAction)changePressureOpacity:(id)sender
{
	if([sender state] == NSOnState) {
		[currentBrush setPressureAffectsOpacity:YES];
	} else {
		[currentBrush setPressureAffectsOpacity:NO];
	}
}

- (IBAction)changePressureSize:(id)sender
{
	if([sender state] == NSOnState) {
		[currentBrush setPressureAffectsSize:YES];
	} else {
		[currentBrush setPressureAffectsSize:NO];
	}
}

- (IBAction)changeTipSize:(id)sender
{
	[currentBrush setTipSize:[sender floatValue]];
	[brushTipSizeText setFloatValue:[currentBrush tipSize]];
	[_brushView setNeedsDisplay:YES];
}

- (void)setBrush:(TIPBrush*)brush
{
	int index;
	currentBrush = brush;
	
	[brushMainSizeSlider setIntValue:[currentBrush mainSize]];
	[brushMainSizeSlider setMaxValue:50];
	[brushMainSizeText setIntValue:[currentBrush mainSize]];
	[brushTipSizeSlider setFloatValue:[currentBrush tipSize]];
	[brushTipSizeSlider setMaxValue:1.0];
	[brushTipSizeText setFloatValue:[currentBrush tipSize]];
	if([currentBrush smooth]) {
		index = [brushShape indexOfItemWithTag:0];
	} else {
		index = [brushShape indexOfItemWithTag:1];
	}
	[brushShape selectItemAtIndex:index];
	
	if([currentBrush pressureAffectsSize])
		[brushPressureSizeCheckbox setState:NSOnState];
	else
		[brushPressureSizeCheckbox setState:NSOffState];
	
	if([currentBrush pressureAffectsOpacity])
		[brushPressureOpacityCheckbox setState:NSOnState];
	else
		[brushPressureOpacityCheckbox setState:NSOffState];
	
	[_brushView setCurrentBrush:currentBrush];
}
@end
