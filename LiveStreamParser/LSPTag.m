//
//  LSPTag.m
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

@import UIKit;

#import "LSPTag.h"

extern NSString * _Nullable LSPPlaylistTypeString(LSPPlaylistType type)
{
    switch (type) {
        case LSPPlaylistTypeVOD:
            return @"VOD";
        case LSPPlaylistTypeEvent:
            return @"EVENT";
        default:
            return nil;
    }
}

/**
 A function that builds a string attribute list for the provided attributed tag
 instance. This function is nearly equivalent to a common `serialize` method for
 attributed tags.

 @param tag the tag
 @return An HLS attribute list for the provided attibuted tag.
 */
static NSString * _Nonnull LSPAttributeListForTag(id<LSPAttributedTag> tag)
{
    NSString *attributeList = nil;
    for (NSString *key in [[tag class] attributeKeys]) {
        NSString *stringValue = [tag valueStringForAttributeKey:key];
        if (stringValue == nil) {
            continue;
        }
        if (attributeList == nil) {
            attributeList = [NSString stringWithFormat:@"%@=%@", key, stringValue];
        } else {
            attributeList = [attributeList stringByAppendingFormat:@",%@=%@", key, stringValue];
        }
    }

    return attributeList ?: @"";
}

/**
 An effective default implemetaion for `-serialize` for an `LSPAttributedTag`.

 @param tag The tag to serialize
 @return The serialized string representation of the tag
 */
static NSString * _Nonnull LSPSerializeAttributedTag(id<LSPAttributedTag> tag)
{
    return [NSString stringWithFormat:@"#%@:%@", [tag name], LSPAttributeListForTag(tag)];
}

/**
 Returns a string with quotes around the string argument, or nil if the argument
 is nil.

 @param string A optional string
 @return nil or the provided string wrapped in " characters
 */
static NSString * _Nullable LSPQuotedString(NSString * _Nullable string)
{
    return string ? [NSString stringWithFormat:@"\"%@\"", string] : nil;
}

static inline BOOL LSPEqualObjects(id<NSObject>obj1, id<NSObject>obj2)
{
    return obj1 == obj2 || [obj1 isEqual:obj2];
}

@implementation LSPBasicTag

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

- (NSString *)serialize
{
    return [NSString stringWithFormat:@"#%@", self.name];
}

- (NSUInteger)hash
{
    return [_name hash];
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    return [self.name isEqual:other.name];
}


@end

@implementation LSPURITag

- (nullable instancetype)initWithURIString:(NSString *)URIString
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    _uri = [NSURL URLWithString:URIString];
    if (_uri == nil) {
        return nil;
    }

    return self;
}

- (NSString *)name
{
    return @"uri-tag";
}

- (NSString *)serialize
{
    return [self.uri absoluteString];
}

- (NSUInteger)hash
{
    return [self.uri hash];
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }

    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;

    return [self.uri isEqual:other.uri];
}

@end


@implementation LSPVersionTag

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

- (NSString *)serialize
{
    return [NSString stringWithFormat:@"#%@:%@", [self name], @(self.version)];
}

- (NSUInteger)hash
{
    return (NSUInteger)(self.version ^ 0xf000);
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    return self.version == other.version;
}

@end

@implementation LSPStreamInfoTag

+ (LSPAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"BANDWIDTH": @(LSPAttributeTypeDecimalInteger),
                                @"AVERAGE-BANDWIDTH": @(LSPAttributeTypeDecimalInteger),
                                @"CODECS": @(LSPAttributeTypeQuotedString),
                                @"RESOLUTION": @(LSPAttributeTypeDecimalResolution),
                                @"FRAME-RATE": @(LSPAttributeTypeDecimalFloatingPoint),
                                @"AUDIO": @(LSPAttributeTypeQuotedString),
                                @"VIDEO": @(LSPAttributeTypeQuotedString),
                                @"SUBTITLES": @(LSPAttributeTypeQuotedString),
                                @"CLOSED-CAPTIONS": @(LSPAttributeTypeQuotedString)};
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

+ (nonnull NSArray<NSString *> *)attributeKeys
{
    return @[@"BANDWIDTH", @"AVERAGE-BANDWIDTH", @"CODECS", @"RESOLUTION", @"FRAME-RATE", @"AUDIO", @"VIDEO", @"SUBTITLES", @"CLOSED-CAPTIONS"];
}

- (nullable NSString *)valueStringForAttributeKey:(nonnull NSString *)key
{
    if ([key isEqualToString:@"BANDWIDTH"]) {
        return [NSString stringWithFormat:@"%@", @(self.bandwidth)];
    }
    
    if ([key isEqualToString:@"AVERAGE-BANDWIDTH"]) {
        return [NSString stringWithFormat:@"%@", @(self.averageBandwidth)];
    }

    if ([key isEqualToString:@"CODECS"]) {
        return LSPQuotedString([self.codecs componentsJoinedByString:@","]);
    }
    
    if ([key isEqualToString:@"RESOLUTION"]) {
        return [NSString stringWithFormat:@"%@x%@", @(self.resolution.width), @(self.resolution.height)];
    }
    
    if ([key isEqualToString:@"FRAME-RATE"]) {
        return [NSString stringWithFormat:@"%@", @(self.frameRate)];
    }
    
    if ([key isEqualToString:@"AUDIO"]) {
        return LSPQuotedString(self.audio);
    }
    
    if ([key isEqualToString:@"VIDEO"]) {
        return LSPQuotedString(self.video);
    }
    
    if ([key isEqualToString:@"SUBTITLES"]) {
        return LSPQuotedString(self.subtitles);
    }
    
    if ([key isEqualToString:@"CLOSED-CAPTIONS"]) {
        return LSPQuotedString(self.closedCaptions);
    }
    
    return nil;
}

- (NSString *)name
{
    return @"EXT-X-STREAM-INF";
}

- (nonnull NSString *)serialize
{
    return LSPSerializeAttributedTag(self);
}

- (NSUInteger)hash
{
    return _bandwidth ^ _averageBandwidth ^ [_codecs hash] ^ (NSUInteger)_resolution.width ^ (NSUInteger)_resolution.height ^ (NSUInteger)_frameRate ^ [_audio hash] ^ [_video hash] ^ [_subtitles hash] ^ [_closedCaptions hash];
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    if (!LSPEqualObjects(self.name, other.name)) {
        return NO;
    }
    
    if (self.bandwidth != other.bandwidth) {
        return NO;
    }
    
    if (self.averageBandwidth != other.averageBandwidth) {
        return NO;
    }

    if (!LSPEqualObjects(self.codecs, other.codecs)) {
        return NO;
    }
    
    if (!CGSizeEqualToSize(self.resolution, other.resolution)) {
        return NO;
    }
    
    if (self.frameRate != other.frameRate) {
        return NO;
    }
    
    if (!LSPEqualObjects(self.audio, other.audio)) {
        return NO;
    }

    if (!LSPEqualObjects(self.video, other.video)) {
        return NO;
    }
    
    if (!LSPEqualObjects(self.subtitles, other.subtitles)) {
        return NO;
    }
    
    if (!LSPEqualObjects(self.closedCaptions, other.closedCaptions)) {
        return NO;
    }
    
    return YES;
}

@end

@implementation LSPIFrameStreamInfoTag

+ (LSPAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"BANDWIDTH": @(LSPAttributeTypeDecimalInteger),
                                @"AVERAGE-BANDWIDTH": @(LSPAttributeTypeDecimalInteger),
                                @"CODECS": @(LSPAttributeTypeQuotedString),
                                @"RESOLUTION": @(LSPAttributeTypeDecimalResolution),
                                @"URI": @(LSPAttributeTypeQuotedString)};
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
    
    NSString *uriString = attributes[@"URI"];
    if ([uriString isKindOfClass:[NSString class]]) {
        NSURL *uri = [NSURL URLWithString:uriString];
        _uri = uri;
    }
    
    return self;
}

+ (nonnull NSArray<NSString *> *)attributeKeys
{
    return @[@"BANDWIDTH", @"AVERAGE-BANDWIDTH", @"CODECS", @"RESOLUTION", @"URI"];
}

- (nullable NSString *)valueStringForAttributeKey:(nonnull NSString *)key
{
    if ([key isEqualToString:@"BANDWIDTH"]) {
        return [NSString stringWithFormat:@"%@", @(self.bandwidth)];
    }
    
    if ([key isEqualToString:@"AVERAGE-BANDWIDTH"]) {
        return [NSString stringWithFormat:@"%@", @(self.averageBandwidth)];
    }
    
    if ([key isEqualToString:@"CODECS"]) {
        return LSPQuotedString([self.codecs componentsJoinedByString:@","]);
    }
    
    if ([key isEqualToString:@"RESOLUTION"]) {
        return [NSString stringWithFormat:@"%@x%@", @(self.resolution.width), @(self.resolution.height)];
    }
    
    if ([key isEqualToString:@"URI"]) {
        return LSPQuotedString([self.uri absoluteString]);
    }
    
    return nil;
}

- (NSString *)name
{
    return @"EXT-X-I-FRAME-STREAM-INF";
}

- (nonnull NSString *)serialize
{
    return LSPSerializeAttributedTag(self);
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    if (!LSPEqualObjects(self.name, other.name)) {
        return NO;
    }
    
    if (self.bandwidth != other.bandwidth) {
        return NO;
    }
    
    if (self.averageBandwidth != other.averageBandwidth) {
        return NO;
    }
    
    if (!LSPEqualObjects(self.codecs, other.codecs)) {
        return NO;
    }
    
    if (!CGSizeEqualToSize(self.resolution, other.resolution)) {
        return NO;
    }
    
    if (!LSPEqualObjects(self.uri, other.uri)) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return [self.name hash] ^ _bandwidth ^ _averageBandwidth ^ [_codecs hash] ^ (NSUInteger)_resolution.width ^ (NSUInteger)_resolution.height ^ [_uri hash];
}

@end


@implementation LSPMediaTag

+ (LSPAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"TYPE": @(LSPAttributeTypeEnumeratedString),
                                @"URI": @(LSPAttributeTypeQuotedString),
                                @"GROUP-ID": @(LSPAttributeTypeQuotedString),
                                @"LANGUAGE": @(LSPAttributeTypeQuotedString),
                                @"ASSOC-LANGUAGE": @(LSPAttributeTypeQuotedString),
                                @"NAME": @(LSPAttributeTypeQuotedString),
                                @"DEFAULT": @(LSPAttributeTypeEnumeratedString),
                                @"AUTOSELECT": @(LSPAttributeTypeEnumeratedString),
                                @"FORCED": @(LSPAttributeTypeEnumeratedString),
                                @"INSTREAM-ID": @(LSPAttributeTypeQuotedString),
                                @"CHARACTERISTICS": @(LSPAttributeTypeQuotedString),};
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
        _type = LSPMediaTypeAudio;
    } else if ([type isEqualToString:@"VIDEO"]) {
        _type = LSPMediaTypeVideo;
    } else if ([type isEqualToString:@"SUBTITLES"]) {
        _type = LSPMediaTypeSubtitles;
    } else if ([type isEqualToString:@"CLOSED-CAPTIONS"]) {
        _type = LSPMediaTypeClosedCaptions;
    } else {
        _type = LSPMediaTypeUnknown;
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

+ (nonnull NSArray<NSString *> *)attributeKeys
{
    return @[@"TYPE", @"GROUP-ID", @"LANGUAGE", @"NAME", @"ASSOC-LANGUAGE", @"DEFAULT", @"AUTOSELECT", @"FORCED", @"URI", @"INSTREAM-ID", @"CHARACTERISTICS"];
}

- (nullable NSString *)valueStringForAttributeKey:(nonnull NSString *)key
{
    if ([key isEqualToString:@"TYPE"]) {
        switch (self.type) {
            case LSPMediaTypeAudio:
                return @"AUDIO";
            case LSPMediaTypeVideo:
                return @"VIDEO";
            case LSPMediaTypeSubtitles:
                return @"SUBTITLES";
            case LSPMediaTypeClosedCaptions:
                return @"CLOSED-CAPTIONS";
            case LSPMediaTypeUnknown:
                return nil;
        }
        return nil;
    }

    if ([key isEqualToString:@"NAME"]) {
        return LSPQuotedString(self.renditionName);
    }
    
    if ([key isEqualToString:@"GROUP-ID"]) {
        return LSPQuotedString(self.groupID);
    }
    
    if ([key isEqualToString:@"LANGUAGE"]) {
        return LSPQuotedString(self.language);
    }
    
    if ([key isEqualToString:@"ASSOC-LANGUAGE"]) {
        return LSPQuotedString(self.associatedLanguage);
    }

    if ([key isEqualToString:@"URI"]) {
        return LSPQuotedString([self.uri absoluteString]);
    }
    
    if ([key isEqualToString:@"DEFAULT"]) {
        return self.defaultRendition ? @"YES" : nil;
    }
    
    if ([key isEqualToString:@"AUTOSELECT"]) {
        return self.autoselect ? @"YES" : nil;
    }

    if ([key isEqualToString:@"FORCED"]) {
        return self.forced ? @"YES" : nil;
    }

    if ([key isEqualToString:@"INSTREAM-ID"]) {
        return LSPQuotedString(self.instreamID);
    }
    
    if ([key isEqualToString:@"CHARACTERISTICS"]) {
        return self.characteristics.count ? LSPQuotedString([self.characteristics componentsJoinedByString:@","]) : nil;
    }
    
    return nil;
}

- (NSString *)name
{
    return @"EXT-X-MEDIA";
}

- (nonnull NSString *)serialize
{
    return LSPSerializeAttributedTag(self);
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    if (!LSPEqualObjects(self.uri, other.uri)) {
        return NO;
    }

    if (!LSPEqualObjects(self.groupID, other.groupID)) {
        return NO;
    }
    
    if (!LSPEqualObjects(self.language, other.language)) {
        return NO;
    }
    
    if (!LSPEqualObjects(self.associatedLanguage, other.associatedLanguage)) {
        return NO;
    }
    
    if (!LSPEqualObjects(self.renditionName, other.renditionName)) {
        return NO;
    }
    
    if (self.defaultRendition != other.defaultRendition) {
        return NO;
    }
    
    if (self.autoselect != other.autoselect) {
        return NO;
    }
    
    if (self.forced != other.forced) {
        return NO;
    }
    
    if (!LSPEqualObjects(self.instreamID, other.instreamID)) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger booleanHash = (NSUInteger)_forced ^ ((NSUInteger)_autoselect << 1) ^ ((NSUInteger)_defaultRendition << 2);
    return booleanHash ^ [_instreamID hash] ^ [_renditionName hash] ^ [_associatedLanguage hash] ^ [_language hash] ^ [_groupID hash] ^ [_uri hash];
}

@end


@implementation LSPSessionDataTag

+ (LSPAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"DATA-ID": @(LSPAttributeTypeQuotedString),
                                @"VALUE": @(LSPAttributeTypeQuotedString),
                                @"GROUP-ID": @(LSPAttributeTypeQuotedString),
                                @"LANGUAGE": @(LSPAttributeTypeQuotedString),
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

+ (nonnull NSArray<NSString *> *)attributeKeys
{
    return @[@"DATA-ID", @"VALUE", @"LANGUAGE", @"URI"];
}

- (nullable NSString *)valueStringForAttributeKey:(nonnull NSString *)key
{
    if ([key isEqualToString:@"DATA-ID"]) {
        return LSPQuotedString(self.dataID);
    }
    
    if ([key isEqualToString:@"VALUE"]) {
        return LSPQuotedString(self.value);
    }
    
    if ([key isEqualToString:@"URI"]) {
        return LSPQuotedString([self.uri absoluteString]);
    }

    if ([key isEqualToString:@"LANGUAGE"]) {
        return LSPQuotedString(self.language);
    }

    return nil;
}

- (NSString *)name
{
    return @"EXT-X-SESSION-DATA";
}

- (nonnull NSString *)serialize
{
    return LSPSerializeAttributedTag(self);
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    return [[self serialize] isEqual:[other serialize]];
}

- (NSUInteger)hash
{
    return [_dataID hash] ^ [_value hash] ^ [_language hash] ^ [_uri hash];
}

@end

@implementation LSPSessionKeyTag

- (NSString *)name
{
    return @"EXT-X-SESSION-KEY";
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    return [[self serialize] isEqual:[other serialize]];
}

@end

@implementation LSPStartTag

+ (LSPAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"TIME-OFFSET": @(LSPAttributeTypeSignedDecimalFloatingPoint),
                                @"PRECISE": @(LSPAttributeTypeEnumeratedString),
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

+ (nonnull NSArray<NSString *> *)attributeKeys
{
    return @[@"TIME-OFFSET", @"PRECISE"];
}


- (nullable NSString *)valueStringForAttributeKey:(nonnull NSString *)key
{
    if ([key isEqualToString:@"TIME-OFFSET"]) {
        return [NSString stringWithFormat:@"%@", @(self.timeOffset)];
    }
    
    if ([key isEqualToString:@"PRECISE"]) {
        return self.precise ? @"YES" : nil;
    }

    return nil;
}

- (NSString *)name
{
    return @"EXT-X-START";
}

- (nonnull NSString *)serialize
{
    return LSPSerializeAttributedTag(self);
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    return [[self serialize] isEqual:[other serialize]];
}

- (NSUInteger)hash
{
    return (NSUInteger)_timeOffset ^ _precise;
}

@end

#pragma mark - Media Segment Tags

@implementation LSPInfoTag

- (instancetype)initWithDuration:(NSTimeInterval)duration title:(nullable NSString *)title
{
    self = [super init];
    
    if (self != nil) {
        _duration = duration;
        _title = [title copy];
    }

    return self;
}

- (NSString *)name
{
    return @"EXTINF";
}

- (nonnull NSString *)serialize {
    return [NSString stringWithFormat:@"#%@:%@,%@", self.name, @(_duration), self.title ?: @""];
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    if (!LSPEqualObjects(self.title, other.title)) {
        return NO;
    }
    
    if (self.duration != other.duration) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    return [self.name hash] ^ (NSUInteger)_duration ^ [_title hash];
}

@end

@implementation LSPKeyTag

+ (LSPAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"METHOD": @(LSPAttributeTypeEnumeratedString),
                                @"URI": @(LSPAttributeTypeQuotedString),
                                @"IV": @(LSPAttributeTypeHexidecimalSequence),
                                @"KEYFORMAT": @(LSPAttributeTypeQuotedString),
                                @"KEYFORMATVERSIONS": @(LSPAttributeTypeQuotedString),
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
            _method = LSPEncryptionMethodNone;
        } else if ([method isEqualToString:@"AES-128"]) {
            _method = LSPEncryptionMethodAES128;
        } else if ([method isEqualToString:@"SAMPLE-AES"]) {
            _method = LSPEncryptionMethodSampleAES;
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
    
    if (_method != LSPEncryptionMethodNone && _uri == nil) {
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

+ (nonnull NSArray<NSString *> *)attributeKeys
{
    return @[@"METHOD", @"URI", @"KEYFORMAT", @"KEYFORMATVERSIONS", @"IV"];
}

- (nullable NSString *)valueStringForAttributeKey:(nonnull NSString *)key
{
    if ([key isEqualToString:@"METHOD"]) {
        switch (self.method) {
            case LSPEncryptionMethodNone:
                return @"NONE";
                break;
            case LSPEncryptionMethodAES128:
                return @"AES-128";
                break;
            case LSPEncryptionMethodSampleAES:
                return @"SAMPLE-AES";
                break;
            default:
                return nil;
                break;
        }
    }
    
    if ([key isEqualToString:@"URI"]) {
        return LSPQuotedString([self.uri absoluteString]);
    }
    
    if ([key isEqualToString:@"KEYFORMAT"]) {
        return LSPQuotedString(self.keyFormat);
    }
    
    if ([key isEqualToString:@"KEYFORMATVERSIONS"]) {
        return LSPQuotedString([self.keyFormatVersions componentsJoinedByString:@"/"]);
    }
    
    if ([key isEqualToString:@"IV"]) {
        return self.initializationVector;
    }
    
    return nil;
}

- (NSString *)name
{
    return @"EXT-X-KEY";
}

- (nonnull NSString *)serialize
{
    return LSPSerializeAttributedTag(self);
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    return [[self serialize] isEqual:[other serialize]];
}

- (NSUInteger)hash
{
    return (NSUInteger)_method ^ [_uri hash] ^ [_keyFormat hash] ^ [_keyFormatVersions hash] ^ [_initializationVector hash];
}

@end


@implementation LSPMapTag

- (instancetype)initWithAttributes:(NSDictionary<NSString *,id> *)attributes
{
    self = [super init];
    
    if (self) {
        
        NSString *uriString = attributes[@"URI"];
        if ([uriString isKindOfClass:[NSString class]]) {
            NSURL *uri = [NSURL URLWithString:uriString];
            _uri = uri;
        } else {
            return nil;
        }
        
        NSString *byteRangeString = attributes[@"BYTERANGE"];
        if ([byteRangeString isKindOfClass:[NSString class]]) {
            LSPByteRange *byteRange = [[LSPByteRange alloc] initWithString:byteRangeString];
            if (byteRangeString != nil) {
                _byteRange = byteRange;
            }
        }
    }

    return self;
}

- (instancetype)initWithURI:(NSURL *)uri byteRange:(nullable LSPByteRange *)byteRange
{
    self = [super init];
    
    if (self) {
        _uri = [uri copy];
        _byteRange = byteRange;
    }

    return self;
}

+ (LSPAttributeType)attributeTypeForKey:(NSString *)key
{
    static NSDictionary<NSString *, NSNumber *> *attributeTypeForKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        attributeTypeForKey = @{@"URI": @(LSPAttributeTypeQuotedString),
                                @"BYTERANGE": @(LSPAttributeTypeQuotedString),
                                };
    });
    return [attributeTypeForKey[key] integerValue];
}

+ (NSArray<NSString *> *)attributeKeys
{
    return @[@"URI", @"BYTERANGE"];
}

- (nullable NSString *)valueStringForAttributeKey:(nonnull NSString *)key
{
    if ([key isEqualToString:@"URI"]) {
        return LSPQuotedString([self.uri absoluteString]);
    }
    
    if ([key isEqualToString:@"BYTERANGE"]) {
        return [self.byteRange serialize];
    }

    return nil;
}

- (NSString *)name
{
    return @"EXT-X-MAP";
}

- (nonnull NSString *)serialize
{
    return LSPSerializeAttributedTag(self);
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    return [[self serialize] isEqualToString:[other serialize]];
}

- (NSUInteger)hash
{
    return [_uri hash] ^ [_byteRange hash];
}

@end

@implementation LSPProgramDateTimeTag

- (instancetype)initWithDate:(NSDate *)date
{
    self = [super init];
    
    if (self != nil) {
        _date = [date copy];
    }

    return self;
}

- (NSString *)name
{
    return @"EXT-X-PROGRAM-DATE-TIME";
}

- (NSString *)serialize
{
    // TODO
    return @"";
}

- (NSUInteger)hash
{
    return [_date hash];
}

@end


@implementation LSPByteRangeTag

- (instancetype)initWithByteRange:(LSPByteRange *)byteRange
{
    self = [super init];
    
    if (self != nil) {
        _byteRange = byteRange;
    }

    return self;
}

- (NSString *)name
{
    return @"EXT-X-BYTERANGE";
}

- (NSString *)serialize
{
    return [NSString stringWithFormat:@"#%@:%@", [self name], [self.byteRange serialize]];
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    if (!LSPEqualObjects(self.byteRange, other.byteRange)) {
        return NO;
    }

    return YES;
}

- (NSUInteger)hash
{
    return [_byteRange hash];
}

@end


#pragma mark - Media Playlist Tags


@implementation LSPMediaSequenceTag

- (instancetype)init
{
    return [self initWithIntegerAttribute:1];
}

- (instancetype)initWithIntegerAttribute:(NSInteger)number
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    _number = number;
    
    return self;
}

- (NSString *)name
{
    return @"EXT-X-MEDIA-SEQUENCE";
}

- (NSString *)serialize
{
    return [NSString stringWithFormat:@"#%@:%@", [self name], @(self.number)];
}

- (NSUInteger)hash
{
    return (NSUInteger)_number;
}

@end

@implementation LSPDiscontinuitySequenceTag

- (instancetype)init
{
    return [self initWithIntegerAttribute:1];
}

- (instancetype)initWithIntegerAttribute:(NSInteger)number
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    _number = number;
    
    return self;
}

- (NSString *)name
{
    return @"EXT-X-DISCONTINUITY-SEQUENCE";
}

- (NSString *)serialize
{
    return [NSString stringWithFormat:@"#%@:%@", [self name], @(self.number)];
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    return self.number == other.number;
}

- (NSUInteger)hash
{
    return (NSUInteger)_number;
}

@end

@implementation LSPPlaylistTypeTag

- (nullable instancetype)initWithEnumeratedString:(NSString *)enumeratedString
{
    if ([enumeratedString isEqualToString:@"VOD"]) {
        return [self initWithType:LSPPlaylistTypeVOD];
    } else if ([enumeratedString isEqualToString:@"EVENT"]) {
        return [self initWithType:LSPPlaylistTypeEvent];
    }

    return nil;
}

- (instancetype)initWithType:(LSPPlaylistType)type
{
    self = [super init];
    
    if (self != nil) {
        _type = type;
    }

    
    return self;
}

- (NSString *)name
{
    return @"EXT-X-PLAYLIST-TYPE";
}

- (NSString *)serialize
{
    return [NSString stringWithFormat:@"#%@:%@", [self name], LSPPlaylistTypeString(self.type)];
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    return self.type == other.type;
}

- (NSUInteger)hash
{
    return (NSUInteger)_type;
}

@end


@implementation LSPTargetDurationTag

- (instancetype)initWithIntegerAttribute:(NSInteger)duration
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    _duration = duration;
    
    return self;
}

- (NSString *)name
{
    return @"EXT-X-TARGETDURATION";
}

- (NSString *)serialize
{
    return [NSString stringWithFormat:@"#%@:%@", [self name], @(self.duration)];
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    }
    
    if (object == self) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    __typeof(self) other = object;
    
    return self.duration == other.duration;
}

- (NSUInteger)hash
{
    return (NSUInteger)_duration;
}

@end
