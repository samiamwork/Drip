//
//  ImageExporter.h
//  Drip
//
//  Created by Nur Monson on 10/16/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Canvas.h"


@interface ImageExporter : NSWindowController {
	IBOutlet NSPopUpButton *_formatPopUp;
	IBOutlet NSSlider *_qualitySlider;
	IBOutlet NSImageView *_preview;
	
	NSBitmapImageRep *_originalImage;
	NSData *_compressedData;
	NSString *_path;
}

+ (ImageExporter *)sharedController;

- (void)setBitmapImageRep:(NSBitmapImageRep *)anImageRep;

- (IBAction)qualityChanged:(id)sender;
- (IBAction)formatChanged:(id)sender;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

// if the session is canceled we return false.
- (BOOL)runModal;
- (void)setPath:(NSString *)aString;

@end
