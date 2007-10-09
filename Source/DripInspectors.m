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

#define ADVANCED_VIEW_HEIGHT 112.0f

- (void)awakeFromNib
{
	[(NSPanel *)[self window] setBecomesKeyOnlyIfNeeded:YES];
	
	// collapse the advanced view if it's open
	// TODO: add a pref to control if this was last open or closed.
	if( ![_advancedView isHidden] ) {
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
		frameRect.origin.y += ADVANCED_VIEW_HEIGHT;
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
	[_layerController setScrollingSketchView:[newDocument scrollingSketchView]];
	
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
		
		//[_advancedView setHidden:NO];
	} else {
		//[_advancedView setHidden:YES];
		minSize.height -= ADVANCED_VIEW_HEIGHT;
		[[self window] setMinSize:minSize];
		
		frameRect.size.height -= ADVANCED_VIEW_HEIGHT;
		frameRect.origin.y += ADVANCED_VIEW_HEIGHT;
		[[self window] setFrame:frameRect display:YES animate:YES];
	}
	
	[_layerTable setAutoresizingMask:layerTableAutoresizingMask];
	[_advancedView setAutoresizingMask:advancedViewAutoresizingMask];
}

@end
