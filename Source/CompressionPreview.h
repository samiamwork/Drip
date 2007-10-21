//
//  CompressionPreview.h
//  Drip
//
//  Created by Nur Monson on 10/16/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CompressionPreview : NSImageView {
	NSPoint _imageOffset;
	NSPoint _lastMousePosition;
	BOOL _isDragging;
}

@end
