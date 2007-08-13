//
//  AnimatingTableView.h
//  Drip
//
//  Created by Nur Monson on 8/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AnimatingTableView : NSTableView {
	int _movingRowIndex;
	NSTimer *_animationTimer;
	NSAnimation *_slidingAnimation;
}

- (void)slideInRowAtIndex:(int)rowToMove;
@end
