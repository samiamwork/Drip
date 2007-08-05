/*
 *  TIPPressurePoint.c
 *  sketchChat
 *
 *  Created by Nur Monson on 4/8/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#include "TIPPressurePoint.h"

TIPPressurePoint TIPMakePressurePoint(float x, float y, float p)
{
	TIPPressurePoint out;
	
	out.point.x = x;
	out.point.y = y;
	out.pressure = p;
	
	return out;
}