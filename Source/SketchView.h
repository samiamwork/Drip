/* SketchView */

#import <Cocoa/Cocoa.h>
#import "TIPBrush.h"
#import "TIPBrushPaint.h"
#import "TIPLayer.h"
#import "TIPPressurePoint.h"

#define MAXBRUSHSIZE	50.0f

#define MAX_LAYERS		3

@interface SketchView : NSView
{
	TIPPressurePoint lastLocation;
	TIPPressurePoint currentLocation;

	TIPBrush *defaultBrush;
	TIPBrush *currentBrush;

	NSColor* mForeColor;

	int canvasWidth;
	int canvasHeight;
	TIPLayer layerList[MAX_LAYERS];
	int cLayer;
		
	id delegate;
}

-(void) setForeColor:(NSColor *)newColor;
-(void) setCurrentLayer:(int)layer;
-(void) setCurrentBrush:(TIPBrush *)brush;
-(TIPBrush *) currentBrush;

-(void)createNewLayer:(int)width:(int)height:(TIPLayer *)l;

-(void) handleMouseEvent:(NSEvent *)theEvent;
-(void) drawCurrentDataFromEvent:(NSEvent *)theEvent;

-(void) paintDabAt:(TIPPressurePoint)loc WithBrush:(TIPBrush*)brush ToLayer:(int)l WithColor:(float*)rgba;
-(TIPPressurePoint) paintLineFrom:(TIPPressurePoint)start To:(TIPPressurePoint)end WithBrush:(TIPBrush*)brush ToLayer:(int)l WithColor:(float*)rgba;

-(void) saveImageAtURL:(NSURL *)url;

- (void)setDelegate:(id)aDelegate;
- (id) delegate;
@end
