//
//  ImageExporter.m
//  Drip
//
//  Created by Nur Monson on 10/16/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ImageExporter.h"

static ImageExporter *g_sharedController;

@implementation ImageExporter

+ (ImageExporter *)sharedController
{
	if( g_sharedController == nil ) {
		g_sharedController = [[ImageExporter alloc] initWithWindowNibName:@"ImageExport"];
	}
	
	return g_sharedController;
}

- (void)dealloc
{
	[_originalImage release];

	[super dealloc];
}

- (void)setBitmapImageRep:(NSBitmapImageRep *)anImageRep
{
	if( anImageRep == _originalImage )
		return;
	
	[_originalImage release];
	_originalImage = [anImageRep retain];
}

- (void)updatePreview
{
	float quality = [_qualitySlider floatValue];
	if( quality > 1.0f )
		quality = 1.0f;
	else if( quality < 0.0f )
		quality = 0.0f;
	
	int format = [_formatPopUp indexOfSelectedItem];
	
	if( !_originalImage )
		printf("original image is nil\n");
	
	NSData *previewData = nil;
	if( format == 0 ) // PNG
		previewData = [_originalImage representationUsingType:NSPNGFileType properties:nil];
	else // JPG
		previewData = [_originalImage representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:quality],NSImageCompressionFactor,nil]];
	if( !previewData )
		printf("preview data is nil\n");
	
	NSBitmapImageRep *previewRep = [NSBitmapImageRep imageRepWithData:previewData];
	if( !previewRep )
		printf("preview rep is nil \n");
	NSImage *previewImage = [[NSImage alloc] init];
	if( ! previewImage )
		printf("preview image is nil \n");
	[previewImage addRepresentation:previewRep];
	
	[_preview setImage:previewImage];
	
	[previewImage release];
	
	[_compressedData release];
	_compressedData = [previewData retain];
}

- (IBAction)qualityChanged:(id)sender
{
	float quality = [_qualitySlider floatValue];
	if( quality > 1.0f )
		quality = 1.0f;
	else if( quality < 0.0f )
		quality = 0.0f;
	[_qualitySlider setFloatValue:quality];
	
	// TODO: set defaults
	[self updatePreview];
}

- (IBAction)formatChanged:(id)sender
{
	// TODO: set defaults
	[self updatePreview];
}

- (IBAction)ok:(id)sender
{
	[NSApp stopModal];
}
- (IBAction)cancel:(id)sender
{
	[NSApp abortModal];
}

- (BOOL)runModal
{
	[[self window] makeKeyAndOrderFront:self];
	int result = [NSApp runModalForWindow:[self window]];
	[[self window] orderOut:self];
	if( result == NSRunAbortedResponse )
		return NO;
	
	return YES;
}

- (NSData *)compressedData
{
	return _compressedData;
}

@end
