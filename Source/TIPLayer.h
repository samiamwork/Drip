#ifndef __TIPLAYER_H__
#define __TIPLAYER_H__

typedef struct TIPLayer_ {
	int width;
	int height;
	int pitch;
	unsigned char *data;
	CGContextRef cxt;
} TIPLayer;

#endif