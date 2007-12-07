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
#import "BrushResat.h"
#import "SketchView.h"
#import "Artist.h"

@interface DripDocument : NSDocument
{
	unsigned int _canvasWidth;
	unsigned int _canvasHeight;
	
	Artist *_artist;
	SketchView *_sketchView;
	
	Canvas *_canvas;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height backgroundColor:(NSColor *)aColor imageData:(NSData *)theImageData;
- (unsigned int)width;
- (unsigned int)height;
- (Canvas *)canvas;

//- (Brush *)brush;
//- (BrushEraser *)eraser;
//- (void)setCurrentBrush:(Brush *)newBrush;
//- (Brush *)currentBrush;
- (Artist *)artist;
- (SketchView *)sketchView;
- (void)setSketchView:(SketchView *)newSketchView;
@end
