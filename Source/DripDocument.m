//
//  DripDocument.m
//  Drip
//
//  Created by Nur Monson on 7/28/07.
//  Copyright theidiotproject 2007 . All rights reserved.
//

#import "DripDocument.h"
#import "DripInspectors.h"

@implementation DripDocument

- (id)init
{
    self = [super init];
    if (self) {
    
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		_canvasWidth = 300;
		_canvasHeight = 300;
		_canvas = nil;
		
		_brush = [[Brush alloc] init];
		_eraser = [[BrushEraser alloc] init];
    }
    return self;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height
{
	if( (self = [super init]) ) {
		_canvasWidth = width;
		_canvasHeight = height;
		
		_canvas = [[Canvas alloc] initWithWidth:_canvasWidth  height:_canvasHeight];
		[_canvas setDocument:self];
		
		_brush = [[Brush alloc] init];
		[_brush setCanvasSize:NSMakeSize(width,height)];
		_eraser = [[BrushEraser alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[_canvas release];
	[_brush release];
	[_eraser release];

	[super dealloc];
}

- (unsigned int)width
{
	return _canvasWidth;
}
- (unsigned int)height
{
	return _canvasHeight;
}
- (Canvas *)canvas
{
	return _canvas;
}
- (Brush *)brush
{
	return _brush;
}
- (BrushEraser *)eraser
{
	return _eraser;
}
- (ScrollingSketchView *)scrollingSketchView
{
	return _sketchView;
}
// we don't need to retain it since we do nothing with it but give it out to those who ask for it.
- (void)setScrollingSketchView:(ScrollingSketchView *)newSketchView
{
	_sketchView = newSketchView;
}

- (NSString *)windowNibName
{
	return @"DripDocument";
}

- (void)makeWindowControllers
{
	DripDocumentWindowController *newWindowController = [[DripDocumentWindowController alloc] initWithWindowNibName:[self windowNibName]];
	[self addWindowController:newWindowController];
	[newWindowController release];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	[NSKeyedArchiver archiveRootObject:_canvas toFile:[absoluteURL path]];
	
	return YES;
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	[_canvas release];
    _canvas = [NSKeyedUnarchiver unarchiveObjectWithFile:[absoluteURL path]];
	[_canvas retain];
	_canvasWidth = [_canvas size].width;
	_canvasHeight = [_canvas size].height;
	[_canvas setDocument:self];

	[_brush setCanvasSize:[_canvas size]];
	[_eraser setCanvasSize:[_canvas size]];
    return YES;
}

@end
