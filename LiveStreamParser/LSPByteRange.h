//
//  LSPByteRange.h
//  LiveStreamParser
//
//  Created by Fabian Canas on 4/10/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import <LiveStreamParser/LSPSerializable.h>

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 Represents a Byte Range as needed by HLS
 */
@interface LSPByteRange : NSObject <LSPSerializable>

- (nullable instancetype)initWithString:(NSString *)string;

- (instancetype)initWithLength:(NSUInteger)length offset:(NSUInteger)offset;

/// The length of the range in bytes
@property (nonatomic) NSUInteger length;

/**
 The start of the subrange as an NSUInteger byte-offset
 */
@property (nonatomic, nullable, copy) NSNumber *offset;

@end

NS_ASSUME_NONNULL_END
