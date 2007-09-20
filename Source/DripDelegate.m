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

- (void)awakeFromNib
{
	SetMouseCoalescingEnabled(true,NULL);
	_inspectors = [DripInspectors sharedController];
	[_inspectors loadWindow];
}

- (IBAction)newFile:(id)sender
{
	[_newFileWindow makeKeyAndOrderFront:sender];
}

- (IBAction)okNewFile:(id)sender
{
	DripDocument *_newDocument = [[DripDocument alloc] initWithWidth:[_widthField intValue] height:[_heightField intValue]];
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

@end
