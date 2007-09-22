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
#import "MovieEncoder.h"

@implementation DripDocumentWindowController

- (void)awakeFromNib
{
	printf("awake from nib\n");
	_playbackTimer = nil;
	
	Canvas *newCanvas = [(DripDocument*)[self document] canvas];
	[_sketchView setCanvas:newCanvas];
	[_sketchView setBrush:[(DripDocument*)[self document] brush]];
	
	[(DripDocument*)[self document] setScrollingSketchView:_sketchView];
}

- (IBAction)exportPlaybackToQuicktime:(id)sender
{
	printf("export\n");
	Canvas *theCanvas = [(DripDocument*)[self document] canvas];
	unsigned int canvasWidth = (unsigned int)[theCanvas size].width;
	unsigned int canvasHeight = (unsigned int)[theCanvas size].height;
	
	MovieEncoder *encoder = [[MovieEncoder alloc] initWithWidth:canvasWidth height:canvasHeight];
	NSString *filename = [[[[self document] fileURL] path] stringByDeletingPathExtension];
	filename = [filename stringByAppendingPathExtension:@"mov"];
	[encoder setPath:filename];
	[encoder promptForPath];
	if( ![encoder path] ) {
		[encoder release];
		printf("export canceled (no filename chosen)\n");
		return;
	}
	[encoder promptForSettings];
	[encoder beginMovie];
	[theCanvas beginPlayback];
	
	// create bitmap to draw into that we can copy data out of.
	void *bitmapBytes = calloc(canvasWidth*canvasHeight*4, 1);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGContextRef bitmapContext = CGBitmapContextCreate( bitmapBytes, canvasWidth,canvasHeight, 8, canvasWidth*4, colorSpace, kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease( colorSpace );
	
	// TODO:draw the white canvas.
	// ...draw the frames
	NSRect invalidCanvasRect;
	NSRect canvasRect = NSMakeRect(0.0f,0.0f,(float)canvasWidth,(float)canvasHeight);
	while( [theCanvas isPlayingBack] ) {
		invalidCanvasRect = NSIntersectionRect( [theCanvas playNextEvent], canvasRect );
		while( NSIsEmptyRect(invalidCanvasRect) && [theCanvas isPlayingBack] )
			invalidCanvasRect = NSIntersectionRect( [theCanvas playNextEvent], canvasRect );
		
		// we have a frame to compress
		[theCanvas drawRect:canvasRect inContext:bitmapContext];
		[encoder addFrameFromData:bitmapBytes width:canvasWidth height:canvasHeight pitch:canvasWidth*4];
	}
	CGContextRelease( bitmapContext );
	free(bitmapBytes);
	[theCanvas endPlayback];
	[encoder endMovie];
	[encoder release];
	
	printf("export done\n");
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
