//
//  BrushController.m
//  Drip
//
//  Created by Nur Monson on 8/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "BrushController.h"

NSString *const DripPenEnteredNotification = @"DripPenEnteredNotification";

@implementation BrushController

- (id)init
{
	if( (self = [super init]) ) {
		_currentBrush = nil;
		
		_paintBrush = nil;
		_eraserBrush = nil;
		_sketchView = nil;
	}

	return self;
}

- (void)dealloc
{
	[_paintBrush release];
	[_eraserBrush release];
	[_sketchView release];

	[super dealloc];
}

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(penEntered:) name:DripPenEnteredNotification object:nil];
}

- (void)penEntered:(NSNotification *)theNotification
{
	NSEvent *penEnteredEvent = [[theNotification userInfo] objectForKey:@"event"];
	switch( [penEnteredEvent pointingDeviceType] ) {
		case NSEraserPointingDevice:
			[self setBrush:_eraserBrush];
			break;
		case NSPenPointingDevice:
		default:
			[self setBrush:_paintBrush];
			break;
	}
	
}

- (IBAction)changeSizeExpression:(id)sender
{
	[_currentBrush setPressureAffectsSize:[sender state]==NSOnState?YES:NO];
}

- (IBAction)changeFlowExpression:(id)sender
{
	[_currentBrush setPressureAffectsFlow:[sender state]==NSOnState?YES:NO];
}

- (IBAction)changeResaturationExpression:(id)sender
{
	[_currentBrush setPressureAffectsResaturation:[sender state]==NSOnState?YES:NO];
}

- (IBAction)changeSize:(id)sender
{
	[_currentBrush setSize:[sender floatValue]];
	[_brushSizeText setIntValue:[sender intValue]];
	[_brushView setNeedsDisplay:YES];
	[_sketchView rebuildBrushCursor];
}

- (IBAction)changeHardness:(id)sender
{
	[_currentBrush setHardness:[sender floatValue]];
	[_brushHardnessText setFloatValue:[_currentBrush hardness]];
	[_brushView setNeedsDisplay:YES];
}

- (IBAction)changeSpacing:(id)sender
{
	[_currentBrush setSpacing:[sender floatValue]];
	[_brushSpacingText setFloatValue:[_currentBrush spacing]];
	[_brushSpacingSlider setFloatValue:[_currentBrush spacing]];
}

- (IBAction)changeResaturation:(id)sender
{
	[_currentBrush setResaturation:[sender floatValue]];
	[_brushResaturationText setFloatValue:[_currentBrush resaturation]];
	[_brushResaturationSlider setFloatValue:[_currentBrush resaturation]];
}

- (IBAction)changeStrokeOpacity:(id)sender
{
	[_currentBrush setStrokeOpacity:[sender floatValue]];
	[_brushStrokeOpacityText setFloatValue:[_currentBrush strokeOpacity]];
	[_brushStrokeOpacitySlider setFloatValue:[_currentBrush strokeOpacity]];
}

// TODO: should set the buttons to reflect this since we won't always be called from the UI
- (void)setBrush:(Brush*)brush
{
	if( brush == _paintBrush )
		[_brushSelector selectCellWithTag:1];
	else
		[_brushSelector selectCellWithTag:2];
	
	if( brush == _currentBrush )
		return;
	
	_currentBrush = brush;
	
	[_brushSizeSlider setFloatValue:[_currentBrush size]];
	[_brushSizeText setIntValue:(unsigned int)[_currentBrush size]];
	[_brushHardnessSlider setFloatValue:[_currentBrush hardness]];
	[_brushHardnessText setFloatValue:[_currentBrush hardness]];
	[_brushSpacingSlider setFloatValue:[_currentBrush spacing]];
	[_brushSpacingText setFloatValue:[_currentBrush spacing]];
	[_brushResaturationSlider setFloatValue:[_currentBrush resaturation]];
	[_brushResaturationText setFloatValue:[_currentBrush resaturation]];
	[_brushStrokeOpacityText setFloatValue:[_currentBrush strokeOpacity]];
	[_brushStrokeOpacitySlider setFloatValue:[_currentBrush strokeOpacity]];
	
	[_sizeExpressionCheckbox setState:[_currentBrush pressureAffectsSize]?NSOnState:NSOffState];
	[_flowExpressionCheckbox setState:[_currentBrush pressureAffectsFlow]?NSOnState:NSOffState];
	[_resaturationExpressionCheckbox setState:[_currentBrush pressureAffectsResaturation]?NSOnState:NSOffState];
	
	[_brushView setBrush:_currentBrush];
	//[_currentBrush setColor:[_colorWell color]];
	if( [brush isMemberOfClass:[Brush class]] )
		[_colorWell setColor:[brush color]];
	
	[_sketchView setBrush:_currentBrush];
}

- (IBAction)colorChanged:(id)sender
{
	[_currentBrush setColor:[sender color]];
}

- (IBAction)selectBrush:(id)sender
{
	Brush *selectedBrush = nil;
	
	switch( [[sender selectedCell] tag] ) {
		case 1:
			selectedBrush = _paintBrush;
			break;
		case 2:
			selectedBrush = _eraserBrush;
			break;
		default:
			selectedBrush = _paintBrush;
	}
	
	[self setBrush:selectedBrush];
}

- (void)setControlsEnabled:(BOOL)isEnabled
{
	[_brushSizeSlider setEnabled:isEnabled];
	[_brushHardnessSlider setEnabled:isEnabled];
	[_brushSpacingSlider setEnabled:isEnabled];
	[_brushResaturationSlider setEnabled:isEnabled];
	[_brushStrokeOpacitySlider setEnabled:isEnabled];
	[_sizeExpressionCheckbox setEnabled:isEnabled];
	[_flowExpressionCheckbox setEnabled:isEnabled];
	[_resaturationExpressionCheckbox setEnabled:isEnabled];
	[_brushSelector setEnabled:isEnabled];
	[_colorWell setEnabled:isEnabled];
}

- (void)setNewBrush:(Brush *)newBrush eraser:(BrushEraser *)newEraser
{
	[_paintBrush release];
	_paintBrush = [newBrush retain];
	
	[_eraserBrush release];
	_eraserBrush = [newEraser retain];

	/*
	[_brushSizeSlider setEnabled:YES];
	[_brushHardnessSlider setEnabled:YES];
	[_brushSpacingSlider setEnabled:YES];
	[_brushResaturationSlider setEnabled:YES];
	[_brushStrokeOpacitySlider setEnabled:YES];
	[_sizeExpressionCheckbox setEnabled:YES];
	[_flowExpressionCheckbox setEnabled:YES];
	[_resaturationExpressionCheckbox setEnabled:YES];
	[_brushSelector setEnabled:YES];
	[_colorWell setEnabled:YES];
	*/
	[self setControlsEnabled:YES];
	
	[self setBrush:_paintBrush];
}

- (void)setScrollingSketchView:(ScrollingSketchView *)newSketchView
{
	if( newSketchView == _sketchView )
		return;
	
	[_sketchView release];
	_sketchView = [newSketchView retain];
}

- (void)disable
{
	[_sketchView release];
	_sketchView = nil;
	
	[_brushSizeSlider setFloatValue:1.0f];
	[_brushSizeText setIntValue:1];
	[_brushHardnessSlider setFloatValue:0.0f];
	[_brushHardnessText setFloatValue:0.0f];
	[_brushSpacingSlider setFloatValue:0.1f];
	[_brushSpacingText setFloatValue:0.1f];
	[_brushResaturationSlider setFloatValue:1.0f];
	[_brushResaturationText setFloatValue:1.0f];
	[_brushStrokeOpacitySlider setFloatValue:1.0f];
	[_brushStrokeOpacityText setFloatValue:1.0f];
	
	[_sizeExpressionCheckbox setState:NSOffState];
	[_flowExpressionCheckbox setState:NSOffState];
	[_resaturationExpressionCheckbox setState:NSOffState];
	[_brushView setBrush:nil];
	
	/*
	[_brushSizeSlider setEnabled:NO];
	[_brushHardnessSlider setEnabled:NO];
	[_brushSpacingSlider setEnabled:NO];
	[_brushResaturationSlider setEnabled:NO];
	[_brushStrokeOpacitySlider setEnabled:NO];
	[_sizeExpressionCheckbox setEnabled:NO];
	[_flowExpressionCheckbox setEnabled:NO];
	[_resaturationExpressionCheckbox setEnabled:NO];
	[_brushSelector setEnabled:NO];
	[_colorWell setEnabled:NO];
	 */
	[self setControlsEnabled:NO];
}
@end
