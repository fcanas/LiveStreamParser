//
//  LSPISO8601Parser.h
//  LiveStreamParser
//
//  Created by Fabian Canas on 4/18/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 Implements parsing ISO 8601 dates
 */
@interface LSPISO8601Parser : NSObject

/**
 Initializes a date parser to parse a date from the current position in the
 provided scanner.
 
 LSPISO8601Parser advances the provided scanner through an expected date string
 when it parses a date.

 @param scanner  A scanner expected to have a date at the current position
 @return an initialized date parser
 */
- (instancetype)initWithScanner:(NSScanner *)scanner NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
