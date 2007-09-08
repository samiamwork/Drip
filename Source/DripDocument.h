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
#import "Brush.h"
#import "BrushEraser.h"
#import "ScrollingSketchView.h"

@interface DripDocument : NSDocument
{
	unsigned int _canvasWidth;
	unsigned int _canvasHeight;
	
	Brush *_brush;
	BrushEraser *_eraser;
	ScrollingSketchView *_sketchView;
	
	Canvas *_canvas;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;
- (unsigned int)width;
- (unsigned int)height;
- (Canvas *)canvas;

- (Brush *)brush;
- (BrushEraser *)eraser;
- (ScrollingSketchView *)scrollingSketchView;
- (void)setScrollingSketchView:(ScrollingSketchView *)newSketchView;
@end
