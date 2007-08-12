//
//  DripDocument.m
//  Drip
//
//  Created by Nur Monson on 7/28/07.
//  Copyright theidiotproject 2007 . All rights reserved.
//

#import "DripDocument.h"

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
	}
	
	return self;
}

- (void)dealloc
{
	[_canvas release];

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

    return YES;
}

@end
