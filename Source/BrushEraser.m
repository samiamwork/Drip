//
//  BrushEraser.m
//  Drip
//
//  Created by Nur Monson on 8/7/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "BrushEraser.h"


@implementation BrushEraser

static void render_dab(float x, float y, PaintLayer *theLayer, float size, float *dabLookup, unsigned char red, unsigned char green, unsigned char blue, float alpha)
{
	int row,col;
	int sizei = (int)size+2;
	int xi = (int)x - sizei/2;
	int yi = (int)y - sizei/2;
	int xend = xi+sizei;
	int yend = yi+sizei;
	unsigned char *p;
	float distanceFromDabCenter;
	float radius = (size*0.5f);
	float srcAlpha;
	
	float oA, nA;
	float oneover_oA;
	float alphaRatio;
	
	unsigned int layerWidth = [theLayer width];
	unsigned int layerHeight = [theLayer height];
	unsigned char *layerData = [theLayer data];
	unsigned int layerPitch = [theLayer pitch];
	
	if(xi<0)
		xi = 0;
	if(xend > layerWidth)
		xend = layerWidth;
	
	if(yi<0)
		yi = 0;
	if(yend > layerHeight)
		yend = layerHeight;
	
	p = layerData + (layerHeight-yi-1)*layerPitch + xi*4 - (yend-yi-1)*layerPitch;
	
	for(row=yend-1; row>=yi; row--) {
		for(col=xi; col<xend; col++) {
			distanceFromDabCenter = sqrtf(((float)(col) - x)*((float)(col) - x)+((float)(row) - y)*((float)(row) - y));
			
			if(distanceFromDabCenter < radius) {
				srcAlpha = dabLookup[(unsigned int)((distanceFromDabCenter/radius)*1000.0f)];
				oA = (float)(*p) * (1.0f/255.0f);
				
				if(oA < srcAlpha) {
					*p = 0; p++;
					*p = 0; p++;
					*p = 0; p++;
					*p = 0; p++;
				} else {
					
					nA = oA - srcAlpha;
					*p = (unsigned char)(nA*255.0f);
					
					oneover_oA = 1.0f/(oA+(1.0f/255.0f));
					alphaRatio = oneover_oA * nA;
					
					p++;
					*p = (unsigned char)((float)(*p) * alphaRatio); p++;
					*p = (unsigned char)((float)(*p) * alphaRatio); p++;
					*p = (unsigned char)((float)(*p) * alphaRatio); p++;
				}
			} else {
				p += 4;
			}
		}
		p += layerPitch - (((xend-xi))*4);
	}
	
}

- (NSRect)renderPointAt:(PressurePoint)aPoint onLayer:(PaintLayer *)aLayer
{
	float brushSize = _brushSize*aPoint.pressure;
	int brushSizeHalf;
	
	unsigned char red = _RGBAColor[0]*255.0f;
	unsigned char green = _RGBAColor[1]*255.0f;
	unsigned char blue = _RGBAColor[2]*255.0f;
	float alpha = _RGBAColor[3];
	/*
	 if(!pressureAffectsSize)
	 brushSize = mainSize;
	 if(pressureAffectsOpacity)
	 alpha *= aPoint.pressure;
	 */
	brushSizeHalf = brushSize/2.0f;
	
	
	render_dab(aPoint.x, aPoint.y, aLayer, brushSize,
			   _brushLookup, red, green, blue, alpha);
	
	//I don't really  think this fix is very good but...
	//it does work and doesn't cost much.
	return NSMakeRect(aPoint.x-brushSizeHalf-2, aPoint.y-brushSizeHalf-2, brushSize+4, brushSize+4);
}

@end
