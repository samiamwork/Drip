//
//  DripDocumentWindowController.h
//  Drip
//
//  Created by Nur Monson on 7/28/07.
//  Copyright theidiotproject 2007 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScrollingSketchView.h"
#import "Canvas.h"
#import "LayerController.h"

@interface DripDocumentWindowController : NSWindowController
{
	IBOutlet ScrollingSketchView *_sketchView;
	
	NSTimer *_playbackTimer;
}

@end
