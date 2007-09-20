//
//  AnimatingTableView.h
//  Drip
//
//  Created by Nur Monson on 8/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum TableAnimationState {
	TableAnimationNone = 0,
	TableAnimationSlide,
	TableAnimationFadeOut,
	TableAnimationFadeIn
} TableAnimationState;

@interface AnimatingTableView : NSTableView {
	TableAnimationState _animationState;
	
	int _movingRowIndexStart;
	int _movingRowIndexEnd;
	NSTimer *_animationTimer;
	NSAnimation *_slidingAnimation;
}

- (void)slideRowFromIndex:(int)fromIndex toIndex:(int)toIndex;
- (void)fadeOutRow:(int)rowIndex;
- (void)fadeInRow:(int)rowIndex;
@end
