//
//  TIPBrush.m
//  sketchChat
//
//  Created by Nur Monson on 3/25/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TIPBrush.h"
#define MAXBRUSHSIZE		50

@implementation TIPBrush

- init
{
	[self changeBrushWithMainSize:50.0f TipSize:0.4f];
	[self setPressureAffectsSize:YES];
	[self setPressureAffectsOpacity:NO];
	[self setSmooth:YES];

	return self;
}

- (int)brushSize
{
	return mainSize;
}

- (float)mainSize
{
	return mainSize;
}

-(void)setMainSize:(float)size
{
	[self changeBrushWithMainSize:size TipSize:tipSize];
}

- (float)tipSize
{
	return tipSize;
}
-(void)setTipSize:(float)size
{
	[self changeBrushWithMainSize:mainSize TipSize:size];
}

- (BOOL)smooth
{
	return smooth;
}
- (void)setSmooth:(BOOL)b
{
	smooth = b;
}

- (BOOL)pressureAffectsOpacity
{
	return pressureAffectsOpacity;
}
- (void)setPressureAffectsOpacity:(BOOL)state
{
	pressureAffectsOpacity = state;
}

- (BOOL)pressureAffectsSize
{
	return pressureAffectsSize;
}
- (void)setPressureAffectsSize:(BOOL)state
{
	pressureAffectsSize = state;
}


- (void)createBezierCurveWithCrossover:(float)crossover
{
	int i;
	int index;
	float cx,bx,ax;
	float cy,by,ay;
	float x0,x1,x2,x3;
	float y0,y1,y2,y3;
	float xt,yt;
	float t;
	
	x0 = 0.0f;
	x1 = crossover;
	x2 = crossover;
	x3 = 1.0f;
	
	y0 = 1.0f;
	y1 = 1.0f;
	//y2 = 0.0f;
	y2 = crossover;
	y3 = 0.0f;
	
	cx = 3.0f*(x1 - x0);
	bx = 3.0f*(x2 - x1) - cx;
	ax = x3 - x0 - cx - bx;
	
	cy = 3*(y1 - y0);
	by = 3*(y2 - y1) - cy;
	ay = y3 - y0 - cy - by;
	
	for(i=0; i<10000; i++) {
		t = ((float)i/10000.0f);
		
		xt = (ax*t*t*t) + (bx*t*t) + cx*t + x0;
		yt = (ay*t*t*t) + (by*t*t) + cy*t + y0;
		
		xt = fabsf(xt);
		if(yt > 1.0f)
			yt = 1.0f;
		else if(yt < 0.0f)
			yt = 0.0f;

		index = (int)(xt*1000.0f);
		if(index >= 1000)
			index = 1000;
		bezierCoordinates[index] = yt;
	}
	
}

- (float*)brushLookup
{
	return bezierCoordinates;
}

- (void)changeBrushWithMainSize:(float)mSize TipSize:(float)tSize
{	
	mSize = fabsf(mSize);
	if((int)mSize > MAXBRUSHSIZE)
		mSize = 50.0f;

	tSize = mSize*fabsf(tSize);
	if(tSize > mSize)
		tSize = mSize;
	
	// set instance values
	tipSize = tSize/mSize;
	mainSize = mSize;
	
	[self createBezierCurveWithCrossover:tipSize];
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
			*p = (unsigned char)(255.0f*alpha); p++;				
			*p = red; p++;
			*p = green; p++;
			*p = blue; p++;
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
	
	render_dab(loc.point.x, loc.point.y, l, brushSize,
			   bezierCoordinates, red, green, blue, alpha);
	
	// for some reason the calculated rect is off by some...
	// in vestigate later so we can get rid of this hack!
	return NSMakeRect(loc.point.x-brushSizeHalf+2, loc.point.y-brushSizeHalf+2, brushSize+4, brushSize+4);
}

// Problem with drawing mode = rough
// creates a situation where pixels get drawn adjecent
// must advance at lease one pixel in either x or y. i.e. stepSize must b
#define STATICFLOW	0.15f
- (NSRect)renderLineFrom:(TIPPressurePoint)start To:(TIPPressurePoint*)end OnLayer:(TIPLayer*)l WithColor:(float*)rgba;
{
	float x,y;
	float brushSize;
	float baseBrushSize = mainSize;
	float pressure;
	float stepSize;
	float length = sqrtf((end->point.x-start.point.x)*(end->point.x-start.point.x) + (end->point.y-start.point.y)*(end->point.y-start.point.y));
	float xRatio = (end->point.x - start.point.x)/length;
	float yRatio = (end->point.y - start.point.y)/length;
	float position = 0.0f;
	TIPPressurePoint newEnd = start;
	NSRect rect;
	NSRect pointRect;
	
	x = start.point.x;
	y = start.point.y;
	rect = NSMakeRect(x,y,0.0f,0.0f);
	
	if(!pressureAffectsSize) {
		start.pressure = 1.0f;
		end->pressure = 1.0f;
	}
	
	pressure = start.pressure;
	brushSize = baseBrushSize * pressure;
	stepSize = brushSize * STATICFLOW;
	//
	position += fabsf(stepSize);
	pressure = start.pressure + ((position/length) * (end->pressure-start.pressure));
	
	// as long as the step size is less than the distance left to the end of the line...
	if(length < stepSize ) {
		*end = newEnd;
		return rect;
	}
	while( position < length ) {
		// get new brush size
		brushSize = baseBrushSize * pressure;
		// get new step size
		stepSize = brushSize * STATICFLOW;
		// advance x and y
		x += stepSize * xRatio;
		y += stepSize * yRatio;
		
		// draw dab
		pointRect = [self renderPointAt:TIPMakePressurePoint(x,y,pressure) OnLayer:l WithColor:rgba];
		
		if((int)rect.size.width == 0 && (int)rect.size.height == 0)
			rect = pointRect;
		else {
			// grow our rect to fit the line with the new dab rendered at the end
			if( (pointRect.origin.x + pointRect.size.width) > (rect.origin.x + rect.size.width))
				rect.size.width = pointRect.origin.x + pointRect.size.width - rect.origin.x;
			if( (pointRect.origin.y + pointRect.size.height) > (rect.origin.y + rect.size.height))
				rect.size.height = pointRect.origin.y + pointRect.size.height - rect.origin.y;
			if(pointRect.origin.x < rect.origin.x) {
				rect.size.width += rect.origin.x-pointRect.origin.x;
				rect.origin.x = pointRect.origin.x;
			}
			if(pointRect.origin.y < rect.origin.y) {
				rect.size.height += rect.origin.y - pointRect.origin.y;
				rect.origin.y = pointRect.origin.y;
			}
		}
		
		newEnd.point.x = x;
		newEnd.point.y = y;
		newEnd.pressure = pressure;
		
		position += fabsf(stepSize);
		pressure = start.pressure + ((position/length) * (end->pressure-start.pressure));
	}
	
	*end = newEnd;
	
	//printf("%f, %f, %f, %f\n", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	return rect;
}

@end
