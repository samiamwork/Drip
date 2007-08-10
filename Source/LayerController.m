//
//  LayerController.m
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "LayerController.h"


@implementation LayerController

- (void)awakeFromNib
{
	[_layerTable setDelegate:self];
	[_layerTable setDataSource:self];
}

- (void)setCanvas:(Canvas *)newCanvas
{
	if( newCanvas == _theCanvas )
		return;
	
	[_theCanvas release];
	_theCanvas = [newCanvas retain];
	
	[_layerTable reloadData];
}

- (IBAction)addLayer:(id)sender
{
	[_theCanvas addLayer];
	unsigned int indexToSelect = [[_theCanvas layers] indexOfObject:[_theCanvas currentLayer]];
	[_layerTable selectRowIndexes:[NSIndexSet indexSetWithIndex:indexToSelect] byExtendingSelection:NO];
	[_layerTable reloadData];
	[_sketchView setNeedsDisplay:YES];
}
- (IBAction)deleteLayer:(id)sender
{
	[_theCanvas deleteLayer:[_theCanvas currentLayer]];
	unsigned int indexToSelect = [[_theCanvas layers] indexOfObject:[_theCanvas currentLayer]];
	[_layerTable selectRowIndexes:[NSIndexSet indexSetWithIndex:indexToSelect] byExtendingSelection:NO];
	[_layerTable reloadData];
	[_sketchView setNeedsDisplay:YES];
}

#pragma mark Layer Table Datasource

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[_theCanvas layers] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSArray *layers = [_theCanvas layers];
	//layers are sorted in reverse
	return [[layers objectAtIndex:[layers count]-rowIndex-1] name];
}

#pragma mark Layer Table Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSArray *layers = [_theCanvas layers];
	[_theCanvas setCurrentLayer:[layers objectAtIndex:[layers count]-[_layerTable selectedRow]-1]];
}

@end
