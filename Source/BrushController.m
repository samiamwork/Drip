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
		
		_currentDocument = nil;
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

#define MAKE_BLEND_ITEM(yy,zz) blendItem = [[NSMenuItem alloc] init]; [blendItem setTitle:yy]; [blendItem setTag:zz]; [blendMenu addItem:blendItem]; [blendItem release]

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(penEntered:) name:DripPenEnteredNotification object:nil];
	
	// set up blend modes menu
	NSMenu *blendMenu = [[NSMenu alloc] init];
	NSMenuItem *blendItem;
	MAKE_BLEND_ITEM(@"Normal",kCGBlendModeNormal);
	MAKE_BLEND_ITEM(@"Multiply",kCGBlendModeMultiply);
	MAKE_BLEND_ITEM(@"Screen",kCGBlendModeScreen);
	MAKE_BLEND_ITEM(@"Overlay",kCGBlendModeOverlay);
	MAKE_BLEND_ITEM(@"Darken",kCGBlendModeDarken);
	MAKE_BLEND_ITEM(@"Lighten",kCGBlendModeLighten);
	MAKE_BLEND_ITEM(@"Color Dodge",kCGBlendModeColorDodge);
	MAKE_BLEND_ITEM(@"Color Burn",kCGBlendModeColorBurn);
	MAKE_BLEND_ITEM(@"Soft Light",kCGBlendModeSoftLight);
	MAKE_BLEND_ITEM(@"Hard Light",kCGBlendModeHardLight);
	MAKE_BLEND_ITEM(@"Difference",kCGBlendModeDifference);
	MAKE_BLEND_ITEM(@"Exclusion",kCGBlendModeExclusion);
	MAKE_BLEND_ITEM(@"Hue",kCGBlendModeHue);
	MAKE_BLEND_ITEM(@"Saturation",kCGBlendModeSaturation);
	MAKE_BLEND_ITEM(@"Color",kCGBlendModeColor);
	MAKE_BLEND_ITEM(@"Luminosity",kCGBlendModeLuminosity);
	
	[_blendModePopUp setMenu:blendMenu];
	[blendMenu release];
	
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
	
	[_currentBrush saveSettings];
}

- (IBAction)changeFlowExpression:(id)sender
{
	[_currentBrush setPressureAffectsFlow:[sender state]==NSOnState?YES:NO];
	
	[_currentBrush saveSettings];
}

- (IBAction)changeResaturationExpression:(id)sender
{
	[_currentBrush setPressureAffectsResaturation:[sender state]==NSOnState?YES:NO];
	
	[_currentBrush saveSettings];
}

- (IBAction)changeSize:(id)sender
{
	[_currentBrush setSize:[sender floatValue]];
	[_brushSizeText setIntValue:[sender intValue]];
	[_brushView setNeedsDisplay:YES];
	[_sketchView rebuildBrushCursor];
	
	[_currentBrush saveSettings];
}

- (IBAction)changeHardness:(id)sender
{
	[_currentBrush setHardness:[sender floatValue]];
	[_brushHardnessText setFloatValue:[_currentBrush hardness]];
	[_brushView setNeedsDisplay:YES];
	
	[_currentBrush saveSettings];
}

- (IBAction)changeSpacing:(id)sender
{
	[_currentBrush setSpacing:[sender floatValue]];
	[_brushSpacingText setFloatValue:[_currentBrush spacing]];
	[_brushSpacingSlider setFloatValue:[_currentBrush spacing]];
	
	[_currentBrush saveSettings];
}

- (IBAction)changeResaturation:(id)sender
{
	[_currentBrush setResaturation:[sender floatValue]];
	[_brushResaturationText setFloatValue:[_currentBrush resaturation]];
	[_brushResaturationSlider setFloatValue:[_currentBrush resaturation]];
	
	[_currentBrush saveSettings];
}

- (IBAction)changeStrokeOpacity:(id)sender
{
	[_currentBrush setStrokeOpacity:[sender floatValue]];
	[_brushStrokeOpacityText setFloatValue:[_currentBrush strokeOpacity]];
	[_brushStrokeOpacitySlider setFloatValue:[_currentBrush strokeOpacity]];
	
	[_currentBrush saveSettings];
}

- (IBAction)changeBlendMode:(id)sender
{
	[_currentBrush setBlendMode:[[sender selectedItem] tag]];
}

- (void)setBrush:(Brush*)brush
{
	if( brush == _paintBrush )
		[_brushSelector selectCellWithTag:1];
	else
		[_brushSelector selectCellWithTag:2];
	
	if( brush == _currentBrush )
		return;
	
	//save the settings on the old brush before setting the new one
	[_currentBrush saveSettings];
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
	[_blendModePopUp selectItemWithTag:[_currentBrush blendMode]];
	
	[_sizeExpressionCheckbox setState:[_currentBrush pressureAffectsSize]?NSOnState:NSOffState];
	[_flowExpressionCheckbox setState:[_currentBrush pressureAffectsFlow]?NSOnState:NSOffState];
	[_resaturationExpressionCheckbox setState:[_currentBrush pressureAffectsResaturation]?NSOnState:NSOffState];
	
	[_brushView setBrush:_currentBrush];
	//[_currentBrush setColor:[_colorWell color]];
	if( [brush isMemberOfClass:[Brush class]] ) {
		[_colorWell setEnabled:YES];
		[_colorWell setColor:[brush color]];
	} else
		[_colorWell setEnabled:NO];
	
	[_sketchView setBrush:_currentBrush];
}

- (IBAction)colorChanged:(id)sender
{
	[_currentBrush setColor:[sender color]];
	[_currentBrush saveSettings];
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
	[_currentDocument setCurrentBrush:_currentBrush];
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
	
	[self setControlsEnabled:NO];
}

- (void)setDripDocument:(DripDocument *)newDocument
{
	_currentDocument = newDocument;
	
	if( !_currentDocument ) {
		[self disable];
		return;
	}
	
	[self setScrollingSketchView:[newDocument scrollingSketchView]];
	
	[_paintBrush release];
	_paintBrush = [[_currentDocument brush] retain];
	[_eraserBrush release];
	_eraserBrush = [[_currentDocument eraser] retain];
	
	[self setBrush:[_currentDocument currentBrush]];
	[self setControlsEnabled:YES];	
}
@end
