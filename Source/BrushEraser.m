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

- (void)setSize:(float)newSize
{
	[super setSize:newSize];
	if( _eraserScratchData != NULL )
		free(_eraserScratchData);
	unsigned int intSize = (unsigned int)ceilf( newSize );
	_scratchSize = intSize*intSize;
	_eraserScratchData = (unsigned char*)malloc( _scratchSize );
	
	if( _eraserScratchCxt != NULL )
		CGContextRelease(_eraserScratchCxt);
	_eraserScratchCxt = CGBitmapContextCreate(_eraserScratchData,intSize,intSize,8,intSize,NULL,kCGImageAlphaOnly);
}

- (NSRect)renderPointAt:(PressurePoint)aPoint onLayer:(PaintLayer *)aLayer
{
	float brushSize = _brushSize*aPoint.pressure;
	float brushSizeHalf;
	/*
	 if(!pressureAffectsSize)
	 brushSize = mainSize;
	 if(pressureAffectsOpacity)
	 alpha *= aPoint.pressure;
	 */
	brushSizeHalf = brushSize/2.0f;
	
	/*
	render_dab(aPoint.x, aPoint.y, aLayer, brushSize,
			   _brushLookup, red, green, blue, alpha);
	 */
	
	int xi = (int)ceilf(aPoint.x - brushSizeHalf);
	int yi = (int)ceilf(aPoint.y - brushSizeHalf);
	int xend = xi+(int)ceilf(brushSize);
	int yend = yi+(int)ceilf(brushSize);
	float srcAlpha;
	
	float oA, nA;
	float oneover_oA;
	float alphaRatio;
	
	unsigned int layerWidth = [aLayer width];
	unsigned int layerHeight = [aLayer height];
	unsigned int layerPitch = [aLayer pitch];
	
	unsigned int eraserPitch = CGBitmapContextGetBytesPerRow(_eraserScratchCxt);
	unsigned char *e = _eraserScratchData + (CGBitmapContextGetHeight(_eraserScratchCxt)-1)*eraserPitch;
	
	NSPoint offset = NSMakePoint(aPoint.x-xi-brushSizeHalf,aPoint.y-yi-brushSizeHalf);
	
	if(xi<0) {
		if( xend <= 0 )
			return NSZeroRect;
		e += -xi;
		xi = 0;
	} if(xend > layerWidth) {
		if( xi >= layerWidth )
			return NSZeroRect;
		xend = layerWidth;
	}
	
	if(yi<0) {
		if( yend <= 0 )
			return NSZeroRect;
		e -= (0 - yi)*eraserPitch;
		yi = 0;
	} if(yend > layerHeight) {
		if( yi >= layerHeight )
			return NSZeroRect;
		yend = layerHeight;
	}
	
	
	bzero(_eraserScratchData,_scratchSize);
	CGContextSetRGBFillColor(_eraserScratchCxt,0.0f,0.0f,0.0f,1.0f);
	CGContextDrawImage(_eraserScratchCxt,CGRectMake(offset.x,offset.y,brushSize,brushSize),_dab);
	
	unsigned char *p = [aLayer data] + (layerHeight-yi-1)*layerPitch + xi*4;// - (yend-yi-1)*layerPitch;
	
	int row,col;
	//the row loop variables are only used for counting
	//actual data movement it in reverse to match the dab
	for( row=yi; row<yend; row++) {
		for(col=xi; col<xend; col++) {
			srcAlpha = ((float)e[col-xi])/255.0f;
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
			
		}
		p -= layerPitch + (((xend-xi))*4);
		e -= eraserPitch;
	}	
	
	//I don't really  think this fix is very good but...
	//it does work and doesn't cost much.
	return NSMakeRect(aPoint.x-brushSizeHalf-2, aPoint.y-brushSizeHalf-2, brushSize+4, brushSize+4);
}

#pragma mark Settings

- (void)changeSettings:(DripEventBrushSettings *)theSettings
{
	if( [theSettings type] != kBrushTypeEraser )
		return;
	
	[self setSize:[theSettings size]];
	[self setHardness:[theSettings hardness]];
	[self setSpacing:[theSettings spacing]];
	[self setPressureAffectsFlow:[theSettings pressureAffectsFlow]];
	[self setPressureAffectsSize:[theSettings pressureAffectsSize]];
	[self setColor:[theSettings color]];
}
- (DripEventBrushSettings *)settings
{
	return [[[DripEventBrushSettings alloc] initWithType:kBrushTypeEraser size:_brushSize hardness:_hardness spacing:_spacing pressureAffectsFlow:_pressureAffectsFlow pressureAffectsSize:_pressureAffectsSize color:[NSColor colorWithCalibratedRed:_RGBAColor[0] green:_RGBAColor[1] blue:_RGBAColor[2] alpha:_RGBAColor[3]]] autorelease];
}
@end
