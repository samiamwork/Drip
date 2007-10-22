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
#import "HUDView.h"

@interface DripDocumentWindowController : NSWindowController
{
	IBOutlet ScrollingSketchView *_sketchView;
	IBOutlet NSSlider *_zoomSlider;
	IBOutlet NSTextField *_zoomText;
	
	NSView *_exportProgressView;
	NSProgressIndicator *_exportProgressBar;
	NSTextField *_exportTimeText;
	
	unsigned int _playbackSpeed;
	
	NSTimer *_playbackTimer;
	NSTimeInterval _exportStartTime;
	NSTimeInterval _lastTimeWeEstimated;
	MovieEncoder *_encoder;
}

- (IBAction)setZoom:(id)sender;
- (IBAction)zoomIn:(id)sender;
- (IBAction)zoomOut:(id)sender;

- (IBAction)setPlaybackSpeed:(id)sender;
@end
