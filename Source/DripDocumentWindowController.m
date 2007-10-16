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
	[_sketchView setBrush:[(DripDocument*)[self document] brush]];
	
	[(DripDocument*)[self document] setScrollingSketchView:_sketchView];
	
	// center window
	NSRect mainScreenFrame = [[NSScreen mainScreen] visibleFrame];
	// find out what side the inspector window is on and compensate
	NSRect inspectorWindowFrame = [[[DripInspectors sharedController] window] frame];
	if( inspectorWindowFrame.origin.x + inspectorWindowFrame.size.width/2.0f < mainScreenFrame.origin.x + mainScreenFrame.size.width/2.0f ) {
		mainScreenFrame.origin.x += inspectorWindowFrame.origin.x + inspectorWindowFrame.size.width - mainScreenFrame.origin.x;
		mainScreenFrame.size.width -= inspectorWindowFrame.origin.x + inspectorWindowFrame.size.width - mainScreenFrame.origin.x;
	} else {
		mainScreenFrame.size.width -= mainScreenFrame.origin.x + mainScreenFrame.size.width - inspectorWindowFrame.origin.x;
	}
	
	NSSize canvasSize = [newCanvas size];
	NSSize windowFrameSize = [[self window] frame].size;
	NSSize viewSize = [_sketchView bounds].size;
	
	NSSize extraWindowSize = NSMakeSize(windowFrameSize.width-viewSize.width, windowFrameSize.height-viewSize.height);
	NSRect newWindowFrame = NSZeroRect;
	newWindowFrame.size.width = canvasSize.width+extraWindowSize.width;
	newWindowFrame.size.height = canvasSize.height+extraWindowSize.height;
	
	newWindowFrame.origin.x = roundf(mainScreenFrame.origin.x + (mainScreenFrame.size.width-newWindowFrame.size.width)/2.0f);
	if( newWindowFrame.origin.x < mainScreenFrame.origin.x ) {
		newWindowFrame.origin.x = mainScreenFrame.origin.x;
		// because this implies that our window is too wide we'll need to make it thinner.
		newWindowFrame.size.width = mainScreenFrame.size.width;
	}
	
	newWindowFrame.origin.y = roundf(mainScreenFrame.origin.y + (mainScreenFrame.size.height-newWindowFrame.size.height)/2.0f);
	if( newWindowFrame.origin.y < mainScreenFrame.origin.y ) {
		newWindowFrame.origin.y = mainScreenFrame.origin.y;
		// because this implies that our window is too tall we need to make it shorter.
		newWindowFrame.size.height = mainScreenFrame.size.height;
	}
	
	[[self window] setFrame:newWindowFrame display:YES];
}

- (IBAction)exportPlaybackToQuicktime:(id)sender
{
	Canvas *theCanvas = [(DripDocument*)[self document] canvas];
	unsigned int canvasWidth = (unsigned int)[theCanvas size].width;
	unsigned int canvasHeight = (unsigned int)[theCanvas size].height;
	
	_encoder = [[MovieEncoder alloc] initWithWidth:canvasWidth height:canvasHeight];
	NSString *filename = [[[[self document] fileURL] path] stringByDeletingPathExtension];
	filename = [filename stringByAppendingPathExtension:@"mov"];
	[_encoder setPath:filename];
	if( ![_encoder promptForPath] || ![_encoder path] ) {
		[_encoder release];
		_encoder = nil;
		printf("export canceled (no filename chosen)\n");
		return;
	}
	[_encoder beginMovie];
	[theCanvas beginPlayback];
	
	// ...draw the frames
	NSRect canvasRect = NSMakeRect(0.0f,0.0f,(float)canvasWidth,(float)canvasHeight);
	[theCanvas drawRect:canvasRect inContext:[_encoder frameContext]];
	[_encoder frameReady];
	
	[_exportProgressBar setHidden:NO];
	[_exportProgressBar setIndeterminate:NO];
	[_exportProgressBar setMinValue:0.0];
	[_exportProgressBar setMaxValue:1.0];
	[_exportProgressBar setDoubleValue:0.0];
	
	_playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(exportTick:) userInfo:nil repeats:YES];
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

- (void)exportTick:(NSTimer *)theTimer
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	Canvas *theCanvas = [(DripDocument*)[self document] canvas];
	NSRect canvasRect = NSMakeRect(0.0f,0.0f,(float)[theCanvas size].width,(float)[theCanvas size].height);
	
	NSRect invalidCanvasRect = [theCanvas playNextVisibleEvent];
	// we have a frame to compress
	// TODO fix the problem with using the invalidRect here instead (probably having to do with the NSFillRect in the base layer)
	[theCanvas drawRect:canvasRect inContext:[_encoder frameContext]];
	[_encoder frameReady];

	double newProgress = (double)[theCanvas currentPlaybackEvent]/(double)[theCanvas eventCount];
	[_exportProgressBar setDoubleValue:newProgress];
	if( ![theCanvas isPlayingBack] ) {
		[theCanvas endPlayback];
		[_encoder endMovie];
		[_encoder release];
		_encoder = nil;
		
		[_exportProgressBar setHidden:YES];
		
		[_playbackTimer invalidate];
		_playbackTimer = nil;
	}
	// everyone out of the pool!
	[pool release];
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

- (IBAction)setZoom:(id)sender
{
	[_sketchView setZoom:powf(10.0f,[sender floatValue])];
	[_zoomSlider setFloatValue:log10f([_sketchView zoom])];
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
	[[DripInspectors sharedController] setDripDocument:[self document]];
}

// this we care about, only if we were main.
- (void)windowWillClose:(NSNotification *) notification
{
	if( ![[self window] isMainWindow] )
		return;
	
	[[DripInspectors sharedController] setDripDocument:nil];
}
@end
