#ifndef __TIPPRESSUREPOINT_H__
#define __TIPPRESSUREPOINT_H__

typedef struct TIPPoint_ {
    float x;
    float y;
} TIPPoint;

typedef struct TIPPressurePoint_ {
	TIPPoint point;
	float pressure;
} TIPPressurePoint;

TIPPressurePoint TIPMakePressurePoint(float x, float y, float p);

#endif