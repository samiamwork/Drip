//
//  DripDocumentWindowController.h
//  Drip
//
//  Created by Nur Monson on 7/28/07.
//  Copyright theidiotproject 2007 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuickTime/QuickTime.h>
#import "SketchView.h"
#import "Canvas.h"
#import "LayerController.h"
#import "MovieEncoder.h"
#import "HUDView.h"

@interface DripDocumentWindowController : NSWindowController
{
	IBOutlet SketchView *_sketchView;
	IBOutlet NSScrollView *_scrollView;
	IBOutlet NSSlider *_zoomSlider;
	IBOutlet NSTextField *_zoomText;

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
