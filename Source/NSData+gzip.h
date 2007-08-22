//
//  NSData+gzip.h
//  Drip
//
//  Created by Nur Monson on 8/21/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSData (gzip)
- (NSData *)gzipDeflate;
- (NSData *)gzipInflate;
@end
