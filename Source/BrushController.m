//
//  BrushController.m
//  Drip
//
//  Created by Nur Monson on 8/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "BrushController.h"

@implementation BrushController

- (id)init
{
	if( (self = [super init]) ) {
		_currentBrush = nil;
		
		_artist = nil;
		_sketchView = nil;
		
		_currentDocument = nil;
	}

	return self;
}

- (void)dealloc
{
	[_artist release];
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
	if( ![penEnteredEvent isEnteringProximity] ) {
		[_artist setUsingPenTip:YES];
		[self setBrush:[_artist currentBrush]];
		return;
	}
	
	switch( [penEnteredEvent pointingDeviceType] ) {
		case NSEraserPointingDevice:
			[_artist setUsingPenTip:NO];
			break;
		case NSPenPointingDevice:
		default:
			[_artist setUsingPenTip:YES];
			break;
	}
	
	[self setBrush:[_artist currentBrush]];
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
	
	[_currentBrush saveSettings];
}

- (void)setBrush:(Brush*)brush
{
	if( brush == [_artist paintBrush] )
		[_brushSelector selectCellWithTag:1];
	else
		[_brushSelector selectCellWithTag:2];
	
	if( brush == _currentBrush )
		return;
	
	//save the settings on the old brush before setting the new one
	[_currentBrush saveSettings];
	_currentBrush = brush;
	
	[_brushSizeSlider setFloatValue:[_currentBrush size]];
	[_brushSizeSlider setEnabled:[_currentBrush usesSize]];
	[_brushSizeText setIntValue:(unsigned int)[_currentBrush size]];
	
	[_brushHardnessSlider setFloatValue:[_currentBrush hardness]];
	[_brushHardnessSlider setEnabled:[_currentBrush usesHardness]];
	[_brushHardnessText setFloatValue:[_currentBrush hardness]];
	
	[_brushSpacingSlider setFloatValue:[_currentBrush spacing]];
	[_brushSpacingSlider setEnabled:[_currentBrush usesSpacing]];
	[_brushSpacingText setFloatValue:[_currentBrush spacing]];
	
	[_brushResaturationSlider setFloatValue:[_currentBrush resaturation]];
	[_brushResaturationSlider setEnabled:[_currentBrush usesResaturation]];
	[_brushResaturationText setFloatValue:[_currentBrush resaturation]];
	
	[_brushStrokeOpacitySlider setEnabled:[_currentBrush usesStrokeOpacity]];
	[_brushStrokeOpacitySlider setFloatValue:[_currentBrush strokeOpacity]];
	[_brushStrokeOpacityText setFloatValue:[_currentBrush strokeOpacity]];
	
	[_blendModePopUp selectItemWithTag:[_currentBrush blendMode]];
	[_blendModePopUp setEnabled:[_currentBrush usesBlendMode]];
	
	[_sizeExpressionCheckbox setState:[_currentBrush pressureAffectsSize]?NSOnState:NSOffState];
	[_sizeExpressionCheckbox setEnabled:[_currentBrush usesPressureAffectsSize]];
	
	[_flowExpressionCheckbox setState:[_currentBrush pressureAffectsFlow]?NSOnState:NSOffState];
	[_flowExpressionCheckbox setEnabled:[_currentBrush usesPressureAffectsFlow]];
	
	[_resaturationExpressionCheckbox setState:[_currentBrush pressureAffectsResaturation]?NSOnState:NSOffState];
	[_resaturationExpressionCheckbox setEnabled:[_currentBrush usesPressureAffectsResaturation]];
	
	[_brushView setBrush:_currentBrush];
	if( [brush isMemberOfClass:[Brush class]] ) {
		[_colorWell setEnabled:YES];
		[_colorWell setColor:[brush color]];
	} else
		[_colorWell setEnabled:NO];
	
	[_sketchView rebuildBrushCursor];
}

- (IBAction)colorChanged:(id)sender
{
	[_artist setColor:[sender color]];
	[_currentBrush saveSettings];
}

- (IBAction)selectBrush:(id)sender
{	
	switch( [[sender selectedCell] tag] ) {
		case 2:
			[_artist selectEraser];
			break;
		case 1:
		default:
			[_artist selectPaintBrush];
	}
	
	[self setBrush:[_artist currentBrush]];
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
	
	[_artist release];
	_artist = [[_currentDocument artist] retain];
	/*
	[_paintBrush release];
	_paintBrush = [[_currentDocument brush] retain];
	[_eraserBrush release];
	_eraserBrush = [[_currentDocument eraser] retain];
	*/
	[self setBrush:[_artist currentBrush]];
	[self setControlsEnabled:YES];
}
@end
