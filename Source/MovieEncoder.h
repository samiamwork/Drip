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
	
	void *_bitmapBytes;
	CGContextRef _bitmapContext;
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;

- (BOOL)promptForPath;
- (NSString *)path;
- (void)setPath:(NSString *)newPath;
- (CGContextRef)frameContext;

- (IBAction)promptForSettings:(id)sender;
- (IBAction)setScale:(id)sender;

- (void)beginMovie;
- (void)endMovie;
- (void)frameReady;

@end
