//
//  Brush.m
//  Drip
//
//  Created by Nur Monson on 8/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "Brush.h"


@implementation Brush

- (id)init
{
	if( (self = [super init]) ) {
		_RGBAColor[0] = 0.0f;
		_RGBAColor[1] = 0.0f;
		_RGBAColor[2] = 0.0f;
		_RGBAColor[3] = 1.0f;
		
		_brushSize = 0.0f;
		_hardness = 0.4f;
		_brushLookup = (float *)malloc(1001*sizeof(float));
		[self createBezierCurveWithCrossover:0.4f];
		
		_dab = NULL;
		_dabData = NULL;
		[self setSize:50.0f];
	}

	return self;
}

- (void)dealloc
{
	free(_brushLookup);
	if( _dab != NULL )
		CGImageRelease(_dab);
	
	[super dealloc];
}

float valueAtCurve(float t, float crossover) {
	float cx,bx,ax;
	float cy,by,ay;
	float x0,x1,x2,x3;
	float y0,y1,y2,y3;
	float xt,yt;
	
	x0 = 0.0f;
	x1 = crossover;
	x2 = crossover;
	x3 = 1.0f;
	
	y0 = 1.0f;
	y1 = 1.0f;
	y2 = 0.0f;
	//y2 = crossover;
	y3 = 0.0f;
	
	cx = 3.0f*(x1 - x0);
	bx = 3.0f*(x2 - x1) - cx;
	ax = x3 - x0 - cx - bx;
	
	cy = 3*(y1 - y0);
	by = 3*(y2 - y1) - cy;
	ay = y3 - y0 - cy - by;
	
	xt = (ax*t*t*t) + (bx*t*t) + cx*t + x0;
	yt = (ay*t*t*t) + (by*t*t) + cy*t + y0;
		
	xt = fabsf(xt);
	if(yt > 1.0f)
		yt = 1.0f;
	else if(yt < 0.0f)
		yt = 0.0f;
	
	return yt;
}

float valueWithCosCurve(float t, float crossover)
{
	if( t <= crossover )
		return 1.0f;
	
	float y = 0.5f*cosf(M_PI*(t-crossover)/(1.0f-crossover))+0.5f;
	return y;
}

- (void)rebuildBrush
{
	if( _dab != NULL )
		CGImageRelease(_dab);
	
	unsigned int intSize = (int)ceilf(_brushSize);
	if( _dabData != NULL )
		free(_dabData);
	_dabData = (unsigned char *)calloc(intSize*intSize,1);
	
	unsigned char *p = _dabData;
	float center = _brushSize/2.0f;
	float distanceFromCenter;
	int row;
	int col;
	for( row=intSize-1; row >= 0; row-- ) {
		for( col=0; col < intSize; col++ ) {
			distanceFromCenter = sqrtf(((float)(col) - center)*((float)(col) - center)+((float)(row) - center)*((float)(row) - center))/center;
			
			if( distanceFromCenter > 1.0f || distanceFromCenter < 0.0f ) {
				*p = 0;
			} else {
				*p = (unsigned char)(255.0f*valueWithCosCurve(distanceFromCenter,_hardness));
			}
			p++;
		}
	}
	
	CGDataProviderRef dataProviderRef = CGDataProviderCreateWithData(NULL, _dabData,intSize*intSize*4, NULL);
	float decode[2] = {1.0,0.0f};
	_dab = CGImageMaskCreate(intSize,intSize,8,8,intSize,dataProviderRef,decode,YES);
	if( _dab == NULL )
		printf("no mask created\n");
	CGDataProviderRelease(dataProviderRef);
}

- (void)setSize:(float)newSize
{
	if( newSize == _brushSize )
		return;
	
	_brushSize = newSize;
	
	[self rebuildBrush];
}
- (float)size
{
	return _brushSize;
}
- (void)setHardness:(float)newHardness
{
	if( newHardness < 0.0f )
		newHardness = 0.0f;
	else if( newHardness > 1.0f )
		newHardness = 1.0f;
	
	if( newHardness == _hardness )
		return;
	
	_hardness = newHardness;
	[self rebuildBrush];
}
- (float)hardness
{
	return _hardness;
}
- (void)setColor:(NSColor*)aColor
{
	NSColor *rgb = [aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	[rgb getRed:&_RGBAColor[0] green:&_RGBAColor[1] blue:&_RGBAColor[2] alpha:&_RGBAColor[3]];
}
- (NSColor*)color
{
	return [NSColor colorWithCalibratedRed:_RGBAColor[0] green:_RGBAColor[1] blue:_RGBAColor[2] alpha:_RGBAColor[3]];
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
		_brushLookup[index] = yt;
	}
	
}

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
	unsigned int srcAlphai;
	unsigned int color;
	
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
		p += layerPitch - (((xend-xi))*4);
	}
}

- (NSRect)renderPointAt:(PressurePoint)aPoint onLayer:(PaintLayer *)aLayer
{
	float brushSize = _brushSize*aPoint.pressure;
	int brushSizeHalf;
	/*
	unsigned char red = _RGBAColor[0]*255.0f;
	unsigned char green = _RGBAColor[1]*255.0f;
	unsigned char blue = _RGBAColor[2]*255.0f;
	float alpha = _RGBAColor[3];
	 */
	/*
	if(!pressureAffectsSize)
		brushSize = mainSize;
	if(pressureAffectsOpacity)
		alpha *= aPoint.pressure;
	*/
	brushSizeHalf = brushSize/2.0f;
	
	
	//render_dab(aPoint.x, aPoint.y, aLayer, brushSize,
	//		   _brushLookup, red, green, blue, alpha);
	//CGContextSetFillColor([aLayer cxt],_RGBAColor);
	CGContextSetRGBFillColor([aLayer cxt],_RGBAColor[0],_RGBAColor[1],_RGBAColor[2],_RGBAColor[3]);
	CGContextDrawImage([aLayer cxt],CGRectMake(aPoint.x-brushSize/2.0f,aPoint.y-brushSize/2.0f,brushSize,brushSize),_dab);
	
	//I don't really  think this fix is very good but...
	//it does work and doesn't cost much.
	return NSMakeRect(aPoint.x-brushSizeHalf-2, aPoint.y-brushSizeHalf-2, brushSize+4, brushSize+4);
}

#define STATICFLOW	0.22f
- (NSRect)renderLineFromPoint:(PressurePoint)startPoint toPoint:(PressurePoint *)endPoint onLayer:(PaintLayer *)aLayer
{
	float x,y;
	float brushSize;
	float baseBrushSize = _brushSize;
	float pressure;
	float stepSize;
	float length = sqrtf((endPoint->x-startPoint.x)*(endPoint->x-startPoint.x) + (endPoint->y-startPoint.y)*(endPoint->y-startPoint.y));
	float xRatio = (endPoint->x - startPoint.x)/length;
	float yRatio = (endPoint->y - startPoint.y)/length;
	float position = 0.0f;
	PressurePoint newEndPoint = startPoint;
	//TIPPressurePoint newEnd = start;
	NSRect rect;
	NSRect pointRect;
	
	x = startPoint.x;
	y = startPoint.y;
	rect = NSMakeRect(x,y,0.0f,0.0f);
	
	/*
	if(!pressureAffectsSize) {
		startPoint.pressure = 1.0f;
		endPoint->pressure = 1.0f;
	}
	*/
	
	pressure = startPoint.pressure;
	brushSize = baseBrushSize * pressure;
	stepSize = brushSize * STATICFLOW;

	position += fabsf(stepSize);
	pressure = startPoint.pressure + ((position/length) * (endPoint->pressure-startPoint.pressure));
	
	// as long as the step size is less than the distance left to the end of the line...
	if(length < stepSize ) {
		*endPoint = newEndPoint;
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
		pointRect = [self renderPointAt:(PressurePoint){x,y,pressure} onLayer:aLayer];
		
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
		
		newEndPoint.x = x;
		newEndPoint.y = y;
		newEndPoint.pressure = pressure;
		
		position += fabsf(stepSize);
		pressure = startPoint.pressure + ((position/length) * (endPoint->pressure-startPoint.pressure));
	}
	
	*endPoint = newEndPoint;
	
	return rect;
}

@end
