//
//  ZoomController.h
//  centeredScrollView
//
//  Created by Nur Monson on 12/30/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyImageView.h"

@interface ZoomController : NSObject {
	IBOutlet NSScrollView *theScrollView;
}

- (IBAction)setZoom:(id)sender;
@end
