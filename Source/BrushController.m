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
	}

	return self;
}

- (void)dealloc
{
	[_currentBrush release];

	[super dealloc];
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
- (void)setBrush:(Brush*)brush
{
	if( brush == _currentBrush )
		return;
	
	[_currentBrush release];
	_currentBrush = [brush retain];
	
	[_brushSizeSlider setFloatValue:[_currentBrush size]];
	[_brushSizeText setIntValue:(unsigned int)[_currentBrush size]];
	[_brushHardnessSlider setFloatValue:[_currentBrush hardness]];
	[_brushHardnessText setFloatValue:[_currentBrush hardness]];
	[_brushView setBrush:_currentBrush];
	[_currentBrush setColor:[_colorWell color]];
}

- (IBAction)colorChanged:(id)sender
{
	[_currentBrush setColor:[sender color]];
}
@end
