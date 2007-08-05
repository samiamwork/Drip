#import "SketchView.h"
//#import "TabletApplication.h"

@implementation SketchView

#define STATICFLOW		0.15f

- (void)createNewLayer:(int)width:(int)height:(TIPLayer *)l
{
	CGColorSpaceRef colorSpace;
	
	// TODO if data not null then free it
	
	l->data = calloc(width*height, 4);
	
	if(!l->data) {
		printf("Layer memory allocation failed");
	}
	
	l->width = width;
	l->height = height;
	l->pitch = width*4;
	
	colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	l->cxt = CGBitmapContextCreate(l->data, width, height, 8, l->pitch, colorSpace, kCGImageAlphaPremultipliedFirst);
	if(!l->cxt) {
		free(l->data);
		printf("Could not create bitmap context!\n");
	}
	CGColorSpaceRelease(colorSpace);
}


- (id)initWithFrame:(NSRect)frameRect
{
	//NSSize newSize;
	int i;
	
	if ((self = [super initWithFrame:frameRect]) != nil) {
		
		for(i=0; i<MAX_LAYERS; i++) {
			[self createNewLayer:(int)frameRect.size.width :(int)frameRect.size.height :&layerList[i]];
		}
		
		cLayer = 0;
		
		[NSColor setIgnoresAlpha: NO];
		defaultBrush = [[TIPBrushPaint alloc] init];
		currentBrush = defaultBrush;
		mForeColor = [[NSColor redColor] retain];
	}
	
	return self;
}

// these proximity events should be handled farther up the chain...
- (void)tabletProximity:(NSEvent *)theEvent
{
	if([theEvent isEnteringProximity]) {
		if([theEvent pointingDeviceType] == NSEraserPointingDevice) {
			
			//currentBrush = eraserBrush;
			if([delegate respondsToSelector:@selector(changeToEraser:)]) {
				[delegate changeToEraser];
			}
		} else {
			
			//currentBrush = paintBrush;
			if([delegate respondsToSelector:@selector(changeToPen:)]) {
				[delegate changeToPen];
			}
		}
	}
}

- (void)tabletPoint:(NSEvent *)theEvent
{
	//printf("tablet %f\n", [theEvent pressure]);
	//[self handleMouseEvent:theEvent];
	//mLastLoc = [self convertPoint:[theEvent locationInWindow]
	//					 fromView:nil];
	
	/*
	CGContextSetRGBFillColor(layerList[cLayer].cxt, [mForeColor redComponent], [mForeColor greenComponent], [mForeColor blueComponent], [mForeColor alphaComponent]);
	// Save the loc the mouse down occurred at. This will be used by the
	// Drawing code during a Drag event to follow.
	mLastLoc = [self convertPoint:[theEvent locationInWindow]
						 fromView:nil];
	mLastPressure = [theEvent pressure];
	
	[self paintDabAt:mLastLoc WithPressure:[theEvent pressure] Brush:currentBrush ToLayer:&layerList[cLayer]];
	 */
}

- (void)mouseDown:(NSEvent *)theEvent
{
	float rgba[4] = {[mForeColor redComponent], [mForeColor greenComponent], [mForeColor blueComponent], [mForeColor alphaComponent]};
	float pressure;
	NSPoint position;
	
	// Save the loc the mouse down occurred at. This will be used by the
	// Drawing code during a Drag event to follow.
	position = [self convertPoint:[theEvent locationInWindow]
						 fromView:nil];
	pressure = [theEvent pressure];
	
	lastLocation.point.x = position.x;
	lastLocation.point.y = position.y;
	lastLocation.pressure = pressure;
	
	[self paintDabAt:lastLocation WithBrush:currentBrush ToLayer:cLayer WithColor:rgba];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	BOOL keepOn = YES;
	
	//[NSApp setMouseCoalescingEnabled:NO];
	while (keepOn) {
		theEvent = [[self window] nextEventMatchingMask:NSLeftMouseUpMask |
				NSLeftMouseDraggedMask];
			
		switch ([theEvent type])
		{
			case NSLeftMouseDragged:
				[self drawCurrentDataFromEvent:theEvent];
				break;
				
			case NSLeftMouseUp:
				keepOn = NO;
				break;
					
			default:
				/* Ignore any other kind of event. */
				break;
		}
	}

	//[NSApp setMouseCoalescingEnabled:YES];
}


- (void)mouseUp:(NSEvent *)theEvent
{
	[self handleMouseEvent:theEvent];
}

-(void)handleMouseEvent:(NSEvent *)theEvent
{
	NSPoint	loc;
	float pressure;
	
	loc = [theEvent locationInWindow];
	
	// pressure: is not valid for MouseMove events
	if([theEvent type] != NSMouseMoved) {
		pressure = [theEvent pressure];
	} else {
		pressure = 0.0;
	}
			
	if( [self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:[self bounds]] ) {
		return;
	}
			
}

-(void) drawCurrentDataFromEvent:(NSEvent *)theEvent
{
	float rgba[4];
	float pressure;
	NSPoint position;
	
	rgba[0] = [mForeColor redComponent];
	rgba[1] = [mForeColor greenComponent];
	rgba[2] = [mForeColor blueComponent];
	rgba[3] = [mForeColor alphaComponent];	
		
	position = [self convertPoint:[theEvent locationInWindow]
							fromView:nil];
	pressure = [theEvent pressure];
	
	currentLocation.point.x = position.x;
	currentLocation.point.y = position.y;
	currentLocation.pressure = pressure;
	
	lastLocation = [self paintLineFrom:lastLocation To:currentLocation WithBrush:currentBrush ToLayer:cLayer WithColor:rgba];
}


void draw_layer_rect(CGContextRef baseCxt, TIPLayer *l, CGRect rect)
{
	CGColorSpaceRef colorSpace;
	CGImageRef cachedImage;
	CGContextRef cachedCxt;
	
	colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	cachedCxt = CGBitmapContextCreate(l->data + l->height*l->pitch -
									  (((int)rect.origin.y+(int)rect.size.height)*l->pitch + (l->pitch - (int)rect.origin.x*4)),
									  (int)rect.size.width,
									  (int)rect.size.height,
									  8,
									  l->pitch,
									  colorSpace,
									  kCGImageAlphaPremultipliedFirst);
	
	if(!cachedCxt) {
		printf("Could not create bitmap context!\n");
		// PROBLEM!
	}
	rect.origin.x = (int)rect.origin.x;
	rect.origin.y = (int)rect.origin.y;
	rect.size.width = (int)rect.size.width;
	rect.size.height = (int)rect.size.height;
	CGColorSpaceRelease(colorSpace);
	
	if((int)rect.size.width == 0 || (int)rect.size.height == 0)
		return;
	
	cachedImage = CGBitmapContextCreateImage(cachedCxt);
	if(!cachedImage) {
		printf("Could not create cached image!\n");
		return;
	}
	
	CGContextDrawImage(baseCxt, rect, cachedImage);
	CFRelease(cachedImage);
	CGContextRelease(cachedCxt);
}

-(void) paintDabAt:(TIPPressurePoint)loc WithBrush:(TIPBrush*)brush ToLayer:(int)l WithColor:(float*)rgba;
{
	[self setNeedsDisplayInRect:[brush renderPointAt:loc OnLayer:&layerList[l] WithColor:rgba]];
}

-(TIPPressurePoint) paintLineFrom:(TIPPressurePoint)start To:(TIPPressurePoint)end WithBrush:(TIPBrush*)brush ToLayer:(int)l WithColor:(float*)rgba;
{
	[self setNeedsDisplayInRect:[brush renderLineFrom:start To:&end OnLayer:&layerList[l] WithColor:rgba]];
	
	return end;
}

- (void)drawRect:(NSRect)rect
{
	//printf("%.01f x %.01f\n", rect.size.width, rect.size.height);
	int i;
	CGRect cRect;
	CGContextRef baseCxt;
	 
	rect.origin.x = (int)rect.origin.x;
	rect.origin.y = (int)rect.origin.y;
	rect.size.width = (int)rect.size.width;
	rect.size.height = (int)rect.size.height;
	
	cRect.origin.x = rect.origin.x;
	cRect.origin.y = rect.origin.y;
	cRect.size.width = rect.size.width;
	cRect.size.height = rect.size.height;
	
	//get current gfx context
	baseCxt = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetShouldAntialias(baseCxt, NO);
	
	CGContextSetRGBFillColor(baseCxt, 1.0f, 1.0f, 1.0f, 1.0f);
	CGContextFillRect(baseCxt, cRect);
	
	for(i=0; i<MAX_LAYERS; i++) {
		draw_layer_rect(baseCxt, &layerList[i], cRect);
	}
}

- (BOOL)isOpaque
{
    // Makes sure that this view is not Transparant!
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    // The view only gets MouseMoved events when the view is the First
    // Responder in the Responder event chain
    return YES;
}

-(void) setForeColor:(NSColor *)newColor
{
	if(mForeColor != nil)
	{
		[mForeColor autorelease];
	}
	mForeColor = [newColor copy];
}

-(void) setCurrentLayer:(int)layer
{
	if(layer >= MAX_LAYERS) {
		cLayer = MAX_LAYERS - 1;
	} else if(layer < 0) {
		cLayer = 0;
	} else  {
		cLayer = layer;
	}
}

-(void) setCurrentBrush:(TIPBrush *)brush
{
	currentBrush = brush;
}

-(TIPBrush *) currentBrush
{
	return currentBrush;
}

-(void) mouseEntered:(NSEvent *)event
{
	printf("mouse in!\n");
}


-(void) saveImageAtURL:(NSURL *)url
{
	int i;
	CGContextRef cxtToSave;
	CGImageRef imageToSave;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	void *data;
	CGImageDestinationRef imageDest;
	CGRect rect = CGRectMake(0.0f, 0.0f, 512.0f, 512.0f);
	
	data = malloc(512*512*4);
	cxtToSave = CGBitmapContextCreate(data, 512, 512, 8, 512*4, colorSpace, kCGImageAlphaNoneSkipLast);
	CGColorSpaceRelease(colorSpace);
	
	CGContextSetRGBFillColor(cxtToSave, 1.0f, 1.0f, 1.0f, 1.0f);
	CGContextFillRect(cxtToSave, rect);
	
	for(i=0; i<MAX_LAYERS; i++) {
		draw_layer_rect(cxtToSave, &layerList[i], rect);
	}
	
	imageToSave = CGBitmapContextCreateImage(cxtToSave);
	imageDest = CGImageDestinationCreateWithURL((CFURLRef)url, kUTTypePNG, 1, nil);
	CGImageDestinationAddImage(imageDest, imageToSave, nil);
	CGImageDestinationFinalize(imageDest);
	
	
	//CFRelease(dest);
	CGContextRelease(cxtToSave);
	CGImageRelease(imageToSave);
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (id)delegate
{
	return delegate;
}

- (void)setDelegate:(id)aDelegate
{
	delegate = aDelegate;
}

@end
