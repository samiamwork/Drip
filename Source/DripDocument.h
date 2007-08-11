//
//  DripDocument.h
//  Drip
//
//  Created by Nur Monson on 7/28/07.
//  Copyright theidiotproject 2007 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "DripDocumentWindowController.h"
#import "Canvas.h"

@interface DripDocument : NSDocument
{
	unsigned int _canvasWidth;
	unsigned int _canvasHeight;
	
	Canvas *_canvas;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;
- (unsigned int)width;
- (unsigned int)height;
- (Canvas *)canvas;
@end
