//
//  AnimatingTableView.m
//  Drip
//
//  Created by Nur Monson on 8/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "AnimatingTableView.h"


@implementation AnimatingTableView

- (void)slideInRowAtIndex:(int)rowToMove
{
	_movingRowIndex = rowToMove;
	_animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/30.0f target:self selector:@selector(animationTick:) userInfo:nil repeats:YES];
	_slidingAnimation = [[NSAnimation alloc] initWithDuration:0.5 animationCurve:NSAnimationEaseOut];
	[_slidingAnimation setAnimationBlockingMode:NSAnimationNonblocking];
	[_slidingAnimation startAnimation];
}

- (NSRect)rectOfRow:(int)rowIndex
{
	NSRect originalRect = [super rectOfRow:rowIndex];
	
	if( ![_slidingAnimation isAnimating] )
		return originalRect;
	
	if( rowIndex > _movingRowIndex )
		originalRect.origin.y -= [_slidingAnimation currentValue]*[self rowHeight];
	
	return originalRect;
}

- (void)animationTick:(NSTimer*)theTimer
{
	if( [_slidingAnimation currentProgress] == 1.0f ) {
		_movingRowIndex = 0;
		[_animationTimer invalidate];
		_animationTimer = nil;
		[_slidingAnimation release];
		_slidingAnimation = nil;
	}
	
	[self setNeedsDisplay:YES];
}

@end
