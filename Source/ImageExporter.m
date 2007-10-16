//
//  ImageExporter.m
//  Drip
//
//  Created by Nur Monson on 10/16/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ImageExporter.h"

static ImageExporter *g_sharedController;

@interface ImageExporter (private)
- (void)updatePreview;
@end

@implementation ImageExporter

+ (void)initialize
{
	// default prefs
}

- (id)initWithWindowNibName:(NSString *)nibName
{
	if( (self = [super initWithWindowNibName:nibName]) ) {
		_originalImage = nil;
		_compressedData = nil;
		_path = nil;
	}
	
	return self;
}

+ (ImageExporter *)sharedController
{
	if( g_sharedController == nil ) {
		g_sharedController = [[ImageExporter alloc] initWithWindowNibName:@"ImageExport"];
	}
	
	return g_sharedController;
}

- (void)awakeFromNib
{
	if( _originalImage )
		[self updatePreview];
	// initialize controls with defaults
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
	if( !_originalImage )
		return;
	
	float quality = [_qualitySlider floatValue];
	if( quality > 1.0f )
		quality = 1.0f;
	else if( quality < 0.0f )
		quality = 0.0f;
	
	int format = [_formatPopUp indexOfSelectedItem];
	NSData *previewData = nil;
	if( format == 0 ) // PNG
		previewData = [_originalImage representationUsingType:NSPNGFileType properties:nil];
	else // JPG
		previewData = [_originalImage representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:quality],NSImageCompressionFactor,nil]];
	
	NSBitmapImageRep *previewRep = [NSBitmapImageRep imageRepWithData:previewData];
	NSImage *previewImage = [[NSImage alloc] init];
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
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setCanSelectHiddenExtension:YES];
	[savePanel setExtensionHidden:YES];
	[savePanel setCanCreateDirectories:YES];
	NSString *fileExtension = [_formatPopUp indexOfSelectedItem]==0 ? @"png" : @"jpg";
	[savePanel setRequiredFileType:fileExtension];
	if( [savePanel runModalForDirectory:[_path stringByDeletingLastPathComponent] file:[[[_path lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:fileExtension]] != NSOKButton )
		return NO;
	
	NSString *newFileName = [savePanel filename];
	[_compressedData writeToFile:newFileName atomically:YES];
	
	// clean up some potentially large data so it's not sitting around while we're not using it
	[_compressedData release];
	_compressedData = nil;
	[_originalImage release];
	_originalImage = nil;

	return YES;
}

- (void)setPath:(NSString *)aString
{
	if( aString == _path )
		return;
	
	[_path release];
	_path = [aString retain];
}
@end
