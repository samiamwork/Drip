//
//  TIPBrushEraser.m
//  sketchChat
//
//  Created by Nur Monson on 4/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TIPBrushEraser.h"


@implementation TIPBrushEraser

#define ONEOVER_255		0.00392156862f

static void render_dab_quick(int x, int y, TIPLayer *l, int size, float *dabLookup, unsigned char red, unsigned char green, unsigned char blue, float alpha)
{
	int row,col;
	int xoffset = 0;
	int xend = size;
	int yoffset = 0;
	int yend = size;
	unsigned char *p;
	int distanceFromDabCenter;
	int radius = size/2;
	x -= radius;
	y -= radius;
	
	if(x<0) {
		xoffset = -x;
		x = 0;
	}
	if(x + size > l->width) {
		xend = l->width - x;
	}
	
	if(y<0) {
		yend += y;
		y = 0;
	}
	if(y + size > l->height) {
		yoffset = y - l->height;
	}
	
	p = l->data + l->height*l->pitch - ((y+(yend-yoffset))*l->pitch) - (l->pitch - x*4);
	
	for(row=yoffset; row<yend; row++) {
		for(col=xoffset; col<xend; col++) {
			distanceFromDabCenter = (int)sqrtf((col - radius)*(col - radius)+(-row+size - radius)*(-row+size - radius));
			
			if(distanceFromDabCenter <= radius) {
				*p = 0; p++;
				*p = 0; p++;
				*p = 0; p++;
				*p = 0; p++;
			} else {
				p += 4;
			}
		}
		p += l->pitch - (((xend-xoffset))*4);
	}
	
}

static void render_dab(float x, float y, TIPLayer *l, float size, float *dabLookup, unsigned char red, unsigned char green, unsigned char blue, float alpha)
{
	int row,col;
	int sizei = (int)size+2;
	int xi = (int)x - sizei/2;
	int yi = (int)y - sizei/2;
	int xoffset = 0;
	int xend = sizei;
	int yoffset = 0;
	int yend = sizei;
	
	float distanceFromDabCenter;
	float radius = size*0.5f;
	float srcAlpha;
	
	unsigned char *p;
	float oA, nA;
	float oneover_oA;
	float alphaRatio;
	
	if(xi<0) {
		xoffset = -xi;
		xi = 0;
	}
	if(xi + sizei > l->width) {
		xend = l->width - xi;
	}
	
	if(yi<0) {
		yend += yi;
		yi = 0;
	}
	if(yi + sizei > l->height) {
		yoffset = yi - l->height;
	}
	
	p = l->data + l->height*l->pitch - ((yi+(yend-yoffset))*l->pitch) - (l->pitch - xi*4);
	
	for(row=yoffset; row<yend; row++) {
		for(col=xoffset; col<xend; col++) {
			
			distanceFromDabCenter = sqrtf(((float)(xi+col) - x)*((float)(xi+col) - x)+((float)(-row+yi+sizei) - y)*((float)(-row+yi+sizei) - y));
			
			if(distanceFromDabCenter < radius) {
				
				srcAlpha = dabLookup[(int)((distanceFromDabCenter/radius)*1000.0f)];
				oA = (float)(*p) * ONEOVER_255;
				
				if(oA < srcAlpha) {
					*p = 0; p++;
					*p = 0; p++;
					*p = 0; p++;
					*p = 0; p++;
				} else {
					
					nA = oA - srcAlpha;
					*p = (unsigned char)(nA*255.0f);
					
					oneover_oA = 1.0f/(oA+ONEOVER_255);
					alphaRatio = oneover_oA * nA;
					
					p++;
					*p = (unsigned char)((float)(*p) * alphaRatio); p++;
					*p = (unsigned char)((float)(*p) * alphaRatio); p++;
					*p = (unsigned char)((float)(*p) * alphaRatio); p++;
				}
			} else {
				p += 4;
			} // end if (within radius)
		}
		p += l->pitch - (((xend-xoffset))*4);
	}
}

- (NSRect)renderPointAt:(TIPPressurePoint)loc OnLayer:(TIPLayer*)l WithColor:(float*)rgba;
{
	float brushSize = mainSize*loc.pressure;
	int brushSizeHalf;
	
	unsigned char red = rgba[0]*255.0f;
	unsigned char green = rgba[1]*255.0f;
	unsigned char blue = rgba[2]*255.0f;
	
	if(!pressureAffectsSize)
		brushSize = mainSize;
	
	brushSizeHalf = brushSize/2.0f;
	if(smooth) {
		render_dab(loc.point.x, loc.point.y, l, brushSize,
				   bezierCoordinates, red, green, blue, rgba[3]);
	} else {
		render_dab_quick(loc.point.x, loc.point.y, l, brushSize,
						 bezierCoordinates, red, green, blue, rgba[3]);
	}
	
	return NSMakeRect(loc.point.x-brushSizeHalf+2, loc.point.y-brushSizeHalf+2, brushSize+4, brushSize+4);
}

@end
