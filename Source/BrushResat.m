//
//  BrushResat.m
//  Drip
//
//  Created by Nur Monson on 9/13/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "BrushResat.h"


@implementation BrushResat

- (NSRect)renderPointAt:(PressurePoint)aPoint onLayer:(PaintLayer *)aLayer
{
	float brushSize = _intSize*aPoint.pressure;
	int brushSizeHalf;
	
	int x = (int)aPoint.x;
	int y = (int)aPoint.y;
	unsigned int layerHeight = [aLayer height];
	unsigned int layerPitch = [aLayer pitch];
	unsigned char *p = [aLayer data] + (layerHeight-y-1)*layerPitch + x*4;
	float red, green, blue;
	float alpha = ((float)*p)/255.0f; p++;
	if( alpha == 0.0f ) {
		red = blue = green = 0.0f;
	} else {
		red = ((float)*p)/(255.0f*alpha); p++;
		green = ((float)*p)/(255.0f*alpha); p++;
		blue = ((float)*p)/(255.0f*alpha);
	}
	red = red*(1.0f-0.11)+_RGBAColor[0]*0.11;
	green = green*(1.0f-0.11)+_RGBAColor[1]*0.11;
	blue = blue*(1.0f-0.11)+_RGBAColor[2]*0.11;
	
	if(!_pressureAffectsSize)
		brushSize = _intSize;
	if(_pressureAffectsFlow)
		CGContextSetRGBFillColor([aLayer cxt],red,green,blue,aPoint.pressure);
	else
		CGContextSetRGBFillColor([aLayer cxt],red,green,blue,_RGBAColor[3]);
	
	brushSizeHalf = brushSize/2.0f;
	CGContextDrawImage([aLayer cxt],CGRectMake(aPoint.x-(brushSize-1.0f)/2.0f,aPoint.y-(brushSize-1.0f)/2.0f,brushSize,brushSize),_dab);
	
	//I don't really  think this fix is very good but...
	//it does work and doesn't cost much.
	return NSMakeRect(aPoint.x-brushSizeHalf-2, aPoint.y-brushSizeHalf-2, brushSize+4, brushSize+4);
}

@end
