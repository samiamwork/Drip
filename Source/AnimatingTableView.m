//
//  AnimatingTableView.m
//  Drip
//
//  Created by Nur Monson on 8/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "AnimatingTableView.h"


@implementation AnimatingTableView

- (void)slideRowFromIndex:(int)fromIndex toIndex:(int)toIndex
{
	_movingRowIndexStart = fromIndex;
	_movingRowIndexEnd = toIndex;
	
	_animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/30.0f target:self selector:@selector(animationTick:) userInfo:nil repeats:YES];
	_slidingAnimation = [[NSAnimation alloc] initWithDuration:0.25 animationCurve:NSAnimationEaseOut];
	[_slidingAnimation setAnimationBlockingMode:NSAnimationNonblocking];
	[_slidingAnimation startAnimation];
}

- (NSRect)rectOfRow:(int)rowIndex
{
	NSRect originalRect = [super rectOfRow:rowIndex];
	
	if( ![_slidingAnimation isAnimating] )
		return originalRect;
	
	int minRowIndex = MIN(_movingRowIndexStart,_movingRowIndexEnd);
	int maxRowIndex = MAX(_movingRowIndexStart,_movingRowIndexEnd);
	
	if( rowIndex == _movingRowIndexEnd ) {
		NSRect startRect = [super rectOfRow:_movingRowIndexStart];
		float offset = (originalRect.origin.y-startRect.origin.y)*[_slidingAnimation currentValue];
		if( minRowIndex == _movingRowIndexEnd )
			originalRect.origin.y -= offset;
		else
			originalRect.origin.y -= offset;
		return originalRect;
	}
	
	if( rowIndex >= minRowIndex && rowIndex <= maxRowIndex ) {
		if( minRowIndex == _movingRowIndexStart )
			originalRect.origin.y += [_slidingAnimation currentValue]*[self rowHeight];
		else
			originalRect.origin.y -= [_slidingAnimation currentValue]*[self rowHeight];
	}
	
	return originalRect;
}

- (NSRange)rowsInRect:(NSRect)aRect
{
	NSRange rangeInRect;
	if ( [_slidingAnimation isAnimating] )
		rangeInRect = NSMakeRange(0, [self numberOfRows]);   // just return all rows
	else
		rangeInRect = [super rowsInRect:aRect];
	
	return rangeInRect;
}

- (void)animationTick:(NSTimer*)theTimer
{
	if( [_slidingAnimation currentProgress] == 1.0f ) {
		_movingRowIndexStart = _movingRowIndexEnd = 0;
		[_animationTimer invalidate];
		_animationTimer = nil;
		[_slidingAnimation release];
		_slidingAnimation = nil;
	}
	
	[self setNeedsDisplay:YES];
}

@end
