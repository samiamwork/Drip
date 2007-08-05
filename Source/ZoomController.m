//
//  ZoomController.m
//  centeredScrollView
//
//  Created by Nur Monson on 12/30/06.
//  Copyright 2006 theidiotproject. All rights reserved.
//

#import "ZoomController.h"


@implementation ZoomController

- (IBAction)setZoom:(id)sender
{
	if( [sender floatValue] == [[theScrollView documentView] zoom] )
		return;

	[[theScrollView documentView] setZoom:[sender floatValue]];
}

@end
