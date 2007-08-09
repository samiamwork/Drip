//
//  DripDocumentWindowController.m
//  Drip
//
//  Created by Nur Monson on 7/28/07.
//  Copyright theidiotproject 2007 . All rights reserved.
//

#import "DripDocumentWindowController.h"
#import "DripDocument.h"

@implementation DripDocumentWindowController

- (void)awakeFromNib
{
	Canvas *newCanvas = [[Canvas alloc] initWithWidth:[(DripDocument*)[self document] width]  height:[(DripDocument*)[self document] height]];
	[_sketchView setCanvas:newCanvas];
	[newCanvas release];
	
	_theCanvas = newCanvas;
	[_layerTable setDelegate:self];
	[_layerTable setDataSource:self];
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
