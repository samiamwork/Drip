//
//  DripDelegate.h
//  Drip
//
//  Created by Nur Monson on 8/1/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DripInspectors.h"

@interface DripDelegate : NSObject {
	IBOutlet NSWindow *_newFileWindow;
	
	IBOutlet NSTextField *_widthField;
	IBOutlet NSTextField *_heightField;
	
	IBOutlet NSColorWell *_backgroundColorWell;
	IBOutlet NSMatrix *_colorRadio;
	
	IBOutlet NSButton *_imageCheckbox;
	
	DripInspectors *_inspectors;
}

- (IBAction)newFile:(id)sender;
- (IBAction)okNewFile:(id)sender;
- (IBAction)cancelNewFile:(id)sender;
- (IBAction)colorChanged:(id)sender;
- (IBAction)sizeChanged:(id)sender;
- (IBAction)clearBackgroundToggled:(id)sender;
@end
