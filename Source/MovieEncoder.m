//
//  MovieEncoder.m
//  Drip
//
//  Created by Nur Monson on 9/21/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "MovieEncoder.h"

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

@implementation MovieEncoder

// we want users to set width and height
- (id)init
{
	if( (self = [super init]) ) {
		[self release];
		return nil;
	}

	return self;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height
{
	if( (self = [super init]) ) {
		if( width == 0 || height == 0 ) {
			[self release];
			return nil;
		}
		
		_width = width;
		_height = height;
		_path = nil;
		_compressionSession = NULL;
		_movie = NULL;
		_dataHandler = NULL;
	}
	
	return self;
}

- (void)dealloc
{
	if( _pixelBufferPool )
		CVPixelBufferPoolRelease( _pixelBufferPool );
	if( _movie )
		DisposeMovie( _movie );
	if( _compressionSession )
		ICMCompressionSessionRelease( _compressionSession );
	if( _dataHandler )
		CloseMovieStorage( _dataHandler );

	[_path release];
	[super dealloc];
}

void loadCompressionSettings( ComponentInstance component )
{
	ComponentResult result;
	
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
}

void saveCompressionSettings( ComponentInstance component )
{
	ComponentResult result;
	
	// save settings back to user defaults
	QTAtomContainer newSettingsContainer;
	result = SCGetSettingsAsAtomContainer( component , &newSettingsContainer );
	if( result )
		printf("SCGetSettingsAsAtomContainer() failed with %d\n", result);
	else {
		NSData *data = [NSData dataWithBytes:*newSettingsContainer length:GetHandleSize(newSettingsContainer)];
		[[NSUserDefaults standardUserDefaults] setObject:data forKey:@"compressionSettings"];
		QTDisposeAtomContainer( newSettingsContainer );
	}
}

NSString *currentCodecName( void )
{
	ComponentInstance component = OpenDefaultComponent(StandardCompressionType,StandardCompressionSubType);
	if( component == NULL ) {
		printf("Falied to open component.\n");
		return nil;
	}
	
	loadCompressionSettings( component );
	SCSpatialSettings spatialSettings;
	SCGetInfo( component, scSpatialSettingsType, &spatialSettings );
	CloseComponent( component );
	
	CodecInfo codecInfo;
	GetCodecInfo( &codecInfo, spatialSettings.codecType, 0);
	void *codecNameCString = calloc( *(unsigned char *)codecInfo.typeName + 1, 1 );
	memcpy( codecNameCString, (unsigned char *)codecInfo.typeName + 1, *(unsigned char *)codecInfo.typeName);
	//printf("name = %s\n", newString );
	NSString *codecName = [NSString stringWithCString:codecNameCString];
	free(codecNameCString);
	
	return codecName;
}

- (BOOL)promptForPath
{
	if( _compressionSession != NULL )
		return NO;
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setCanSelectHiddenExtension:YES];
	[savePanel setExtensionHidden:YES];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setRequiredFileType:@"mov"];
	NSString *filename = nil;
	NSString *directory = [@"~/Desktop" stringByExpandingTildeInPath];
	if( _path ) {
		filename = [_path lastPathComponent];
		directory = [_path stringByDeletingLastPathComponent];
	}
	
	NSView *containerView = [[NSView alloc] initWithFrame:NSMakeRect(0.0f,0.0f,300.0f,75.0f)];
	[containerView setAutoresizingMask:NSViewWidthSizable | NSViewMaxYMargin];
	
	NSTextField *settingsLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(16.0f,50.0f-25.0f,150.0f,25.0f)];
	[settingsLabel setEditable:NO];
	[settingsLabel setDrawsBackground:NO];
	[settingsLabel setSelectable:NO];
	[settingsLabel setBezeled:NO];
	[settingsLabel setStringValue:@"Compression Settings"];
	[containerView addSubview:settingsLabel];
	[settingsLabel release];
	
	NSButton *changeButton = [[NSButton alloc] initWithFrame:NSMakeRect(150.0f+16.0f,50.0f-25.0f,75.0f,25.0f)];
	[changeButton setTitle:@"Change"];
	[changeButton setBezelStyle:NSRoundedBezelStyle];
	[containerView addSubview:changeButton];
	[changeButton release];
	
	NSTextField *settingsDescription = [[NSTextField alloc] initWithFrame:NSMakeRect(16.0f,50.0f-45.0f,300.0f,20.0f)];
	[settingsDescription setEditable:NO];
	[settingsDescription setDrawsBackground:NO];
	[settingsDescription setSelectable:NO];
	[settingsDescription setBezeled:NO];
	[settingsDescription setStringValue:currentCodecName()];
	[containerView addSubview:settingsDescription];
	[settingsDescription release];
	
	[savePanel setAccessoryView:containerView];
	NSRect superBounds = [[containerView superview] bounds];
	[containerView setFrame:NSMakeRect(0.0f,0.0f,superBounds.size.width-32.0f,75.0f)];
	[containerView release];
	
	if( [savePanel runModalForDirectory:directory file:filename] != NSFileHandlingPanelOKButton )
		return NO;
	
	[self setPath:[savePanel filename]];
	
	return YES;
}
- (NSString *)path
{
	return _path;
}
- (void)setPath:(NSString *)newPath
{
	if( newPath == _path || _compressionSession != NULL )
		return;
	
	[_path release];
	_path = [newPath retain];
}

- (void)promptForSettings
{
	ComponentResult result;
	ComponentInstance component = OpenDefaultComponent(StandardCompressionType,StandardCompressionSubType);
	if( component == NULL ) {
		printf("Falied to open component.\n");
		return;
	}
	
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
	
	long flags = scAllowEncodingWithCompressionSession;
	SCSetInfo( component, scPreferenceFlagsType, &flags);
	
	// prompt for sequence settings
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
	
	CloseComponent( component );
}

- (void)beginMovie
{
	ComponentResult result;
	ComponentInstance component = OpenDefaultComponent(StandardCompressionType,StandardCompressionSubType);
	if( component == NULL ) {
		printf("Falied to open component.\n");
		return;
	}
	
	// load settings from defaults
	NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"compressionSettings"];
	if( !data ) {
		[self promptForSettings];
		data = [[NSUserDefaults standardUserDefaults] objectForKey:@"compressionSettings"];
	}

	QTAtomContainer container = NewHandle( [data length] );
	if( container ) {
		[data getBytes:*container];
		result = SCSetSettingsFromAtomContainer( component, container);
		if( result )
			printf("SCSetSettingsFromAtomContainer() failed with error %d\n", result);
		QTDisposeAtomContainer(container);
	}
	
	long flags = scAllowEncodingWithCompressionSession;
	SCSetInfo( component, scPreferenceFlagsType, &flags);
	
	ICMCompressionSessionOptionsRef sessionOptions = NULL;
	result = SCCopyCompressionSessionOptions( component, &sessionOptions );
	if( result ) {
		printf("SCCopyCompressionSessionOptions() failed with %d\n", result);
		return;
	}
	SCSpatialSettings spatialSettings;
	SCGetInfo( component, scSpatialSettingsType, &spatialSettings );
	CloseComponent( component );
	
	// Create Movie
	// Use ConvertMovieToFile to make MP4 kQTFileTypeMP4
	Handle dataRef;
	OSType dataRefType;
	result = QTNewDataReferenceFromFullPathCFString((CFStringRef)_path, kQTNativeDefaultPathStyle, 0, &dataRef, &dataRefType);
	if( result ) {
		printf("QTNewDataReferenceFromFullCFPathString() failed with %d\n", result);
		return;
	}
	result = CreateMovieStorage( dataRef, dataRefType, 'TVOD', smCurrentScript, createMovieFileDeleteCurFile, &_dataHandler, &_movie);
	if( result ) {
		// TODO:checking for more meaningful errors
		printf("CreateMovieStorage() failed with %d\n", result);
		return;
	}
	DisposeHandle(dataRef);
	_track = NewMovieTrack( _movie, _width<<16, _height<<16, kNoVolume);
	result = GetMoviesError();
	if( result ) {
		printf("NewMovieTrack() failed with %d\n", result);
		return;
	}
	_media = NewTrackMedia( _track, VideoMediaType, 1000000, 0, 0);
	result = GetMoviesError();
	if( result ) {
		printf("NewTrackMedia() failed with %d\n", result);
		return;
	}
	result = BeginMediaEdits( _media );
	if( result ) {
		printf("BeginMediaEdits() failed with %d\n", result);
		return;
	}
	
	// start compression session
	ICMEncodedFrameOutputRecord outputRecord = {FrameOutputCallback, &_media, NULL};
	result = ICMCompressionSessionCreate( kCFAllocatorDefault, _width, _height, spatialSettings.codecType, 1000000, sessionOptions, NULL, &outputRecord, &_compressionSession);
	CFRelease( sessionOptions );
	
	// create the pixelbuffer pool
	NSMutableDictionary *bufferAttribs = [[NSMutableDictionary alloc] init];
	[bufferAttribs setObject:[NSNumber numberWithUnsignedInt:k32ARGBPixelFormat] forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
	[bufferAttribs setObject:[NSNumber numberWithUnsignedInt:_width] forKey:(NSString *)kCVPixelBufferWidthKey];
	[bufferAttribs setObject:[NSNumber numberWithUnsignedInt:_height] forKey:(NSString *)kCVPixelBufferHeightKey];
	result = CVPixelBufferPoolCreate( kCFAllocatorDefault, NULL, (CFDictionaryRef)bufferAttribs, &_pixelBufferPool);
	[bufferAttribs release];
	if( result ) {
		// TODO: more cleanup here
		printf("CVPixelBufferPoolCreate() failed with %d\n", result );
		return;
	}
	_currentFrame = 0;
	
}

- (void)endMovie
{
	OSStatus result;
	result = ICMCompressionSessionCompleteFrames( _compressionSession, true, 0, 0);
	if( result ) {
		printf("ICMCompressionSessionCompleteFrames() failed with %d\n", result);
		return;
	}
	
	// finish up the movie
	result = EndMediaEdits( _media );
	if( result ) {
		printf("EndMediaEdits() failed with %s\n", result );
		return;
	}
	result = ExtendMediaDecodeDurationToDisplayEndTime( _media, NULL );
	if( result )
		printf("ExtendMediaDecodeSurationToDisplayEndTime() failed with %s\n", result);
	result = InsertMediaIntoTrack( _track, 0, 0, GetMediaDisplayDuration(_media), fixed1);
	if( result )
		printf("InsertMediaIntoTrack() failed with %d\n", result );
	result = AddMovieToStorage( _movie, _dataHandler );
	if( result )
		printf("AddMovieToStorage() failed with %d\n", result );
	CloseMovieStorage( _dataHandler );
	_dataHandler = NULL;
	DisposeMovie( _movie );
	_movie == NULL;
	// release track and media too
	
	ICMCompressionSessionRelease( _compressionSession );
	_compressionSession = NULL;
}

- (void)addFrameFromData:(void *)bitmapBytes width:(unsigned int)width height:(unsigned int)height pitch:(unsigned int)pitch
{
	if( !_compressionSession )
		return;
	
	CVReturn result;
	SInt64 timeStamp = ICMCompressionSessionGetTimeScale( _compressionSession ) * (1.0/60.0);
	
	CVPixelBufferRef pixelBuffer;
	result = CVPixelBufferPoolCreatePixelBuffer( kCFAllocatorDefault, _pixelBufferPool, &pixelBuffer);
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
	void *pixelBufferBytes = CVPixelBufferGetBaseAddress( pixelBuffer );
	size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
	
	int rowIndex;
	for( rowIndex = 0; rowIndex < height; rowIndex++ )
		memcpy( pixelBufferBytes+rowIndex*bytesPerRow, bitmapBytes+rowIndex*pitch,width*4);

	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0);
	ICMSourceTrackingCallbackRecord trackingCallback = { SourceFrameTrackingCallback, &pixelBuffer };
	result = ICMCompressionSessionEncodeFrame( _compressionSession, pixelBuffer, timeStamp*_currentFrame,0,kICMValidTime_DisplayTimeStampIsValid, NULL, &trackingCallback,NULL);
	// the compression session should retain it and will release it when it's done
	CVPixelBufferRelease( pixelBuffer );
	if( result ) {
		printf("ICMCompressionSessionEncodeFrame() failed with %d\n", result);
		return;
	}
	
	_currentFrame++;
}

@end
