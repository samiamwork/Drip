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
    }
    return self;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height
{
	if( (self = [super init]) ) {
		_canvasWidth = width;
		_canvasHeight = height;
	}
	
	return self;
}

- (unsigned int)width
{
	return _canvasWidth;
}
- (unsigned int)height
{
	return _canvasHeight;
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

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
    
    return YES;
}

@end
