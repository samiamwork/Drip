//
//  DripDocumentWindowController.m
//  Drip
//
//  Created by Nur Monson on 7/28/07.
//  Copyright theidiotproject 2007 . All rights reserved.
//

#import "DripDocumentWindowController.h"
#import "DripDocument.h"
#import "DripInspectors.h"

@implementation DripDocumentWindowController

- (void)awakeFromNib
{
	_playbackTimer = nil;
	
	Canvas *newCanvas = [(DripDocument*)[self document] canvas];
	[_sketchView setCanvas:newCanvas];
	
	[(DripDocument*)[self document] setScrollingSketchView:_sketchView];
}

- (IBAction)playBack:(id)sender
{
	Canvas *theCanvas = [(DripDocument*)[self document] canvas];
	if( [theCanvas isPlayingBack] )
		return;
	
	printf("playback\n");
	_playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(playbackTick:) userInfo:nil repeats:YES];
	[theCanvas beginPlayback];
	[_sketchView setNeedsDisplay:YES];
}

- (IBAction)pausePlayback:(id)sender
{
	printf("pause\n");
	if( _playbackTimer == nil ) {
		_playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(playbackTick:) userInfo:nil repeats:YES];
	} else {
		[_playbackTimer invalidate];
		_playbackTimer = nil;
	}
}

- (IBAction)stopPlayback:(id)sender
{
	printf("stop playback\n");
	[_playbackTimer invalidate];
	_playbackTimer = nil;
	
	Canvas *theCanvas = [(DripDocument*)[self document] canvas];
	[theCanvas endPlayback];
}

- (void)playbackTick:(NSTimer *)theTimer
{
	Canvas *theCanvas = [(DripDocument*)[self document] canvas];
	NSRect invalidCanvasRect = [theCanvas playNextEvent];
	while( NSIsEmptyRect(invalidCanvasRect) ) {
		if( ![theCanvas isPlayingBack] ) {
			[self stopPlayback:self];
			return;
		}
		invalidCanvasRect = [theCanvas playNextEvent];
	}
	//TODO: should be more precise
	[_sketchView invalidateCanvasRect:invalidCanvasRect];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	printf("did become main\n");
	[[DripInspectors sharedController] setDripDocument:[self document]];
}

// we don't really care about this one since the new main will take care of it
- (void)windowDidResignMain:(NSNotification *)notification
{
	printf("did resign main\n");
}
// this we care about, only if we were main.
- (void)windowWillClose:(NSNotification *) notification
{
	printf("will close\n");
	if( [[self window] isMainWindow] )
		printf("was main\n");
}
@end
