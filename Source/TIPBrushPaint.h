//
//  TIPBrushPaint.h
//  sketchChat
//
//  Created by Nur Monson on 4/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TIPBrush.h"
#import "PaintLayer.h"

@interface TIPBrushPaint : TIPBrush {

}

- (NSRect)renderPointAt:(NSPoint)aPoint withPressure:(float)aPressure onLayer:(PaintLayer *)aLayer;
@end
