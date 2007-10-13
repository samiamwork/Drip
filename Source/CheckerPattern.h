/*
 *  CheckerPattern.h
 *  Drip
 *
 *  Created by Nur Monson on 10/12/07.
 *  Copyright 2007 theidiotproject. All rights reserved.
 *
 */

#include <Carbon/Carbon.h>

#define PATTERN_SIZE 20.0f

void drawCheckerPatternInContextWithPhase( CGContextRef cxt, CGSize phase, CGRect aRect );