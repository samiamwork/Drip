//
//  MovieEncoder.h
//  Drip
//
//  Created by Nur Monson on 9/21/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuickTime/QuickTime.h>

@interface MovieEncoder : NSWindowController {
	CVPixelBufferPoolRef _pixelBufferPool;
	Movie _movie;
	Track _track;
	Media _media;
	DataHandler _dataHandler;
	ICMCompressionSessionRef _compressionSession;
	
	unsigned int _width;
	unsigned int _height;
	unsigned int _currentFrame;
	
	NSString *_path;
	
	IBOutlet NSView *_containerView;
	IBOutlet NSTextField *_codecDescription;
	IBOutlet NSTextField *_sizeField;
	IBOutlet NSSlider *_sizeSlider;
	float _scale;
	
	// For export progress
	IBOutlet NSWindow *_progressSheet;
	IBOutlet NSProgressIndicator *_exportProgressBar;
	IBOutlet NSTextField *_exportTimeText;
	
	id _delegate;
	
	void *_bitmapBytes;
	CGContextRef _bitmapContext;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;

- (BOOL)promptForPath;
- (NSString *)path;
- (void)setPath:(NSString *)newPath;
- (CGContextRef)frameContext;
- (void)setDelegate:(id)theDelegate;
- (id)delegate;

- (IBAction)promptForSettings:(id)sender;
- (IBAction)setScale:(id)sender;
- (IBAction)cancelExport:(id)sender;

- (void)setProgress:(double)theProgress timeEstimate:(NSString *)theTimeEstimate;

// begin encoding the movie and attach the progress sheet to theWindow
- (void)beginMovieForWindow:(NSWindow *)theWindow;
- (void)endMovie;
- (void)frameReady;

@end
