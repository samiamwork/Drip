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
	NSDictionary *defaultPrefs = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0f],@"imageExportQuality",[NSNumber numberWithInt:0],@"imageExportFormat",nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
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
		[g_sharedController window];
	}
	
	return g_sharedController;
}

- (void)awakeFromNib
{
	if( _originalImage )
		[self updatePreview];

	[_formatPopUp selectItemAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"imageExportFormat"]];
	if( [_formatPopUp indexOfSelectedItem] == 0 ) { // PNG
		[_qualitySlider setFloatValue:1.0f];
		[_qualitySlider setEnabled:NO];
	} else {
		[_qualitySlider setFloatValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"imageExportQuality"]];
		[_qualitySlider setEnabled:YES];
	}
}

- (void)dealloc
{
	[_originalImage release];
	[_compressedData release];

	[super dealloc];
	g_sharedController = nil;
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
	
	float fileSize = [_compressedData length];
	NSArray *sizeExtensions = [NSArray arrayWithObjects:@"B",@"KB",@"MB",@"GB",nil];
	unsigned int extensionIndex = 0;
	while( fileSize > 1024.0f && extensionIndex < [sizeExtensions count] ) {
		fileSize /= 1024.0f;
		extensionIndex++;
	}
	
	[_sizeField setStringValue:[NSString stringWithFormat:@"%.02f %@",fileSize,[sizeExtensions objectAtIndex:extensionIndex]]];
}

- (IBAction)qualityChanged:(id)sender
{
	float quality = [_qualitySlider floatValue];
	if( quality > 1.0f )
		quality = 1.0f;
	else if( quality < 0.0f )
		quality = 0.0f;
	[_qualitySlider setFloatValue:quality];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:quality] forKey:@"imageExportQuality"];
	[self updatePreview];
}

- (IBAction)formatChanged:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[_formatPopUp indexOfSelectedItem]] forKey:@"imageExportFormat"];
	// TODO: if the selection doesn't care about compression then disable the slider. If not, enable it.
	int format = [_formatPopUp indexOfSelectedItem];
	if( format == 0 ) { // PNG
		[_qualitySlider setFloatValue:1.0f];
		[_qualitySlider setEnabled:NO];
		[(NSSavePanel *)[self window] setRequiredFileType:@"png"];
	} else {
		[_qualitySlider setFloatValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"imageExportQuality"]];
		[_qualitySlider setEnabled:YES];
		[(NSSavePanel *)[self window] setRequiredFileType:@"jpg"];
	}
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
	[self updatePreview];
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setCanSelectHiddenExtension:YES];
	[savePanel setExtensionHidden:YES];
	[savePanel setCanCreateDirectories:YES];
	int format = [[NSUserDefaults standardUserDefaults] integerForKey:@"imageExportFormat"];
	NSString *fileExtension = format==0 ? @"png" : @"jpg";
	[savePanel setRequiredFileType:fileExtension];
	[self setWindow:savePanel];
	[_auxView setFrame:NSMakeRect(0.0f,0.0f,361.0f,236.0f)];
	[savePanel setAccessoryView:_auxView];
	[_auxView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable ];
	[savePanel setTitle:@"Export Image"];
	// we don't know exactly how big the aux view space is so we're trying to make
	// sure  our aux view doesn't get smashed
	[_auxView setFrame:[[_auxView superview] bounds]];
	if( [savePanel runModalForDirectory:[_path stringByDeletingLastPathComponent] file:[[[_path lastPathComponent] stringByDeletingPathExtension] stringByAppendingPathExtension:fileExtension]] != NSOKButton ) {
		[savePanel setAccessoryView:nil];
		[_compressedData release];
		_compressedData = nil;
		[_originalImage release];
		_originalImage = nil;
		
		return NO;
	}
	[savePanel setAccessoryView:nil];
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
