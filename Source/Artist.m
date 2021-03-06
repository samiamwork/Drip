//
//  Artist.m
//  Drip
//
//  Created by Nur Monson on 10/20/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "Artist.h"
#import "DripEventBrushSettings.h"


@implementation Artist

- (id)init
{
	if( (self = [super init]) ) {
		_paintBrush = [[Brush alloc] init];
		_eraserBrush = [[BrushEraser alloc] init];
		
		_currentPenTipBrush = _paintBrush;
		_currentPenEndBrush = _eraserBrush;
		
		_currentBrushPtr = &_currentPenTipBrush;
		
		_color = [[*_currentBrushPtr color] retain];
		
		_lastCheckedBrushSettings = nil;
		_undoManager = nil;
	}

	return self;
}

- (void)dealloc
{
	[_paintBrush release];
	[_eraserBrush release];
	[_color release];
	[_lastCheckedBrushSettings release];

	[super dealloc];
}

// TODO: add a setting for current pen end tools
- (void)loadSettings
{
	[_paintBrush loadSettings];
	[_eraserBrush loadSettings];
	
	[_color release];
	_color = [[*_currentBrushPtr color] retain];
}

- (void)saveSettings
{
	[_paintBrush saveSettings];
	[_eraserBrush saveSettings];
}

- (id)getNewBrushSettings
{
	DripEventBrushSettings *brushSettings = [[DripEventBrushSettings alloc] initWithBrush:*_currentBrushPtr];
	if( !_lastCheckedBrushSettings || ![_lastCheckedBrushSettings isEqual:brushSettings] ) {
		[self setLastBrushSettings:brushSettings];
		[brushSettings release];

		return brushSettings;
	}
	
	[brushSettings release];
	return  nil;
}

- (id)lastBrushSettings
{
	return _lastCheckedBrushSettings;
}
- (void)setLastBrushSettings:(id)brushSettings
{
	[[_undoManager prepareWithInvocationTarget:self] setLastBrushSettings:_lastCheckedBrushSettings];
	if( brushSettings == _lastCheckedBrushSettings )
		return;
	
	[_lastCheckedBrushSettings release];
	_lastCheckedBrushSettings = [brushSettings retain];
}

- (void)setUndoManager:(NSUndoManager *)undoManager
{
	if( undoManager == _undoManager )
		return;
	
	[_undoManager release];
	_undoManager = [undoManager retain];
}

- (void)setCanvasSize:(NSSize)canvasSize
{
	[_paintBrush setCanvasSize:canvasSize];
	[_eraserBrush setCanvasSize:canvasSize];
}

- (Brush *)paintBrush
{
	return _paintBrush;
}
- (BrushEraser *)eraserBrush
{
	return _eraserBrush;
}

- (NSColor *)color
{
	return _color;
}
- (void)setColor:(NSColor *)aColor
{
	if( aColor == _color )
		return;
	
	[_color release];
	_color = [aColor retain];
	
	[*_currentBrushPtr setColor:_color];
}

- (Brush *)currentBrush
{
	return *_currentBrushPtr;
}
- (void)selectPaintBrush
{
	*_currentBrushPtr = _paintBrush;
	[*_currentBrushPtr setColor:_color];
}
- (void)selectEraser
{
	*_currentBrushPtr = _eraserBrush;
	[*_currentBrushPtr setColor:_color];
}

// if it's not using the pen tip it's using the pen end (eraser).
- (void)setUsingPenTip:(BOOL)willUsePenTip
{
	if( willUsePenTip )
		_currentBrushPtr = &_currentPenTipBrush;
	else
		_currentBrushPtr = &_currentPenEndBrush;
	
	[*_currentBrushPtr setColor:_color];
}

@end
