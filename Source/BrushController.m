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

- (IBAction)changeSizeExpression:(id)sender
{
	[_currentBrush setPressureAffectsSize:[sender state]==NSOnState?YES:NO];
}

- (IBAction)changeFlowExpression:(id)sender
{
	[_currentBrush setPressureAffectsFlow:[sender state]==NSOnState?YES:NO];
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

// TODO: should set the buttons to reflect this since we won't always be called from the UI
- (void)setBrush:(Brush*)brush
{
	if( brush == _currentBrush )
		return;
	
	_currentBrush = brush;
	
	[_brushSizeSlider setFloatValue:[_currentBrush size]];
	[_brushSizeText setIntValue:(unsigned int)[_currentBrush size]];
	[_brushHardnessSlider setFloatValue:[_currentBrush hardness]];
	[_brushHardnessText setFloatValue:[_currentBrush hardness]];
	[_brushSpacingSlider setFloatValue:[_currentBrush spacing]];
	[_brushSpacingText setFloatValue:[_currentBrush spacing]];
	
	[_sizeExpressionCheckbox setState:[_currentBrush pressureAffectsSize]?NSOnState:NSOffState];
	[_flowExpressionCheckbox setState:[_currentBrush pressureAffectsFlow]?NSOnState:NSOffState];
	[_brushView setBrush:_currentBrush];
	[_currentBrush setColor:[_colorWell color]];
}

- (IBAction)colorChanged:(id)sender
{
	[_currentBrush setColor:[sender color]];
}

- (IBAction)selectBrush:(id)sender
{
	Brush *_selectedBrush = nil;
	
	switch( [[sender selectedCell] tag] ) {
		case 1:
			_selectedBrush = _paintBrush;
			break;
		case 2:
			_selectedBrush = _eraserBrush;
			break;
		default:
			_selectedBrush = _paintBrush;
	}
	
	[self setBrush:_selectedBrush];
	[_sketchView setBrush:_selectedBrush];
}

- (void)setNewBrush:(Brush *)newBrush eraser:(BrushEraser *)newEraser
{
	[_paintBrush release];
	_paintBrush = [newBrush retain];
	
	[_eraserBrush release];
	_eraserBrush = [newEraser retain];
	
	[self setBrush:_paintBrush];
}

- (void)setScrollingSketchView:(ScrollingSketchView *)newSketchView
{
	if( newSketchView == _sketchView )
		return;
	
	[_sketchView release];
	_sketchView = [newSketchView retain];
}
@end
