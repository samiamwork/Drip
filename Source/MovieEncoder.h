//
//  MovieEncoder.h
//  Drip
//
//  Created by Nur Monson on 9/21/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuickTime/QuickTime.h>

@interface MovieEncoder : NSObject {
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
}

- (id)initWithWidth:(unsigned int)width height:(unsigned int)height;

- (void)promptForPath;
- (NSString *)path;
- (void)setPath:(NSString *)newPath;

- (void)promptForSettings;

- (void)beginMovie;
- (void)endMovie;
- (void)addFrameFromData:(void *)bitmapBytes width:(unsigned int)width height:(unsigned int)height pitch:(unsigned int)pitch;
@end
