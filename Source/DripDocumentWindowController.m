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
	Canvas *newCanvas = [(DripDocument*)[self document] canvas];
	[_sketchView setCanvas:newCanvas];
	[_layerController setCanvas:newCanvas];
}

@end
