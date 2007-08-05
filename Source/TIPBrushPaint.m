//
//  TIPBrushPaint.m
//  sketchChat
//
//  Created by Nur Monson on 4/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TIPBrushPaint.h"


@implementation TIPBrushPaint

static void render_dab_quick(int x, int y, TIPLayer *l, int size, float *dabLookup, unsigned char red, unsigned char green, unsigned char blue, float alpha)
{
	int row,col;
	int sizei = (int)size+2;
	int xi = (int)x - sizei/2;
	int yi = (int)y - sizei/2;
	int xoffset = 0;
	int xend = sizei;
	int yoffset = 0;
	int yend = sizei;
	unsigned char *p;
	int distanceFromDabCenter;
	int radius = size/2;
	unsigned int srcAlphai;
	unsigned int color;
	
	if(radius < 1)
		radius = 0;
	radius *= radius;
	
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
	
	srcAlphai = (unsigned int)(255.0f * alpha);
	
	for(row=yoffset; row<yend; row++) {
		for(col=xoffset; col<xend; col++) {
			//distanceFromDabCenter = (int)sqrtf(((float)(xi+col) - x)*((float)(xi+col) - x)+((float)(-row+yi+sizei) - y)*((float)(-row+yi+sizei) - y));
			distanceFromDabCenter = (int)(((xi+col) - x)*((xi+col) - x)+((-row+yi+sizei) - y)*((-row+yi+sizei) - y));
			
			if(distanceFromDabCenter > radius) {
				// we're outside the dab so do nothing
				p += 4;
			} else {
				color = ((unsigned int)*p)*(255-srcAlphai);
				color = color>>8;
				color += srcAlphai;
				*p = (unsigned char)color;
				p++;
				
				color = ((*p)*(255-srcAlphai) + red*srcAlphai)>>8; *p = (unsigned char)color; p++;
				color = ((*p)*(255-srcAlphai) + green*srcAlphai)>>8; *p = (unsigned char)color; p++;
				color = ((*p)*(255-srcAlphai) + blue*srcAlphai)>>8; *p = (unsigned char)color; p++;
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
	unsigned char *p;
	float distanceFromDabCenter;
	float radius = (size*0.5f);
	unsigned int srcAlphai;
	unsigned int color;
	
	
	
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
			//distanceFromDabCenter = frsqrte(((float)(xi+col) - x)*((float)(xi+col) - x)+((float)(-row+yi+sizei) - y)*((float)(-row+yi+sizei) - y));
			
			if(distanceFromDabCenter > radius) {
				// we're outside the dab so do nothing
				p += 4;
			} else {
				srcAlphai = (unsigned int)(255.0f*alpha*dabLookup[(int)((distanceFromDabCenter/radius)*1000.0f)]);
				
				color = ((unsigned int)*p)*(255-srcAlphai);
				color = color/255.0f;
				color += srcAlphai;
				*p = (unsigned char)color;
				p++;
				
				color = (float)((*p)*(255-srcAlphai) + red*srcAlphai)/255.0f; *p = (unsigned char)color; p++;
				color = (float)((*p)*(255-srcAlphai) + green*srcAlphai)/255.0f; *p = (unsigned char)color; p++;
				color = (float)((*p)*(255-srcAlphai) + blue*srcAlphai)/255.0f; *p = (unsigned char)color; p++;
			}
		}
		p += l->pitch - (((xend-xoffset))*4);
	}
}

- (NSRect)renderPointAt:(TIPPressurePoint)loc OnLayer:(TIPLayer*)l WithColor:(float*)rgba;
{
	float brushSize = (mainSize*loc.pressure);
	int brushSizeHalf;
	
	unsigned char red = rgba[0]*255.0f;
	unsigned char green = rgba[1]*255.0f;
	unsigned char blue = rgba[2]*255.0f;
	float alpha = rgba[3];
	
	if(!pressureAffectsSize)
		brushSize = mainSize;
	if(pressureAffectsOpacity)
		alpha *= loc.pressure;
	
	brushSizeHalf = brushSize/2.0f;
	
	if(smooth) {
		render_dab(loc.point.x, loc.point.y, l, brushSize,
				   bezierCoordinates, red, green, blue, alpha);
	} else {
		render_dab_quick(loc.point.x, loc.point.y, l, brushSize,
						 bezierCoordinates, red, green, blue, alpha);
	}

	//I don't really  think this fix is very good but...
	//it does work and doesn't cost much.
	return NSMakeRect(loc.point.x-brushSizeHalf-2, loc.point.y-brushSizeHalf-2, brushSize+4, brushSize+4);
}

@end
