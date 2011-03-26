//
//  AnimatingTableView.m
//  Drip
//
//  Created by Nur Monson on 8/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "AnimatingTableView.h"

@protocol TableViewAnimationDelegate
- (void)tableViewAnimationDone:(AnimatingTableView *)aTableView;
@end

typedef struct {
	float red, green, blue, alpha;
} RGBAColor;

typedef struct {
	RGBAColor colorOne;
	RGBAColor colorTwo;
} TwoColors;

static void linearColorBlend( void *info, const float *in, float *out )
{
	TwoColors *twoColors = (TwoColors *)info;
	
	out[0] = twoColors->colorOne.red*(1.0f - *in) + twoColors->colorTwo.red*(*in);
	out[1] = twoColors->colorOne.green*(1.0f - *in) + twoColors->colorTwo.green*(*in);
	out[2] = twoColors->colorOne.blue*(1.0f - *in) + twoColors->colorTwo.blue*(*in);
	out[3] = twoColors->colorOne.alpha*(1.0f - *in) + twoColors->colorTwo.alpha*(*in);
}

static void linearColorBlendReleaseInfoFunction( void *info )
{
	free( info );
}

static const CGFunctionCallbacks linearFunctionCallbacks = {0, &linearColorBlend, &linearColorBlendReleaseInfoFunction};

@implementation AnimatingTableView

#pragma mark gradient drawing

- (id)_highlightColorForCell:(NSCell *)cell;
{
	return nil;
}

- (void)highlightSelectionInClipRect:(NSRect)aRect
{
	NSColor *alternateSelectedControlColor = [NSColor alternateSelectedControlColor];
	[alternateSelectedControlColor setFill];
	NSRect rowRect = [self rectOfRow:[self selectedRow]];
	if( _slidingAnimation ) {
		// Drawing a gradient is pretty slow so we just do a solid fill if we're animating.
		NSRectFill( rowRect );
		return;
	}
	float hue, saturation, brightness, alpha;
	[[alternateSelectedControlColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	
	NSColor *lighterColor = [NSColor colorWithDeviceHue:hue saturation:MAX(0.0f,saturation-0.12f) brightness:MIN(1.0f,brightness+0.3f) alpha:alpha];
	NSColor *darkerColor = [NSColor colorWithDeviceHue:hue saturation:MIN(1.0f,(saturation > 0.4f)? saturation+0.12f : 0.0f) brightness:MAX(0.0f,brightness-0.045f) alpha:alpha];
	
	
	TwoColors *twoColors = (TwoColors *)malloc( sizeof(TwoColors) );
	static const float domainAndRange[8] = {0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f};
	CGFunctionRef linearBlendFunctionRef = CGFunctionCreate( twoColors, 1, domainAndRange, 4, domainAndRange, &linearFunctionCallbacks );
	
	[lighterColor getRed:&twoColors->colorOne.red green:&twoColors->colorOne.green blue:&twoColors->colorOne.blue alpha:&twoColors->colorOne.alpha];
	[darkerColor getRed:&twoColors->colorTwo.red green:&twoColors->colorTwo.green blue:&twoColors->colorTwo.blue alpha:&twoColors->colorTwo.alpha];
	
	NSRect topLine;
	NSRect gradientRect;
	NSDivideRect( rowRect, &topLine, &gradientRect, 1.0f, NSMinYEdge );
	NSRectFill( topLine );
	
	CGContextRef cxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState( cxt ); {
		CGContextClipToRect( cxt, *(CGRect *)&rowRect );
		CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
		CGShadingRef shading = CGShadingCreateAxial( colorspace,CGPointMake(gradientRect.origin.x,gradientRect.origin.y),CGPointMake(gradientRect.origin.x,gradientRect.origin.y+gradientRect.size.height), linearBlendFunctionRef, NO,NO);
		CGColorSpaceRelease( colorspace );
		CGContextDrawShading( cxt, shading );
		CGShadingRelease( shading );
	} CGContextRestoreGState( cxt );
	
	CGFunctionRelease( linearBlendFunctionRef );
}

- (void)slideRowFromIndex:(int)fromIndex toIndex:(int)toIndex
{
	_animationState = TableAnimationSlide;
	
	_movingRowIndexStart = fromIndex;
	_movingRowIndexEnd = toIndex;
	
	_animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/30.0f target:self selector:@selector(animationTick:) userInfo:nil repeats:YES];
	_slidingAnimation = [[NSAnimation alloc] initWithDuration:0.25 animationCurve:NSAnimationEaseOut];
	[_slidingAnimation setAnimationBlockingMode:NSAnimationNonblocking];
	[_slidingAnimation startAnimation];
}

- (void)fadeOutRow:(int)rowIndex
{
	_animationState = TableAnimationFadeOut;
	_movingRowIndexStart = rowIndex;
	
	_animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/30.0f target:self selector:@selector(animationTick:) userInfo:nil repeats:YES];
	_slidingAnimation = [[NSAnimation alloc] initWithDuration:0.25 animationCurve:NSAnimationEaseOut];
	[_slidingAnimation setAnimationBlockingMode:NSAnimationNonblocking];
	[_slidingAnimation startAnimation];
}

- (void)fadeInRow:(int)rowIndex
{
	_animationState = TableAnimationFadeIn;
	_movingRowIndexStart = rowIndex;
	
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
	
	if( _animationState == TableAnimationFadeOut || _animationState == TableAnimationFadeIn ) {
		if( rowIndex <= _movingRowIndexStart)
			return originalRect;
		
		float animationValue = [_slidingAnimation currentValue];
		if( _animationState == TableAnimationFadeOut )
			originalRect.origin.y -= originalRect.size.height*(1.0f-animationValue);
		else
			originalRect.origin.y -= originalRect.size.height*animationValue;
		
		return originalRect;
	}
	
	// if we're sliding
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
			[(id <TableViewAnimationDelegate>)[self delegate] tableViewAnimationDone:self];
	}
	
	[self setNeedsDisplay:YES];
}

#pragma mark Not Animation

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
