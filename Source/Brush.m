//
//  Brush.m
//  Drip
//
//  Created by Nur Monson on 8/6/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "Brush.h"

#import "DripEventStrokeBegin.h"
#import "DripEventStrokeContinue.h"
#import "DripEventStrokeEnd.h"

NSString *const kPaintBrushSizeKey = @"paintBrushSize";
NSString *const kPaintBrushHardnessKey = @"paintBrushHardness";
NSString *const kPaintBrushSpacingKey = @"paintBrushSpacing";
NSString *const kPaintBrushResaturationKey = @"paintBrushResaturation";
NSString *const kPaintBrushOpacityKey = @"paintBrushOpacity";
NSString *const kPaintBrushBlendModeKey = @"paintBrushBlendMode";
NSString *const kPaintBrushPressureAffectsSizeKey = @"paintBrushPressureAffectsSize";
NSString *const kPaintBrushPressureAffectsFlowKey = @"paintBrushPressureAffectsFlow";
NSString *const kPaintBrushPressureAffectsResaturationKey = @"paintBrushPressureAffectsResaturation";
NSString *const kPaintBrushColorKey = @"paintBrushColor";

@implementation Brush

+ (void)initialize
{
	NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
	[defaultPrefs setValue:[NSNumber numberWithFloat:20.0f] forKey:kPaintBrushSizeKey];
	[defaultPrefs setValue:[NSNumber numberWithFloat:0.8f] forKey:kPaintBrushHardnessKey];
	[defaultPrefs setValue:[NSNumber numberWithFloat:0.2f] forKey:kPaintBrushSpacingKey];
	[defaultPrefs setValue:[NSNumber numberWithFloat:1.0f] forKey:kPaintBrushResaturationKey];
	[defaultPrefs setValue:[NSNumber numberWithFloat:1.0f] forKey:kPaintBrushOpacityKey];
	[defaultPrefs setValue:[NSNumber numberWithInt:kCGBlendModeNormal] forKey:kPaintBrushBlendModeKey];
	[defaultPrefs setValue:[NSNumber numberWithBool:YES] forKey:kPaintBrushPressureAffectsSizeKey];
	[defaultPrefs setValue:[NSNumber numberWithBool:NO] forKey:kPaintBrushPressureAffectsFlowKey];
	[defaultPrefs setValue:[NSNumber numberWithBool:NO] forKey:kPaintBrushPressureAffectsResaturationKey];
	[defaultPrefs setValue:[NSArchiver archivedDataWithRootObject:[NSColor blackColor]] forKey:kPaintBrushColorKey];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];
}

- (id)init
{
	if( (self = [super init]) ) {
		_dab = NULL;
		_dabData = NULL;
		_workLayer = nil;
		[self setColor:[NSColor blackColor]];
		
		_brushSize = 0.0f;
		[self setSize:50.0f];
		[self setHardness:0.4f];
		[self setSpacing:0.25f];
		[self setResaturation:1.0f];
		[self setStrokeOpacity:1.0f];
		[self setBlendMode:kCGBlendModeNormal];
		[self setPressureAffectsResaturation:NO];
		[self setPressureAffectsFlow:NO];
		[self setPressureAffectsSize:YES];
		
		_strokeEvents = [[NSMutableArray alloc] init];

		//_brushLookup = (float *)malloc(1001*sizeof(float));
		//[self createBezierCurveWithCrossover:0.4f];
		_settingsHaveChanged = YES;
	}

	return self;
}

- (void)dealloc
{
	//free(_brushLookup);
	CGImageRelease(_dab);
	if( _dabData )
		free(_dabData );
	[_workLayer release];
	[_strokeEvents release];
	
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
	else if( t > 1.0f || t<0.0f )
		return 0.0f;
	
	float y = 0.5f*cosf(M_PI*(t-crossover)/(1.0f-crossover))+0.5f;
	return y;
}

- (void)rebuildBrush
{
	if( _dab != NULL )
		CGImageRelease(_dab);
	
	unsigned int intSize = (int)ceilf(_brushSize);
	if( !(intSize & 1) )
		intSize += 1;
	
	if( _dabData != NULL )
		free(_dabData);
	_dabData = (unsigned char *)calloc(intSize*intSize,1);
	
	unsigned char *p = _dabData;
	float center = (float)((intSize-1)/2);
	// better? still doesn't fix problem though
	//float center = ((float)intSize)/2.0f;
	float distanceFromCenter;
	int row;
	int col;
	int vOffset;
	int hOffset;
	float x;
	float y;
	float totalValue;
	for( row=0; row < intSize; row++ ) {
		for( col=0; col < intSize; col++ ) {
			totalValue = 0.0f;
			for( vOffset=-1; vOffset < 2; vOffset++ ) {
				for( hOffset=-1; hOffset < 2; hOffset++ ) {
					x = (float)col + (float)hOffset*0.5f;
					y = (float)row + (float)vOffset*0.5f;
					if( (float)x == center && (float)y == center )
						distanceFromCenter = 0.0f;
					else
						distanceFromCenter = sqrtf((x - center)*(x - center)+(y - center)*(y - center))/(_brushSize/2.0f);
					
					totalValue += valueWithCosCurve(distanceFromCenter,_hardness);
				}
			}
			*p = (unsigned char)(255.0f*(totalValue/9.0f));
			p++;
		}
	}

	_intSize = (float)intSize;
	CGDataProviderRef dataProviderRef = CGDataProviderCreateWithData(NULL, _dabData,intSize*intSize, NULL);
	float decode[2] = {1.0,0.0f};
	_dab = CGImageMaskCreate(intSize,intSize,8,8,intSize,dataProviderRef,decode,YES);
	if( _dab == NULL )
		printf("no mask created\n");
	CGDataProviderRelease(dataProviderRef);
}

- (void)setCanvasSize:(NSSize)newCanvasSize
{
	[_workLayer release];
	_workLayer = [[PaintLayer alloc] initWithWidth:(unsigned int)newCanvasSize.width height:(unsigned int)newCanvasSize.height];
	[_workLayer setBlendMode:_blendMode];
	[_workLayer setOpacity:_strokeOpacity];
}

- (void)setSize:(float)newSize
{
	if( newSize < 1.0f )
		newSize = 1.0f;
	if( newSize == _brushSize )
		return;
	
	_brushSize = newSize;
	
	[self rebuildBrush];
	_settingsHaveChanged = YES;
}
- (float)size
{
	return _brushSize;
}
- (BOOL)usesSize
{
	return YES;
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
	_settingsHaveChanged = YES;
}
- (float)hardness
{
	return _hardness;
}
- (BOOL)usesHardness
{
	return YES;
}

- (void)setSpacing:(float)newSpacing
{
	if( newSpacing < 0.01f)
		newSpacing = 0.01f;
	if( newSpacing > 1.5f )
		newSpacing = 1.5f;
	
	_spacing = newSpacing;
	_settingsHaveChanged = YES;
}
- (float)spacing
{
	return _spacing;
}
- (BOOL)usesSpacing
{
	return YES;
}

- (void)setResaturation:(float)newResaturation
{
	if( newResaturation < 0.0f )
		newResaturation = 0.0f;
	else if( newResaturation > 1.0f )
		newResaturation = 1.0f;
	
	_resaturation = newResaturation;
	_settingsHaveChanged = YES;
}
- (float)resaturation
{
	return _resaturation;
}
- (BOOL)usesResaturation
{
	return YES;
}

- (void)setStrokeOpacity:(float)newStrokeOpacity
{
	if( newStrokeOpacity < 0.0f )
		newStrokeOpacity = 0.0f;
	else if( newStrokeOpacity > 1.0f )
		newStrokeOpacity = 1.0f;
	
	if( newStrokeOpacity == _strokeOpacity )
		return;
	
	_strokeOpacity = newStrokeOpacity;
	[_workLayer setOpacity:_strokeOpacity];
	_settingsHaveChanged = YES;
}
- (float)strokeOpacity
{
	return _strokeOpacity;
}
- (BOOL)usesStrokeOpacity
{
	return YES;
}

- (void)setBlendMode:(CGBlendMode)newBlendMode
{
	_blendMode = newBlendMode;
	[_workLayer setBlendMode:_blendMode];
	_settingsHaveChanged = YES;
}
- (CGBlendMode)blendMode
{
	return _blendMode;
}
- (BOOL)usesBlendMode
{
	return YES;
}

- (void)setPressureAffectsFlow:(BOOL)willAffectFlow
{
	_pressureAffectsFlow = willAffectFlow;
	_settingsHaveChanged = YES;
}
- (BOOL)pressureAffectsFlow
{
	return _pressureAffectsFlow;
}
- (BOOL)usesPressureAffectsFlow
{
	return YES;
}

- (void)setPressureAffectsSize:(BOOL)willAffectSize
{
	_pressureAffectsSize = willAffectSize;
	_settingsHaveChanged = YES;
}
- (BOOL)pressureAffectsSize
{
	return _pressureAffectsSize;
}
- (BOOL)usesPressureAffectsSize
{
	return [self usesSize];
}

- (void)setPressureAffectsResaturation:(BOOL)willAffectResaturation
{
	_pressureAffectsResaturation = willAffectResaturation;
	_settingsHaveChanged = YES;
}
- (BOOL)pressureAffectsResaturation
{
	return _pressureAffectsResaturation;
}
- (BOOL)usesPressureAffectsResaturation
{
	return [self usesResaturation];
}

- (void)setColor:(NSColor*)aColor
{
	NSColor *rgb = [aColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	[rgb getRed:&_RGBAColor[0] green:&_RGBAColor[1] blue:&_RGBAColor[2] alpha:&_RGBAColor[3]];
	_settingsHaveChanged = YES;
}
- (NSColor*)color
{
	return [NSColor colorWithCalibratedRed:_RGBAColor[0] green:_RGBAColor[1] blue:_RGBAColor[2] alpha:_RGBAColor[3]];
}
- (BOOL)usesColor
{
	return YES;
}

- (BrushType)type
{
	return kBrushTypePaint;
}
/*
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
*/
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

- (void)drawDabAtPoint:(NSPoint)aPoint
{
	CGContextDrawImage([[NSGraphicsContext currentContext] graphicsPort],CGRectMake(aPoint.x-(_intSize-1)/2.0f,aPoint.y-(_intSize-1)/2.0f,_intSize,_intSize),_dab);
}

void sampleBitmap(unsigned char *bitmap, unsigned int pitch, unsigned int width, unsigned int height, unsigned int x, unsigned int y, float *red, float *green, float *blue)
{
	float alpha;
	unsigned char *p = bitmap + (height-y-1)*pitch + x*4;
	if( x < 0 || x >= width || y < 0 || y >= height )
		alpha = 0.0f;
	else
		alpha = ((float)*p)/255.0f; p++;
		
	if( alpha == 0.0f ) {
		*red = *green = *blue = 0.0f;
	} else {
		*red = ((float)*p)/(255.0f*(alpha)); p++;
		*green = ((float)*p)/(255.0f*(alpha)); p++;
		*blue = ((float)*p)/(255.0f*(alpha));
	}
}
- (NSRect)beginStrokeAtPoint:(PressurePoint)aPoint onLayer:(Layer *)aLayer
{
	int x = (int)aPoint.x;
	int y = (int)aPoint.y;
	
	void *bitmapData = [[aLayer mainPaintLayer] data];
	unsigned int bitmapPitch = [[aLayer mainPaintLayer] pitch];
	unsigned int bitmapWidth = [[aLayer mainPaintLayer] width];
	unsigned int bitmapHeight = [[aLayer mainPaintLayer] height];
	
	float red, green, blue;
	sampleBitmap( bitmapData, bitmapPitch, bitmapWidth, bitmapHeight, x, y, &red, &green, &blue);
	_resatColor[0] = red;
	_resatColor[1] = green;
	_resatColor[2] = blue;
	sampleBitmap( bitmapData, bitmapPitch, bitmapWidth, bitmapHeight, x, y+_intSize/4, &red, &green, &blue);
	_resatColor[0] += red;
	_resatColor[1] += green;
	_resatColor[2] += blue;
	sampleBitmap( bitmapData, bitmapPitch, bitmapWidth, bitmapHeight, x+_intSize/4, y, &red, &green, &blue);
	_resatColor[0] += red;
	_resatColor[1] += green;
	_resatColor[2] += blue;
	sampleBitmap( bitmapData, bitmapPitch, bitmapWidth, bitmapHeight, x, y-_intSize/4, &red, &green, &blue);
	_resatColor[0] += red;
	_resatColor[1] += green;
	_resatColor[2] += blue;
	sampleBitmap( bitmapData, bitmapPitch, bitmapWidth, bitmapHeight, x-_intSize/4, y, &red, &green, &blue);
	_resatColor[0] += red;
	_resatColor[1] += green;
	_resatColor[2] += blue;
	
	_resatColor[0] /= 5.0f;
	_resatColor[1] /= 5.0f;
	_resatColor[2] /= 5.0f;
	_paintingLayer = aLayer;
	_lastBrushPosition = aPoint;
	_leftoverDistance = 0.0f;
	
	[_paintingLayer attachLayer:_workLayer];

	_strokeRect = [self renderPointAt:aPoint onLayer:_workLayer];
	
	DripEventStrokeBegin *newEvent = [[DripEventStrokeBegin alloc] initWithPosition:NSMakePoint(aPoint.x,aPoint.y) pressure:aPoint.pressure];
	[_strokeEvents addObject:newEvent];
	[newEvent release];
	
	return _strokeRect;
}
#define TVAL 0.75f
float interpolateBetween( float a, float b, float c )
{
	float p0 = (TVAL-0.0f);
	float p1 = (TVAL-0.5f);
	float p2 = (TVAL-1.0f);
	
	float midpoint =	(p1*p2* a )/((0.0f-0.5f)*(0.0f-1.0f)) +
						(p0*p2* b )/((0.5f-0.0f)*(0.5f-1.0f)) +
						(p0*p1* c )/((1.0f-0.5f)*(1.0f-0.0f));
	return midpoint;
}

- (NSRect)continueStrokeAtPoint:(PressurePoint)aPoint
{
	// we're currently rejecting equal points in the render line method
	// but this has the problem of discarding the last point drawn including it's pressure
	// so the next line will start from a pressure that was not previously drawn.
	// however this does not seem undesireable since the pressure *did* in fact change that fast.
	//if( aPoint.x == _lastBrushPosition.x && aPoint.y == _lastBrushPosition.y )
	//	return NSZeroRect;
	
	NSRect invalidRect;
	
	if( [_strokeEvents count] > 1 ) {
		DripEventStrokeContinue *point0 = [_strokeEvents objectAtIndex:[_strokeEvents count]-2];
		//DripEventStrokeContinue *point1 = [_strokeEvents objectAtIndex:[_strokeEvents count]-1];
		
		NSPoint vec2 = NSMakePoint(aPoint.x-_lastBrushPosition.x, aPoint.y-_lastBrushPosition.y);
		float vec2Length = sqrtf(vec2.x*vec2.x + vec2.y*vec2.y);
		
		if( vec2Length > 10.0f ) {
			PressurePoint midpoint;
			midpoint.x = interpolateBetween([point0 position].x, _lastBrushPosition.x, aPoint.x);
			midpoint.y = interpolateBetween([point0 position].y, _lastBrushPosition.y, aPoint.y);
			midpoint.pressure = interpolateBetween([point0 pressure], _lastBrushPosition.pressure, aPoint.pressure);
			
			invalidRect = [self renderLineFromPoint:_lastBrushPosition toPoint:&midpoint onLayer:_workLayer leftover:&_leftoverDistance];
			_lastBrushPosition = midpoint;
			NSRect newRect = [self renderLineFromPoint:_lastBrushPosition toPoint:&aPoint onLayer:_workLayer leftover:&_leftoverDistance];
			invalidRect = NSUnionRect( invalidRect, newRect );
			
			_lastBrushPosition = aPoint;			
		} else {
			invalidRect = [self renderLineFromPoint:_lastBrushPosition toPoint:&aPoint onLayer:_workLayer leftover:&_leftoverDistance];
			_lastBrushPosition = aPoint;
		}
		
		_vec1 = vec2;
		_vec1Length = vec2Length;
	} else {
		DripEventStrokeBegin *strokeBegin = [_strokeEvents objectAtIndex:0];
		_vec1 = NSMakePoint( aPoint.x-[strokeBegin position].x, aPoint.y-[strokeBegin position].y);
		_vec1Length = sqrtf(_vec1.x*_vec1.x + _vec1.y*_vec1.y);
		
		invalidRect = [self renderLineFromPoint:_lastBrushPosition toPoint:&aPoint onLayer:_workLayer leftover:&_leftoverDistance];
		_lastBrushPosition = aPoint;
		
	}
	
	DripEventStrokeContinue *newEvent = [[DripEventStrokeContinue alloc] initWithPosition:NSMakePoint(aPoint.x,aPoint.y) pressure:aPoint.pressure];
	[_strokeEvents addObject:newEvent];
	[newEvent release];
	
	_strokeRect = NSUnionRect(_strokeRect,invalidRect);
	
	return invalidRect;
}
- (NSRect)endStroke
{
	DripEventStrokeBegin *newEvent = [[DripEventStrokeEnd alloc] init];
	[_strokeEvents addObject:newEvent];
	[newEvent release];
	
	[_paintingLayer commitLayer:_workLayer rect:NSIntegralRect(_strokeRect)];
	return _strokeRect;
}

- (NSArray*)popStrokeEvents
{
	NSArray *poppedEvents = [NSArray arrayWithArray:_strokeEvents];
	[_strokeEvents removeAllObjects];
	return poppedEvents;
}

- (NSRect)renderPointAt:(PressurePoint)aPoint onLayer:(PaintLayer *)aLayer
{
	float brushSize = _intSize*aPoint.pressure;
	int brushSizeHalf;

	float resat = _resaturation;
	if( _pressureAffectsResaturation )
		resat *= aPoint.pressure;
	
	_resatColor[0] = _resatColor[0]*(1.0f-resat)+_RGBAColor[0]*resat;
	_resatColor[1] = _resatColor[1]*(1.0f-resat)+_RGBAColor[1]*resat;
	_resatColor[2] = _resatColor[2]*(1.0f-resat)+_RGBAColor[2]*resat;
	
	if(!_pressureAffectsSize)
		brushSize = _intSize;
	
	if(_pressureAffectsFlow)
		CGContextSetRGBFillColor([aLayer cxt],_resatColor[0],_resatColor[1],_resatColor[2],_RGBAColor[3]*aPoint.pressure);
	else
		CGContextSetRGBFillColor([aLayer cxt],_resatColor[0],_resatColor[1],_resatColor[2],_RGBAColor[3]);
	
	brushSizeHalf = brushSize/2.0f;
	CGContextDrawImage([aLayer cxt],CGRectMake(aPoint.x-(brushSize-1.0f)/2.0f,aPoint.y-(brushSize-1.0f)/2.0f,brushSize,brushSize),_dab);
	//CGContextFillRect([aLayer cxt],CGRectMake(aPoint.x-5.0f,aPoint.y-5.0f,10.0f,10.0f));
	
	//I don't really  think this fix is very good but...
	//it does work and doesn't cost much.
	return NSMakeRect(aPoint.x-brushSizeHalf-2, aPoint.y-brushSizeHalf-2, brushSize+4, brushSize+4);
}

- (NSRect)renderLineFromPoint:(PressurePoint)startPoint toPoint:(PressurePoint *)endPoint onLayer:(PaintLayer *)aLayer leftover:(float *)leftoverDistance
{
	if( startPoint.x == endPoint->x && startPoint.y == endPoint->y )
		return NSZeroRect;
	
	float x,y;
	float brushSize;
	float baseBrushSize = _intSize;
	float pressure;
	float stepSize;
	float length = sqrtf((endPoint->x-startPoint.x)*(endPoint->x-startPoint.x) + (endPoint->y-startPoint.y)*(endPoint->y-startPoint.y));
	float xRatio = (endPoint->x - startPoint.x)/length;
	float yRatio = (endPoint->y - startPoint.y)/length;
	NSRect rect;
	NSRect pointRect;
	
	rect = NSMakeRect(x,y,0.0f,0.0f);
	
	// FIX: this breaks pressure affecting opacity
	if(!_pressureAffectsSize) {
		//startPoint.pressure = 1.0f;
		//endPoint->pressure = 1.0f;
	}
	 
	pressure = startPoint.pressure;
	brushSize = baseBrushSize;
	if( _pressureAffectsSize )
		brushSize = baseBrushSize * pressure;
	stepSize = brushSize * _spacing;

	float position = stepSize-*leftoverDistance;
	length += *leftoverDistance;
	pressure = startPoint.pressure + ((position/(length-*leftoverDistance)) * (endPoint->pressure-startPoint.pressure));
	
	// as long as the step size is less than the distance left to the end of the line...
	if(length < stepSize ) {
		*leftoverDistance = length;
		return NSZeroRect;
	}
	
	x = startPoint.x;
	y = startPoint.y;
	rect.size.width = baseBrushSize;
	if( _pressureAffectsSize )
		rect.size.width = baseBrushSize*pressure;
	rect.size.height = rect.size.width;
	rect.origin.x = x-rect.size.width/2.0f;
	rect.origin.y = y-rect.size.width/2.0f;
	
	while( position < length-*leftoverDistance ) {
		// get new brush size
		if( _pressureAffectsSize )
			brushSize = baseBrushSize * pressure;
		// get new step size
		stepSize = brushSize * _spacing;
		// advance x and y
		x = startPoint.x + position * xRatio;
		y = startPoint.y + position * yRatio;
		
		// draw dab
		pointRect = [self renderPointAt:(PressurePoint){x,y,pressure} onLayer:aLayer];
		
		position += stepSize;
		pressure = startPoint.pressure + ((position/(length-*leftoverDistance)) * (endPoint->pressure-startPoint.pressure));
	}
	
	*leftoverDistance = length - (position+*leftoverDistance-stepSize);	
	
	return NSUnionRect(rect,pointRect);
}

#pragma mark Settings
- (BOOL)didSettingsChange
{
	BOOL settingsWereChanged = _settingsHaveChanged;
	_settingsHaveChanged = NO;
	return settingsWereChanged;
}

- (void)saveSettings
{
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
	
	[standardDefaults setFloat:[self size] forKey:kPaintBrushSizeKey];
	[standardDefaults setFloat:[self hardness] forKey:kPaintBrushHardnessKey];
	[standardDefaults setFloat:[self spacing] forKey:kPaintBrushSpacingKey];
	[standardDefaults setFloat:[self resaturation] forKey:kPaintBrushResaturationKey];
	[standardDefaults setFloat:[self strokeOpacity] forKey:kPaintBrushOpacityKey];
	[standardDefaults setInteger:[self blendMode] forKey:kPaintBrushBlendModeKey];
	[standardDefaults setBool:[self pressureAffectsSize] forKey:kPaintBrushPressureAffectsSizeKey];
	[standardDefaults setBool:[self pressureAffectsFlow] forKey:kPaintBrushPressureAffectsFlowKey];
	[standardDefaults setBool:[self pressureAffectsResaturation] forKey:kPaintBrushPressureAffectsResaturationKey];
	[standardDefaults setObject:[NSArchiver archivedDataWithRootObject:[self color]] forKey:kPaintBrushColorKey];
}

- (void)loadSettings
{
	NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
	
	[self setSize:[standardDefaults floatForKey:kPaintBrushSizeKey]];
	[self setHardness:[standardDefaults floatForKey:kPaintBrushHardnessKey]];
	[self setSpacing:[standardDefaults floatForKey:kPaintBrushSpacingKey]];
	[self setResaturation:[standardDefaults floatForKey:kPaintBrushResaturationKey]];
	[self setStrokeOpacity:[standardDefaults floatForKey:kPaintBrushOpacityKey]];
	[self setBlendMode:(CGBlendMode)[standardDefaults integerForKey:kPaintBrushBlendModeKey]];
	[self setPressureAffectsSize:[standardDefaults boolForKey:kPaintBrushPressureAffectsSizeKey]];
	[self setPressureAffectsFlow:[standardDefaults boolForKey:kPaintBrushPressureAffectsFlowKey]];
	[self setPressureAffectsResaturation:[standardDefaults boolForKey:kPaintBrushPressureAffectsResaturationKey]];
	[self setColor:[NSUnarchiver unarchiveObjectWithData:[standardDefaults dataForKey:kPaintBrushColorKey]]];
}
@end
