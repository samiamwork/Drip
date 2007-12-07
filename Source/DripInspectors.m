//
//  DripInspectors.m
//  Drip
//
//  Created by Nur Monson on 9/7/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "DripInspectors.h"

NSString *DripDocumentActivateNotification = @"DripDocumentActivateNotification";
NSString *DripDocumentDeactivateNotification = @"DripDocumentDeactivateNotification";
static DripInspectors *g_sharedController;
@implementation DripInspectors

+ (void)initialize
{
	NSDictionary *defaultPrefs = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"areAdvancedBrushSettingsShown",nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
	[defaultPrefs release];
}

+ (DripInspectors *)sharedController
{
	if( g_sharedController == nil ) {
		g_sharedController = [[DripInspectors alloc] initWithWindowNibName:@"DripInspectors"];
		
		NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
		[defaultCenter addObserver:g_sharedController selector:@selector(documentActivateNotification:) name:DripDocumentActivateNotification object:nil];
		[defaultCenter addObserver:g_sharedController selector:@selector(documentDeactivateNotification:) name:DripDocumentDeactivateNotification object:nil];
	}
	
	return g_sharedController;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

//old value: 112.0f (assumes collapsed height of 26
#define ADVANCED_VIEW_HEIGHT 133.0f

- (void)awakeFromNib
{
	[self setShouldCascadeWindows:NO];
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
	[[self window] setFrameAutosaveName:@"ToolsInspector"];
	
	// IB is broken and won't let us set max = min so we do it ourselves.
	[[self window] setMaxSize:NSMakeSize([[self window] minSize].width,FLT_MAX)];
	
	// collapse the advanced view if needed
	if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"areAdvancedBrushSettingsShown"] ) {
		[_advancedViewDisclosure setState:NSOffState];
		
		unsigned int layerTableAutoresizingMask = [_layerTable autoresizingMask];
		[_layerTable setAutoresizingMask:layerTableAutoresizingMask ^ NSViewMaxYMargin ^ NSViewHeightSizable];
		unsigned int advancedViewAutoresizingMask = [_advancedView autoresizingMask];
		[_advancedView setAutoresizingMask:advancedViewAutoresizingMask ^ NSViewMinYMargin ^ NSViewHeightSizable];
		
		NSRect frameRect = [[self window] frame];
		//[_advancedView setHidden:YES];
		NSSize minSize = [[self window] minSize];
		minSize.height -= ADVANCED_VIEW_HEIGHT;
		[[self window] setMinSize:minSize];
		frameRect.size.height -= ADVANCED_VIEW_HEIGHT;
		// because the window always unarchives from the nib expanded and the saved frame record
		// in this case is with the window collapsed we need to compensate for the window being too
		// high. So we do not add the normal ADVANCED_VIEW_HEIGHT.
		//frameRect.origin.y += ADVANCED_VIEW_HEIGHT;
		[[self window] setFrame:frameRect display:YES animate:YES];
		
		[_layerTable setAutoresizingMask:layerTableAutoresizingMask];
		[_advancedView setAutoresizingMask:advancedViewAutoresizingMask];
	}
}

- (void)setDripDocument:(DripDocument *)newDocument
{	
	[_brushController setDripDocument:newDocument];

	if( newDocument == nil ) {
		[_layerController disable];
		return;
	}
	[_layerController setCanvas:[newDocument canvas]];
	[_layerController setSketchView:[newDocument sketchView]];
	
	[[self window] orderFront:nil];
}

- (void)layersUpdated
{
	[_layerController layersUpdated];
}

- (IBAction)toggleAdvanced:(id)sender
{
	NSRect frameRect = [[self window] frame];
	NSSize minSize = [[self window] minSize];
	unsigned int layerTableAutoresizingMask = [_layerTable autoresizingMask];
	[_layerTable setAutoresizingMask:layerTableAutoresizingMask ^ NSViewMaxYMargin ^ NSViewHeightSizable];
	unsigned int advancedViewAutoresizingMask = [_advancedView autoresizingMask];
	[_advancedView setAutoresizingMask:advancedViewAutoresizingMask ^ NSViewMinYMargin ^ NSViewHeightSizable];
		
	if( [sender state] == NSOnState ) {
		// expand
		minSize.height += ADVANCED_VIEW_HEIGHT;
		[[self window] setMinSize:minSize];
		
		frameRect.size.height += ADVANCED_VIEW_HEIGHT;
		frameRect.origin.y -= ADVANCED_VIEW_HEIGHT;
		[[self window] setFrame:frameRect display:YES animate:YES];
		
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"areAdvancedBrushSettingsShown"];
	} else {
		minSize.height -= ADVANCED_VIEW_HEIGHT;
		[[self window] setMinSize:minSize];
		
		frameRect.size.height -= ADVANCED_VIEW_HEIGHT;
		frameRect.origin.y += ADVANCED_VIEW_HEIGHT;
		[[self window] setFrame:frameRect display:YES animate:YES];
		
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"areAdvancedBrushSettingsShown"];
	}
	
	[_layerTable setAutoresizingMask:layerTableAutoresizingMask];
	[_advancedView setAutoresizingMask:advancedViewAutoresizingMask];
}

@end
