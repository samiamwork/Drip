//
//  AnimatingTableView.m
//  Drip
//
//  Created by Nur Monson on 8/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "AnimatingTableView.h"

@interface NSObject (Delegate)
- (void)tableViewAnimationDone:(AnimatingTableView *)aTableView;
@end

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
		
		if( [self delegate] && [[self delegate] respondsToSelector:@selector(tableViewAnimationDone:)] )
			[[self delegate] tableViewAnimationDone:self];
	}
	
	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder
{
	return NO;
}
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	int row = [self rowAtPoint:location];
	int col = [self columnAtPoint:location];
	
	NSTableColumn *clickedColumn = [[self tableColumns] objectAtIndex:col];
	NSCell *clickedCell = [clickedColumn dataCellForRow:row];
	
	if( ![clickedCell isKindOfClass:[NSButtonCell class]] ) {
		[super mouseDown:theEvent];
		return;
	}
	
	NSNumber *value = [[self dataSource] tableView:self objectValueForTableColumn:clickedColumn row:row];
	if( [[self dataSource] respondsToSelector:@selector(tableView:setObjectValue:forTableColumn:row:)] )
		[[self dataSource] tableView:self setObjectValue:([value boolValue] ? [NSNumber numberWithBool:NO] : [NSNumber numberWithBool:YES]) forTableColumn:clickedColumn row:row];
	
	[self setNeedsDisplayInRect:[self rectOfRow:row]];
}

- (void)textDidEndEditing:(NSNotification *)notification;
{
    if ([[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement) {
        /*
		 This is ugly, but just about the only way to do it. 
		 NSTableView is determined to select and edit something else, even the 
		 text field that it just finished editing, unless we mislead it about 
		 what key was pressed to end editing.
		 */
		NSMutableDictionary *newUserInfo;
        NSNotification *newNotification;
		
        newUserInfo = [NSMutableDictionary dictionaryWithDictionary:[notification userInfo]];
        [newUserInfo setObject:[NSNumber numberWithInt:NSIllegalTextMovement] forKey:@"NSTextMovement"];
        newNotification = [NSNotification notificationWithName:[notification name] object:[notification object] userInfo:newUserInfo];
        [super textDidEndEditing:newNotification];
		
        // For some reason we lose firstResponder status when when we do the above.
		[[self window] makeFirstResponder:self];
    } else
        [super textDidEndEditing:notification];
}

@end
