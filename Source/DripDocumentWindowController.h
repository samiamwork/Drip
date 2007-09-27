//
//  DripDocumentWindowController.h
//  Drip
//
//  Created by Nur Monson on 7/28/07.
//  Copyright theidiotproject 2007 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuickTime/QuickTime.h>
#import "ScrollingSketchView.h"
#import "Canvas.h"
#import "LayerController.h"
#import "MovieEncoder.h"

@interface DripDocumentWindowController : NSWindowController
{
	IBOutlet ScrollingSketchView *_sketchView;
	IBOutlet NSSlider *_zoomSlider;
	IBOutlet NSProgressIndicator *_exportProgressBar;
	
	NSTimer *_playbackTimer;
	MovieEncoder *_encoder;
}

- (IBAction)setZoom:(id)sender;
@end
