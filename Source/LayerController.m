//
//  LayerController.m
//  Drip
//
//  Created by Nur Monson on 8/2/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "LayerController.h"

#define LayerTableViewType @"LayerTableViewType"
@implementation LayerController

- (void)awakeFromNib
{
	[_layerTable setDelegate:self];
	[_layerTable setDataSource:self];
	
	[_layerTable registerForDraggedTypes:[NSArray arrayWithObject:LayerTableViewType]];
	_draggingLayer = nil;
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
	[_opacitySlider setFloatValue:[[_theCanvas currentLayer] opacity]];
}
- (IBAction)deleteLayer:(id)sender
{
	[_theCanvas deleteLayer:[_theCanvas currentLayer]];
	unsigned int indexToSelect = [[_theCanvas layers] indexOfObject:[_theCanvas currentLayer]];
	[_layerTable selectRowIndexes:[NSIndexSet indexSetWithIndex:indexToSelect] byExtendingSelection:NO];
	[_layerTable reloadData];
	[_sketchView setNeedsDisplay:YES];
	[_opacitySlider setFloatValue:[[_theCanvas currentLayer] opacity]];
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

- (IBAction)setOpacity:(id)sender
{
	float oldOpacity = [[_theCanvas currentLayer] opacity];
	[[_theCanvas currentLayer] setOpacity:[sender floatValue]];
	float newOpacity = [[_theCanvas currentLayer] opacity];
	
	if( newOpacity != oldOpacity ) {
		[sender setFloatValue:newOpacity];
		[_theCanvas currentLayerSettingsChanged];
		[_sketchView setNeedsDisplay:YES];
	}
}

#pragma mark Drag and Drop

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
	// I'm only going to allow one row selected at a time
	NSArray *layers = [_theCanvas layers];
	PaintLayer *selectedLayer = [[_theCanvas layers] objectAtIndex:[layers count]-1-[rowIndexes firstIndex]];
	if( selectedLayer == nil )
		return NO;
	
	_draggingLayer = selectedLayer;
	[pboard declareTypes:[NSArray arrayWithObject:LayerTableViewType] owner:self];
	[pboard setData:[NSData data] forType:LayerTableViewType];
	
	return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{	
	// no dropping on items, only above because it makes more visual sense
	if( op == NSTableViewDropOn )
		[tv setDropRow:row dropOperation:NSTableViewDropAbove];

	return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info 
			  row:(int)toTableRow dropOperation:(NSTableViewDropOperation)op
{
	NSArray *layers = [_theCanvas layers];
	int fromLayerRow = [layers indexOfObject:_draggingLayer];
	if( fromLayerRow == NSNotFound ) {
		_draggingLayer = nil;
		return NO;
	}

	toTableRow--;
	int toLayerRow = [layers count]-toTableRow-1;
		
	// no dropping on, above or below the row we're dragging
	if( toLayerRow == fromLayerRow || (toLayerRow == fromLayerRow+1 && op == NSTableViewDropAbove) ) {
		_draggingLayer = nil;
		return NO;
	}

	[_theCanvas insertLayer:_draggingLayer AtIndex:toLayerRow];
	[_sketchView setNeedsDisplay:YES];
	[_opacitySlider setFloatValue:[[_theCanvas currentLayer] opacity]];
	
	//the layer order has changed so we need a new array
	NSArray *newLayers = [_theCanvas layers];
	[_layerTable selectRow:[newLayers count]-[newLayers indexOfObject:[_theCanvas currentLayer]]-1 byExtendingSelection:NO];
	
	[aTableView reloadData];
	
	toTableRow = [newLayers count]-[newLayers indexOfObject:_draggingLayer]-1;
	int fromTableRow = [layers count]-fromLayerRow-1;
	[_layerTable slideRowFromIndex:fromTableRow toIndex:toTableRow];

	_draggingLayer = nil;
	return YES;
}

#pragma mark Layer Table Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	NSArray *layers = [_theCanvas layers];

	[_theCanvas setCurrentLayer:[layers objectAtIndex:[layers count]-[_layerTable selectedRow]-1]];
	[_opacitySlider setFloatValue:[[_theCanvas currentLayer] opacity]];
}

@end
