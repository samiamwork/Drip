//
//  SketchController.m
//  Drip
//
//  Created by Nur Monson on 8/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "SketchController.h"


@implementation SketchController

- (id)init
{
	if( (self = [super init]) ) {
		_paintBrush = [[TIPBrushPaint alloc] init];
		_eraser = [[TIPBrushEraser alloc] init];
	}

	return self;
}

- (void)dealloc
{
	[_paintBrush release];
	[_eraser release];

	[super dealloc];
}

- (void)awakeFromNib
{
	[_brushController setBrush:_paintBrush];
	[(SketchView*)[_scrollView documentView] setCurrentBrush:_paintBrush];
}

- (IBAction)colorChanged:(id)sender
{
	[(SketchView*)[_scrollView documentView] setForeColor:[[sender color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace]];
}

- (IBAction)selectBrush:(id)sender
{
	TIPBrush *_selectedBrush = nil;
	
	switch( [[sender selectedCell] tag] ) {
		case 1:
			_selectedBrush = _paintBrush;
			break;
		case 2:
			_selectedBrush = _eraser;
			break;
		default:
			_selectedBrush = _paintBrush;
	}
	
	[_brushController setBrush:_selectedBrush];
	[(SketchView*)[_scrollView documentView] setCurrentBrush:_selectedBrush];
}
@end
