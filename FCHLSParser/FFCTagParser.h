//
//  FFCTagParser.h
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

@import Foundation;

@protocol FFCTag;

NS_ASSUME_NONNULL_BEGIN

@interface FFCTagParser : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithString:(NSString *)string NS_DESIGNATED_INITIALIZER;

- (nullable id <FFCTag>)nextTag;

- (NSArray<id<FFCTag>> *)parse;

@end

NS_ASSUME_NONNULL_END
