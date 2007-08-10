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
	[_layerController setCanvas:newCanvas];
	
	[newCanvas release];
}

@end
