//
//  DripDelegate.m
//  Drip
//
//  Created by Nur Monson on 8/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripDelegate.h"
#import "DripDocument.h"

@implementation DripDelegate

+ (void)initialize
{
	NSDictionary *defaultPrefs = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSArchiver archivedDataWithRootObject:[NSColor whiteColor]],@"canvasBackgroundColor",
		[NSNumber numberWithBool:NO],@"isNewCanvasBackgroundClear",
		[NSNumber numberWithInt:300],@"canvasWidth",
		[NSNumber numberWithInt:300],@"canvasHeight",
		nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
	[defaultPrefs release];
}

- (void)awakeFromNib
{
	SetMouseCoalescingEnabled(false,NULL);
	_inspectors = [DripInspectors sharedController];
	[_inspectors loadWindow];
	
	[_widthField setIntValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"canvasWidth"] intValue]];
	[_heightField setIntValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"canvasHeight"] intValue]];
	[_backgroundColorWell setColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] dataForKey:@"canvasBackgroundColor"]]];
	if( [[NSUserDefaults standardUserDefaults] boolForKey:@"isNewCanvasBackgroundClear"] )
		[_colorRadio selectCellWithTag:1];
	else
		[_colorRadio selectCellWithTag:0];
	
	[_newFileWindow center];
}

- (IBAction)newFile:(id)sender
{
	[_newFileWindow makeKeyAndOrderFront:sender];
}

- (IBAction)okNewFile:(id)sender
{
	[self sizeChanged:nil];
	DripDocument *_newDocument = [[DripDocument alloc] initWithWidth:[_widthField intValue] height:[_heightField intValue] backgroundColor:[[_colorRadio selectedCell] tag] ? nil : [_backgroundColorWell color]];
	[[NSDocumentController sharedDocumentController] addDocument:_newDocument];
	[_newDocument makeWindowControllers];
	[_newDocument showWindows];
	[_newDocument release];
	[_newFileWindow orderOut:sender];
}

- (IBAction)cancelNewFile:(id)sender
{
	[_newFileWindow orderOut:sender];
}

- (IBAction)colorChanged:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSArchiver archivedDataWithRootObject:[_backgroundColorWell color]] forKey:@"canvasBackgroundColor"];
}

- (IBAction)sizeChanged:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[_widthField intValue]] forKey:@"canvasWidth"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[_heightField intValue]] forKey:@"canvasHeight"];
}

- (IBAction)clearBackgroundToggled:(id)sender
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[[_colorRadio selectedCell] tag] ? YES : NO] forKey:@"isNewCanvasBackgroundClear"];
}

#pragma mark Application Delegate Methods

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	[_newFileWindow orderOut:nil];
	return NO;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

#pragma mark NewFile window Delegate methods

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	NSPasteboard *thePasteboard = [NSPasteboard generalPasteboard];
	NSString *bestType = [thePasteboard availableTypeFromArray:[NSArray arrayWithObject:NSTIFFPboardType]];
	if( !bestType )
		return;
	
	NSImage *pasteboardImage = [[NSImage alloc] initWithPasteboard:thePasteboard];
	[_widthField setIntValue:(int)[pasteboardImage size].width];
	[_heightField setIntValue:(int)[pasteboardImage size].height];
}

@end
