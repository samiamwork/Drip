//
//  ColoredView.h
//  Drip
//
//  Created by Nur Monson on 10/7/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ColoredView : NSView {
	NSColor *_color;
}

- (NSColor *)color;
- (void)setColor:(NSColor *)aColor;
@end
