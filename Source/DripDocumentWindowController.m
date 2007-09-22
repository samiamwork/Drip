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
	printf("awake from nib\n");
	_playbackTimer = nil;
	
	Canvas *newCanvas = [(DripDocument*)[self document] canvas];
	[_sketchView setCanvas:newCanvas];
	[_sketchView setBrush:[(DripDocument*)[self document] brush]];
	
	[(DripDocument*)[self document] setScrollingSketchView:_sketchView];
}

static OSStatus FrameOutputCallback(void* encodedFrameOutputRefCon, ICMCompressionSessionRef session, OSStatus error, ICMEncodedFrameRef frame, void* reserved)
{
	if(error == noErr) {
		OSErr result;
		result = AddMediaSampleFromEncodedFrame(*(Media *)encodedFrameOutputRefCon, frame, NULL);
	}
	
	return error;
}

static void SourceFrameTrackingCallback(void *sourceTrackingRefCon, ICMSourceTrackingFlags sourceTrackingFlags, void *sourceFrameRefCon, void *reserved)
{
    /*
	 * Indicates that this is the last call for this sourceFrameRefCon.
	 */
    if (sourceTrackingFlags & kICMSourceTracking_LastCall)
    {
    }
	
    /*
	 * Indicates that the session is done with the source pixel buffer
	 * and has released any reference to it that it had.
	 */
	if (sourceTrackingFlags & kICMSourceTracking_ReleasedPixelBuffer)
	{
		//CVPixelBufferRelease( *(CVPixelBufferRef *)sourceTrackingRefCon );
	}
	
}

- (IBAction)exportPlaybackToQuicktime:(id)sender
{
	ComponentResult result;
	printf("export\n");
	ComponentInstance component = OpenDefaultComponent(StandardCompressionType,StandardCompressionSubType);
	if( component == NULL ) {
		printf("Falied to open component.\n");
		return;
	}
	long flags = scAllowEncodingWithCompressionSession;
	SCSetInfo( component, scPreferenceFlagsType, &flags);
	
	// load settings from defaults
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"compressionSettings"];
	if( data ) {
		QTAtomContainer container = NewHandle( [data length] );
		if( container ) {
			[data getBytes:*container];
			result = SCSetSettingsFromAtomContainer( component, container);
			if( result )
				printf("SCSetSettingsFromAtomContainer() failed with error %d\n", result);
			QTDisposeAtomContainer(container);
		}
	}
	
	result = SCRequestSequenceSettings( component );
	if( result ) {
		if( result != 1 )
			printf("SCRequestSequenceSettings() failed with %d\n", result);
		CloseComponent( component );
		return;
	}
	
	// save settings back to user defaults
	QTAtomContainer newSettingsContainer;
	result = SCGetSettingsAsAtomContainer( component , &newSettingsContainer );
	if( result )
		printf("SCGetSettingsAsAtomContainer() failed with %d\n", result);
	else {
		data = [NSData dataWithBytes:*newSettingsContainer length:GetHandleSize(newSettingsContainer)];
		[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"compressionSettings"];
		QTDisposeAtomContainer( newSettingsContainer );
	}
	
	ICMCompressionSessionOptionsRef sessionOptions;
	SCCopyCompressionSessionOptions( component, &sessionOptions );
	SCSpatialSettings spatialSettings;
	SCGetInfo( component, scSpatialSettingsType, &spatialSettings );
	
	CloseComponent( component );
	
	// Create Movie
	Handle dataRef;
	OSType dataRefType;
	result = QTNewDataReferenceFromFullPathCFString(CFSTR("/Users/samiam/Desktop/Test.mov"), kQTNativeDefaultPathStyle, 0, &dataRef, &dataRefType);
	if( result ) {
		printf("QTNewDataReferenceFromFullCFPathString() failed with %d\n", result);
		return;
	}
	DataHandler newDataHandler;
	Movie newMovie;
	result = CreateMovieStorage( dataRef, dataRefType, 'TVOD', smCurrentScript, createMovieFileDeleteCurFile, &newDataHandler, &newMovie);
	if( result ) {
		printf("CreateMovieStorage() failed with %d\n", result);
		return;
	}
	DisposeHandle(dataRef);
	Canvas *theCanvas = [(DripDocument*)[self document] canvas];
	unsigned int canvasWidth = (unsigned int)[theCanvas size].width;
	unsigned int canvasHeight = (unsigned int)[theCanvas size].height;
	Track newTrack = NewMovieTrack( newMovie, canvasWidth<<16,canvasHeight<<16, kNoVolume);
	result = GetMoviesError();
	if( result ) {
		printf("NewMovieTrack() failed with %d\n", result);
		return;
	}
	Media newMedia = NewTrackMedia( newTrack, VideoMediaType, 1000000, 0, 0);
	result = GetMoviesError();
	if( result ) {
		printf("NewTrackMedia() failed with %d\n", result);
		return;
	}
	result = BeginMediaEdits( newMedia );
	if( result ) {
		printf("BeginMediaEdits() failed with %d\n", result);
		return;
	}
	
	// start compression session
	ICMEncodedFrameOutputRecord outputRecord = {FrameOutputCallback, &newMedia, NULL};
	ICMCompressionSessionRef compressionSession;
	result = ICMCompressionSessionCreate( kCFAllocatorDefault, canvasWidth, canvasHeight, spatialSettings.codecType, 1000000, sessionOptions, NULL, &outputRecord, &compressionSession);
	CFRelease( sessionOptions );
	
	// create the pixelbuffer pool
	NSMutableDictionary *bufferAttribs = [[NSMutableDictionary alloc] init];
	[bufferAttribs setObject:[NSNumber numberWithUnsignedInt:k32ARGBPixelFormat] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
	[bufferAttribs setObject:[NSNumber numberWithUnsignedInt:canvasWidth] forKey:(NSString *)kCVPixelBufferWidthKey];
	[bufferAttribs setObject:[NSNumber numberWithUnsignedInt:canvasHeight] forKey:(NSString *)kCVPixelBufferHeightKey];
	//[bufferAttribs setObject:[NSNumber numberWithUnsignedInt:4] forKey:(NSString *)kCVPixelBufferBytesPerRowAlignmentKey];
	//[bufferAttribs setObject:[NSNumber numberWithBool:YES] forKey:kCVPixelBufferCGBitmapContextCompatibilityKey];
	CVPixelBufferPoolRef bufferPool;
	result = CVPixelBufferPoolCreate( kCFAllocatorDefault, NULL, (CFDictionaryRef)bufferAttribs, &bufferPool);
	[bufferAttribs release];
	if( result ) {
		// TODO: more cleanup here
		printf("CVPixelBufferPoolCreate() failed with %d\n", result );
		return;
	}
	[theCanvas beginPlayback];
	
	// create bitmap to draw into that we can copy data out of.
	void *bitmapBytes = calloc(canvasWidth*canvasHeight*4, 1);
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	CGContextRef bitmapContext = CGBitmapContextCreate( bitmapBytes, canvasWidth,canvasHeight, 8, canvasWidth*4, colorSpace, kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease( colorSpace );
	
	SInt64 timeStamp = ICMCompressionSessionGetTimeScale( compressionSession ) * (1.0/60.0);
	unsigned int frameNumber = 0;
	ICMSourceTrackingCallbackRecord trackingCallback = { SourceFrameTrackingCallback, NULL };
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
		CVPixelBufferRef pixelBuffer;
		result = CVPixelBufferPoolCreatePixelBuffer( kCFAllocatorDefault, bufferPool, &pixelBuffer);
		
		CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
		void *bytes = CVPixelBufferGetBaseAddress( pixelBuffer );
		size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
		int rowIndex;
		for( rowIndex = 0; rowIndex < canvasHeight; rowIndex++ ) {
			memcpy( bytes+rowIndex*bytesPerRow, bitmapBytes+rowIndex*canvasWidth*4,canvasWidth*4);
		}
		CVPixelBufferUnlockBaseAddress( pixelBuffer, 0);
		trackingCallback.sourceTrackingRefCon = &pixelBuffer;
		result = ICMCompressionSessionEncodeFrame( compressionSession, pixelBuffer, timeStamp*frameNumber,0,kICMValidTime_DisplayTimeStampIsValid, NULL, &trackingCallback,NULL);
		CVPixelBufferRelease( pixelBuffer );
		if( result ) {
			printf("ICMCompressionSessionEncodeFrame() failed with %d\n", result);
			return;
		}
		frameNumber++;
		//printf("%.01f\% Complete\n", (float)[theCanvas currentPlaybackEvent]/(float)[theCanvas eventCount]);
	}
	result = ICMCompressionSessionCompleteFrames( compressionSession, true, 0, 0);
	if( result ) {
		printf("ICMCompressionSessionCompleteFrames() failed with %d\n", result);
		return;
	}
	CGContextRelease( bitmapContext );
	free(bitmapBytes);
	[theCanvas endPlayback];
	
	// finish up the movie
	result = EndMediaEdits( newMedia );
	if( result ) {
		printf("EndMediaEdits() failed with %s\n", result );
		return;
	}
	result = ExtendMediaDecodeDurationToDisplayEndTime( newMedia, NULL );
	if( result )
		printf("ExtendMediaDecodeSurationToDisplayEndTime() failed with %s\n", result);
	TimeValue64 mediaDuration;
	mediaDuration = GetMediaDisplayDuration(newMedia);
	result = InsertMediaIntoTrack( newTrack, 0, 0, mediaDuration, fixed1);
	if( result )
		printf("InsertMediaIntoTrack() failed with %d\n", result );
	result = AddMovieToStorage( newMovie, newDataHandler );
	if( result )
		printf("AddMovieToStorage() failed with %d\n", result );
	CloseMovieStorage( newDataHandler );
	DisposeMovie( newMovie );
	
	ICMCompressionSessionRelease( compressionSession );
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
