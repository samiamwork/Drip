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
		_paintBrush = [[Brush alloc] init];
		_eraserBrush = [[BrushEraser alloc] init];
	}

	return self;
}

- (void)dealloc
{
	[_paintBrush release];
	[_eraserBrush release];

	[super dealloc];
}

- (void)awakeFromNib
{
	[_brushController setBrush:_paintBrush];
	[_sketchView setBrush:_paintBrush];
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
	
	[_brushController setBrush:_selectedBrush];
	[_sketchView setBrush:_selectedBrush];
}

@end
