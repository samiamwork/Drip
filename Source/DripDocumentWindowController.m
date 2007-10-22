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
#import "ImageExporter.h"

@implementation DripDocumentWindowController

- (void)awakeFromNib
{
	_playbackTimer = nil;
	
	_playbackSpeed = 1;
	
	// export progress indicator controls
	_exportProgressView = nil;
	_exportProgressBar = nil;
	_exportTimeText = nil;
	
	Canvas *newCanvas = [(DripDocument*)[self document] canvas];
	[_sketchView setCanvas:newCanvas];
	[_sketchView setArtist:[(DripDocument*)[self document] artist]];
	// set the zoom slider
	[_zoomSlider setFloatValue:log10f([_sketchView zoom])];
	[_zoomText setStringValue:[NSString stringWithFormat:@"%.02f%%",[_sketchView zoom]*100.0f]];
	
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
	
	if( newWindowFrame.size.width < 300.0f )
		newWindowFrame.size.width = 300.0f;
	if( newWindowFrame.size.height < 200.0f )
		newWindowFrame.size.height = 200.0f;
	
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
	
	// set up the progress view.
	NSSize sketchViewSize = [_sketchView bounds].size;
	_exportProgressView = [[HUDView alloc] initWithFrame:NSMakeRect(floorf((sketchViewSize.width-300.0f)/2.0f),floorf((sketchViewSize.height-81.0f)/2.0f),300.0f,81.0f )];
	// progress bar
	_exportProgressBar = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(20.0f,20.0f,300.0f-40.0f,20.0f)];
	[_exportProgressBar setStyle:NSProgressIndicatorBarStyle];
	[_exportProgressBar setControlSize:NSRegularControlSize];
	[_exportProgressBar setHidden:NO];
	[_exportProgressBar setIndeterminate:NO];
	[_exportProgressBar setMinValue:0.0];
	[_exportProgressBar setMaxValue:1.0];
	[_exportProgressBar setDoubleValue:0.0];
	[_exportProgressView addSubview:_exportProgressBar];
	[_exportProgressBar release];
	// "Exporting..." Label
	NSTextField *exportTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(20.0f,81.0f-20.0f-17.0f,114.0f,17.0f)];
	[exportTitle setBordered:NO];
	[exportTitle setEditable:NO];
	[exportTitle setDrawsBackground:NO];
	[exportTitle setBezeled:NO];
	[exportTitle setStringValue:NSLocalizedString(@"Exporting...",@"Exporting...")];
	[exportTitle setTextColor:[NSColor whiteColor]];
	[_exportProgressView addSubview:exportTitle];
	[exportTitle release];
	// time estimate
	_exportTimeText = [[NSTextField alloc] initWithFrame:NSMakeRect(300.0f-114.0f-20.0f,81.0f-20.0f-17.0f,114.0f,17.0f)];
	[_exportTimeText setBordered:NO];
	[_exportTimeText setEditable:NO];
	[_exportTimeText setDrawsBackground:NO];
	[_exportTimeText setBezeled:NO];
	[_exportTimeText setStringValue:NSLocalizedString(@"Calculating",@"Calculating")];
	[_exportTimeText setAlignment:NSRightTextAlignment];
	[_exportTimeText setTextColor:[NSColor whiteColor]];
	[_exportProgressView addSubview:_exportTimeText];
	[_exportTimeText release];
	// TODO: add cancel button
	[_exportProgressView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
	[_sketchView addSubview:_exportProgressView];
	
	_exportStartTime = [NSDate timeIntervalSinceReferenceDate];
	_lastTimeWeEstimated = _exportStartTime;
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
	
	/*NSRect invalidCanvasRect = */
	int step = 0;
	for( step = 0; step < _playbackSpeed; step++ )
		[theCanvas playNextVisibleEvent];
	// we have a frame to compress
	// TODO fix the problem with using the invalidRect here instead (probably having to do with the NSFillRect in the base layer)
	[theCanvas drawRect:canvasRect inContext:[_encoder frameContext]];
	[_encoder frameReady];
	
	// calculate time left if we're more than 10% done
	float percentLeft = (float)([theCanvas eventCount]-[theCanvas currentPlaybackEvent])/(float)[theCanvas eventCount];
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	if( percentLeft < 0.9f && now-_lastTimeWeEstimated > 5.0 ) {
		_lastTimeWeEstimated = now;
		NSTimeInterval timeLeft = (now-_exportStartTime)*(percentLeft/(1.0f-percentLeft));
		int hours = timeLeft/(60.0*60.0);
		timeLeft -= (double)hours*60.0*60.0;
		int mins = timeLeft/60.0;
		timeLeft -= (double)mins*60.0;
		int secs = timeLeft;
		
		NSString *timeString;
		if( mins < 1 )
			timeString = NSLocalizedString(@"less than a minute",@"less than a minute");
		else
			timeString = [NSString stringWithFormat:@"-%d:%02d:%02d",hours,mins,secs];
		[_exportTimeText setStringValue:timeString];
	}
	

	double newProgress = (double)[theCanvas currentPlaybackEvent]/(double)[theCanvas eventCount];
	[_exportProgressBar setDoubleValue:newProgress];
	if( ![theCanvas isPlayingBack] ) {
		[theCanvas endPlayback];
		[_encoder endMovie];
		[_encoder release];
		_encoder = nil;
		
		[_exportProgressBar setHidden:YES];
		[_exportProgressView removeFromSuperview];
		[_exportProgressView release];
		_exportProgressView = nil;
		_exportProgressBar = nil;
		_exportTimeText = nil;
		
		[_playbackTimer invalidate];
		_playbackTimer = nil;
		printf("export done\n");
	}
	// everyone out of the pool!
	[pool release];
}

- (void)playbackTick:(NSTimer *)theTimer
{
	Canvas *theCanvas = [(DripDocument*)[self document] canvas];
	NSRect invalidCanvasRect;
	
	int step = 0;
	for( step = 0; step < _playbackSpeed; step++ )
		invalidCanvasRect = NSUnionRect( [theCanvas playNextVisibleEvent], invalidCanvasRect );
	
	/*
	while( NSIsEmptyRect(invalidCanvasRect) ) {
		if( ![theCanvas isPlayingBack] ) {
			[self stopPlayback:self];
			return;
		}
		invalidCanvasRect = [theCanvas playNextEvent];
	}
	 */
	
	[_sketchView invalidateCanvasRect:invalidCanvasRect];
	if( ![theCanvas isPlayingBack] )
		[self stopPlayback:self];
}

- (IBAction)exportImage:(id)sender
{
	Canvas *theCanvas = [(DripDocument*)[self document] canvas];
	ImageExporter *imageExporter = [ImageExporter sharedController];
	[imageExporter setBitmapImageRep:[theCanvas bitmapImageRep]];
	[imageExporter setPath:[[[self document] fileURL] path]];
	[imageExporter runModal];
}

- (IBAction)setZoom:(id)sender
{
	[_sketchView setZoom:powf(10.0f,[sender floatValue])];
	[_zoomSlider setFloatValue:log10f([_sketchView zoom])];
	[_zoomText setStringValue:[NSString stringWithFormat:@"%.02f%%",[_sketchView zoom]*100.0f]];
}

- (IBAction)zoomIn:(id)sender
{
	float currentZoom = [_sketchView zoom];
	if( currentZoom >= 1.0f )
		currentZoom = floorf( currentZoom ) + 1.0f;
	else if( currentZoom >= 0.5f )
		currentZoom = 1.0f;
	else if( currentZoom >= 0.25f )
		currentZoom = 0.5f;
	else if( currentZoom >= 0.2f )
		currentZoom = 0.25f;
	else if( currentZoom >= 0.1f )
		currentZoom = 0.2f;
	else
		currentZoom = 0.1f;
	
	[_sketchView setZoom:currentZoom];
	[_zoomSlider setFloatValue:log10f([_sketchView zoom])];
	[_zoomText setStringValue:[NSString stringWithFormat:@"%.02f%%",[_sketchView zoom]*100.0f]];
}

- (IBAction)zoomOut:(id)sender
{
	float currentZoom = [_sketchView zoom];
	if( currentZoom > 1.0f )
		currentZoom = ceilf( currentZoom ) - 1.0f;
	else if( currentZoom > 0.5f )
		currentZoom = 0.5f;
	else if( currentZoom > 0.25f )
		currentZoom = 0.25f;
	else if( currentZoom > 0.2f )
		currentZoom = 0.2f;
	else if( currentZoom > 0.1f )
		currentZoom = 0.1f;
	else
		currentZoom = 0.1f;
	
	[_sketchView setZoom:currentZoom];
	[_zoomSlider setFloatValue:log10f([_sketchView zoom])];
	[_zoomText setStringValue:[NSString stringWithFormat:@"%.02f%%",[_sketchView zoom]*100.0f]];
}

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
	if( [[[menuItem menu] title] isEqualToString:@"Playback Speed"] ) {
		switch( _playbackSpeed ) {
			case 2:
				[self setPlaybackSpeed:[[menuItem menu] itemWithTag:1]];
				break;
			case 3:
				[self setPlaybackSpeed:[[menuItem menu] itemWithTag:2]];
				break;
			case 1:
			default:
				_playbackSpeed = 0;
				[self setPlaybackSpeed:[[menuItem menu] itemWithTag:0]];
		}
		
		return YES;
	}
	
	return YES;
}

- (IBAction)setPlaybackSpeed:(id)sender
{
	NSMenu *speedMenu = [sender menu];
	switch( [sender tag] ) {
		case 0:
			_playbackSpeed = 1;
			[sender setState:NSOnState];
			[[speedMenu itemWithTag:1] setState:NSOffState];
			[[speedMenu itemWithTag:2] setState:NSOffState];
			break;
		case 1:
			_playbackSpeed = 2;
			[[speedMenu itemWithTag:0] setState:NSOffState];
			[sender setState:NSOnState];
			[[speedMenu itemWithTag:2] setState:NSOffState];
			break;
		case 2:
			_playbackSpeed = 3;
			[[speedMenu itemWithTag:0] setState:NSOffState];
			[[speedMenu itemWithTag:1] setState:NSOffState];
			[sender setState:NSOnState];
			break;
	}
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
