//
//  FFCTag.m
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

@import UIKit;

#import "FFCTag.h"

@implementation FFCTag

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    _name = [name copy];
    
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    FFCTag *other = object;
    
    BOOL equalNames = (!self.name && !other.name) || [self.name isEqualToString:other.name];

    return equalNames;
}

@end

@implementation FFCVersionTag

- (instancetype)init
{
    return [self initWithIntegerAttribute:1];
}

- (instancetype)initWithIntegerAttribute:(NSInteger)version
{
    self = [super initWithName:@"EXT-X-VERSION"];
    
    if (self == nil) {
        return nil;
    }
    
    if (version == 0) {
        version = 1;
    }

    _version = version;
    
    return self;
}

- (NSString *)name
{
    return @"EXT-X-VERSION";
}

@end

@implementation FFCStreamInfoTag

+ (FFCAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"BANDWIDTH": @(FFCAttributeTypeDecimalInteger),
                                @"AVERAGE-BANDWIDTH": @(FFCAttributeTypeDecimalInteger),
                                @"CODECS": @(FFCAttributeTypeQuotedString),
                                @"RESOLUTION": @(FFCAttributeTypeDecimalResolution),
                                @"FRAME-RATE": @(FFCAttributeTypeDecimalFloatingPoint),
                                @"AUDIO": @(FFCAttributeTypeQuotedString),
                                @"VIDEO": @(FFCAttributeTypeQuotedString),
                                @"SUBTITLES": @(FFCAttributeTypeQuotedString),
                                @"CLOSED-CAPTIONS": @(FFCAttributeTypeQuotedString)};
    });
    return [attributeTypeForKey[key] integerValue];
}

- (nullable instancetype)initWithAttributes:(NSDictionary<NSString *, id> *)attributes
{
    self = [super initWithName:@"EXT-X-STREAM-INF"];
    
    if (self == nil) {
        return nil;
    }
    
    NSNumber *bandwidth = attributes[@"BANDWIDTH"];
    if (bandwidth == nil || ![bandwidth isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    _bandwidth = [bandwidth unsignedIntegerValue];

    NSNumber *averageBandwidth = attributes[@"AVERAGE-BANDWIDTH"];
    if ([averageBandwidth isKindOfClass:[NSNumber class]]) {
        _averageBandwidth = [averageBandwidth unsignedIntegerValue];
    }
    
    NSString *codecsString = attributes[@"CODECS"];
    if ([codecsString isKindOfClass:[NSString class]]) {
        _codecs = [codecsString componentsSeparatedByString:@","];
    } else {
        _codecs = @[];
    }
    
    NSValue *resolutionValue = attributes[@"RESOLUTION"];
    if ([resolutionValue isKindOfClass:[NSValue class]]) {
        _resolution = [resolutionValue CGSizeValue];
    } else {
        _resolution = CGSizeZero;
    }

    NSNumber *frameRate = attributes[@"FRAME-RATE"];
    if ([frameRate isKindOfClass:[NSNumber class]]) {
        _frameRate = [frameRate doubleValue];
    }
    
    NSString *audio = attributes[@"AUDIO"];
    if ([audio isKindOfClass:[NSString class]]) {
        _audio = audio;
    }
    
    NSString *video = attributes[@"VIDEO"];
    if ([video isKindOfClass:[NSString class]]) {
        _video = video;
    }
    
    NSString *subtitles = attributes[@"SUBTITLES"];
    if ([subtitles isKindOfClass:[NSString class]]) {
        _subtitles = subtitles;
    }
    
    NSString *closedCaptions = attributes[@"CLOSED-CAPTIONS"];
    if ([closedCaptions isKindOfClass:[NSString class]]) {
        _closedCaptions = closedCaptions;
    }
    
    return self;
}

@end

@implementation FFCIFrameStreamInfoTag

+ (FFCAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"BANDWIDTH": @(FFCAttributeTypeDecimalInteger),
                                @"AVERAGE-BANDWIDTH": @(FFCAttributeTypeDecimalInteger),
                                @"CODECS": @(FFCAttributeTypeQuotedString),
                                @"RESOLUTION": @(FFCAttributeTypeDecimalResolution),
                                @"FRAME-RATE": @(FFCAttributeTypeDecimalFloatingPoint),
                                @"URI": @(FFCAttributeTypeQuotedString)};
    });
    return [attributeTypeForKey[key] integerValue];
}

- (nullable instancetype)initWithAttributes:(NSDictionary<NSString *, id> *)attributes
{
    self = [super initWithName:@"EXT-X-STREAM-INF"];
    
    if (self == nil) {
        return nil;
    }
    
    NSNumber *bandwidth = attributes[@"BANDWIDTH"];
    if (bandwidth == nil || ![bandwidth isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    _bandwidth = [bandwidth unsignedIntegerValue];
    
    NSNumber *averageBandwidth = attributes[@"AVERAGE-BANDWIDTH"];
    if ([averageBandwidth isKindOfClass:[NSNumber class]]) {
        _averageBandwidth = [averageBandwidth unsignedIntegerValue];
    }
    
    NSString *codecsString = attributes[@"CODECS"];
    if ([codecsString isKindOfClass:[NSString class]]) {
        _codecs = [codecsString componentsSeparatedByString:@","];
    } else {
        _codecs = @[];
    }
    
    NSValue *resolutionValue = attributes[@"RESOLUTION"];
    if ([resolutionValue isKindOfClass:[NSValue class]]) {
        _resolution = [resolutionValue CGSizeValue];
    } else {
        _resolution = CGSizeZero;
    }
    
    NSNumber *frameRate = attributes[@"FRAME-RATE"];
    if ([frameRate isKindOfClass:[NSNumber class]]) {
        _frameRate = [frameRate doubleValue];
    }
    
    return self;
}

@end


