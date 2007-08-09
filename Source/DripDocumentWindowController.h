//
//  DripDocumentWindowController.h
//  Drip
//
//  Created by Nur Monson on 7/28/07.
//  Copyright theidiotproject 2007 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScrollingSketchView.h"
#import "Canvas.h"

@interface DripDocumentWindowController : NSWindowController
{
	IBOutlet ScrollingSketchView *_sketchView;
	IBOutlet NSWindow *_toolWindow;
	IBOutlet NSTableView *_layerTable;
	Canvas *_theCanvas;
}

- (IBAction)addLayer:(id)sender;
- (IBAction)deleteLayer:(id)sender;
@end
