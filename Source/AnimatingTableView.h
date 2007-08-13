//
//  AnimatingTableView.h
//  Drip
//
//  Created by Nur Monson on 8/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AnimatingTableView : NSTableView {
	int _movingRowIndexStart;
	int _movingRowIndexEnd;
	NSTimer *_animationTimer;
	NSAnimation *_slidingAnimation;
}

- (void)slideRowFromIndex:(int)fromIndex toIndex:(int)toIndex;
@end
