/*
 *  TIPCGUtils.h
 *  TriviaPlayer
 *
 *  Created by Nur Monson on 10/6/06.
 *  Copyright 2006 theidiotproject. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>
#include <ApplicationServices/ApplicationServices.h>

void             TIPDumpCGImageToPNG(CGImageRef theImage, const char* path);
CGMutablePathRef TIPCGUtilsRoundedBoxCreate( CGRect inRect, float margin, float radius, float lineWidth );
CGMutablePathRef TIPCGUtilsPartialRoundedBoxCreate( CGRect inRect, float radius, bool lowerRight, bool upperRight, bool upperLeft, bool lowerLeft );
CGMutablePathRef TIPCGUtilsPill( CGRect inRect );
