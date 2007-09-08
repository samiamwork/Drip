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

- (void)awakeFromNib
{
	printf("awake!\n");
}

- (void)setDripDocument:(DripDocument *)newDocument
{
	printf("set document\n");
	[_brushController setNewBrush:[newDocument brush] eraser:[newDocument eraser]];
	[_brushController setBrush:[[newDocument scrollingSketchView] brush]];
	[_brushController setScrollingSketchView:[newDocument scrollingSketchView]];
	
	[_layerController setCanvas:[newDocument canvas]];
	[_layerController setScrollingSketchView:[newDocument scrollingSketchView]];
	
	[[self window] orderFront:nil];
}
@end
