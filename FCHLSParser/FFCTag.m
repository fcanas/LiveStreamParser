//
//  FFCTag.m
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

@import UIKit;

#import "FFCTag.h"

@implementation FFCBasicTag

@synthesize name = _name;

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    _name = [name copy];
    
    return self;
}

@end

@implementation FFCVersionTag

- (instancetype)init
{
    return [self initWithIntegerAttribute:1];
}

- (instancetype)initWithIntegerAttribute:(NSInteger)version
{
    self = [super init];
    
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
    self = [super init];
    
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

    NSNumber *frameRateNumber = attributes[@"FRAME-RATE"];
    if ([frameRateNumber isKindOfClass:[NSNumber class]]) {
        _frameRate = MAX([frameRateNumber doubleValue], 0);
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

- (NSString *)name
{
    return @"EXT-X-STREAM-INF";
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
    self = [super init];
    
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

- (NSString *)name
{
    return @"EXT-X-I-FRAME-STREAM-INF";
}

@end


@implementation FFCMediaTag

+ (FFCAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"TYPE": @(FFCAttributeTypeEnumeratedString),
                                @"URI": @(FFCAttributeTypeQuotedString),
                                @"GROUP-ID": @(FFCAttributeTypeQuotedString),
                                @"LANGUAGE": @(FFCAttributeTypeQuotedString),
                                @"ASSOC-LANGUAGE": @(FFCAttributeTypeQuotedString),
                                @"NAME": @(FFCAttributeTypeQuotedString),
                                @"DEFAULT": @(FFCAttributeTypeEnumeratedString),
                                @"AUTOSELECT": @(FFCAttributeTypeEnumeratedString),
                                @"FORCED": @(FFCAttributeTypeEnumeratedString),
                                @"INSTREAM-ID": @(FFCAttributeTypeQuotedString),
                                @"CHARACTERISTICS": @(FFCAttributeTypeQuotedString),};
    });
    return [attributeTypeForKey[key] integerValue];
}

- (nullable instancetype)initWithAttributes:(NSDictionary<NSString *, id> *)attributes
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    NSString *type = attributes[@"TYPE"];
    if (![type isKindOfClass:[NSString class]]) {
        return nil;
    }
    if ([type isEqualToString:@"AUDIO"]) {
        _type = FFCMediaTypeAudio;
    } else if ([type isEqualToString:@"VIDEO"]) {
        _type = FFCMediaTypeVideo;
    } else if ([type isEqualToString:@"SUBTITLES"]) {
        _type = FFCMediaTypeSubtitles;
    } else if ([type isEqualToString:@"CLOSED-CAPTIONS"]) {
        _type = FFCMediaTypeClosedCaptions;
    } else {
        _type = FFCMediaTypeUnknown;
    }

    NSString *name = attributes[@"NAME"];
    if ([name isKindOfClass:[NSString class]]) {
        _renditionName = name;
    } else {
        return nil;
    }

    NSString *group = attributes[@"GROUP-ID"];
    if ([group isKindOfClass:[NSString class]]) {
        _groupID = group;
    } else {
        return nil;
    }

    NSString *language = attributes[@"LANGUAGE"];
    if ([language isKindOfClass:[NSString class]]) {
        _language = language;
    }
    
    NSString *assocLanguage = attributes[@"ASSOC-LANGUAGE"];
    if ([assocLanguage isKindOfClass:[NSString class]]) {
        _associatedLanguage = assocLanguage;
    }
    
    NSString *uriString = attributes[@"URI"];
    if ([uriString isKindOfClass:[NSString class]]) {
        NSURL *uri = [NSURL URLWithString:uriString];
        _uri = uri;
    }
    
    NSString *defaultString = attributes[@"DEFAULT"];
    if ([defaultString isKindOfClass:[NSString class]] && [defaultString isEqualToString:@"YES"]) {
        _defaultRendition = YES;
    }

    NSString *autoselectString = attributes[@"AUTOSELECT"];
    if ([autoselectString isKindOfClass:[NSString class]] && [autoselectString isEqualToString:@"YES"]) {
        _autoselect = YES;
    }

    NSString *forcedString = attributes[@"FORCED"];
    if ([forcedString isKindOfClass:[NSString class]] && [forcedString isEqualToString:@"YES"]) {
        _forced = YES;
    }
    
    NSString *instreamID = attributes[@"INSTREAM-ID"];
    if ([instreamID isKindOfClass:[NSString class]]) {
        _instreamID = instreamID;
    }
    
    NSString *characteristicsString = attributes[@"CHARACTERISTICS"];
    if ([characteristicsString isKindOfClass:[NSString class]]) {
        _characteristics = [characteristicsString componentsSeparatedByString:@","];
    } else {
        _characteristics = @[];
    }

    return self;
}

- (NSString *)name
{
    return @"EXT-X-MEDIA";
}

@end


@implementation FFCSessionDataTag

+ (FFCAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"DATA-ID": @(FFCAttributeTypeQuotedString),
                                @"VALUE": @(FFCAttributeTypeQuotedString),
                                @"GROUP-ID": @(FFCAttributeTypeQuotedString),
                                @"LANGUAGE": @(FFCAttributeTypeQuotedString),
                                };
    });
    return [attributeTypeForKey[key] integerValue];
}

- (nullable instancetype)initWithAttributes:(NSDictionary<NSString *, id> *)attributes
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    NSString *dataID = attributes[@"DATA-ID"];
    if ([dataID isKindOfClass:[NSString class]]) {
        _dataID = dataID;
    } else {
        return nil;
    }
    
    NSString *valueString = attributes[@"VALUE"];
    if ([valueString isKindOfClass:[NSString class]]) {
        _value = valueString;
    }
    
    NSString *uriString = attributes[@"URI"];
    if ([uriString isKindOfClass:[NSString class]]) {
        NSURL *uri = [NSURL URLWithString:uriString];
        _uri = uri;
    }
    
    if (_uri == nil && _value == nil) {
        return nil;
    }
    
    NSString *language = attributes[@"LANGUAGE"];
    if ([language isKindOfClass:[NSString class]]) {
        _language = language;
    }
    
    return self;
}

- (NSString *)name
{
    return @"EXT-X-SESSION-DATA";
}

@end

@implementation FFCSessionKeyTag

+ (FFCAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"METHOD": @(FFCAttributeTypeEnumeratedString),
                                @"URI": @(FFCAttributeTypeQuotedString),
                                @"IV": @(FFCAttributeTypeHexidecimalSequence),
                                @"KEYFORMAT": @(FFCAttributeTypeQuotedString),
                                @"KEYFORMATVERSIONS": @(FFCAttributeTypeQuotedString),
                                };
    });
    return [attributeTypeForKey[key] integerValue];
}

- (nullable instancetype)initWithAttributes:(NSDictionary<NSString *, id> *)attributes
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    NSString *method = attributes[@"METHOD"];
    if ([method isKindOfClass:[NSString class]]) {
        if ([method isEqualToString:@"NONE"]) {
            _method = FFCEncryptionMethodNone;
        } else if ([method isEqualToString:@"AES-128"]) {
            _method = FFCEncryptionMethodAES128;
        } else if ([method isEqualToString:@"SAMPLE-AES"]) {
            _method = FFCEncryptionMethodSampleAES;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
    
    NSString *uriString = attributes[@"URI"];
    if ([uriString isKindOfClass:[NSString class]]) {
        _uri = [NSURL URLWithString:uriString];
    }
    
    if (_method != FFCEncryptionMethodNone && _uri == nil) {
        return nil;
    }

    NSString *keyFormatString = attributes[@"KEYFORMAT"];
    if ([keyFormatString isKindOfClass:[NSString class]]) {
        _keyFormat = keyFormatString;
    } else {
        _keyFormat = @"identity";
    }
    
    NSString *keyFormatVersionsString = attributes[@"KEYFORMATVERSIONS"];
    if ([keyFormatVersionsString isKindOfClass:[NSString class]]) {
        NSArray *components = [keyFormatVersionsString componentsSeparatedByString:@"/"];
        NSMutableArray *versions = [[NSMutableArray alloc] initWithCapacity:components.count];
        for (NSString *componentString in components) {
            [versions addObject:@([componentString integerValue])];
        }
        _keyFormatVersions = [versions copy];
    } else {
        _keyFormatVersions = @[];
    }
    
    NSString *ivString = attributes[@"IV"];
    if ([ivString isKindOfClass:[NSString class]]) {
        _initializationVector = ivString;
    }
    
    return self;
}

- (NSString *)name
{
    return @"EXT-X-SESSION-KEY";
}

@end

@implementation FFCStartTag

+ (FFCAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"TIME-OFFSET": @(FFCAttributeTypeSignedDecimalFloatingPoint),
                                @"PRECISE": @(FFCAttributeTypeEnumeratedString),
                                };
    });
    return [attributeTypeForKey[key] integerValue];
}

- (instancetype)initWithAttributes:(NSDictionary<NSString *, id> *)attributes
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    NSNumber *timeOffsetNumer = attributes[@"TIME-OFFSET"];
    if (![timeOffsetNumer isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    _timeOffset = [timeOffsetNumer doubleValue];
    
    NSString *preciseString = attributes[@"PRECISE"];
    if ([preciseString isKindOfClass:[NSString class]] && [preciseString isEqualToString:@"YES"]) {
        _precise = YES;
    }
    
    return attributes[@"TIME-OFFSET"] ? [super init] : nil;
}

- (NSString *)name
{
    return @"EXT-X-START";
}

@end

