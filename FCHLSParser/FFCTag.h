//
//  FFCTag.h
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

@import Foundation;
@import CoreGraphics;

NS_ASSUME_NONNULL_BEGIN

/**
 Types available in an attribute list

 - FFCAttributeTypeUnknown: For use when an attribute name is unknown. May result in short-circuiting parsing for the current tag.
 - FFCAttributeTypeDecimalInteger: [0-9] in range 0 to 2^64-1 (implies 1 to 20 digits)
 - FFCAttributeTypeHexidecimalSequence: 0x or 0X prefix with characters [0..9], [A..F]. Max length is variable.
 - FFCAttributeTypeDecimalFloatingPoint: [0..9] and ., non-negative decimal
 - FFCAttributeTypeSignedDecimalFloatingPoint: [0..9], - and .
 - FFCAttributeTypeQuotedString:  within a pair of quotes (0x22). Must not contain CR (0xD) or LF (0xA) or " (0x22). Equality is determined by bytewise comparison.
 - FFCAttributeTypeEnumeratedString: unquoted string pre-defined by the Attribute it's used in. will never contain ", ', or whitespace.
 - FFCAttributeTypeDecimalResolution: two decimal-integer separated by x define a width and a height
 */
typedef NS_ENUM(NSInteger, FFCAttributeType) {
    FFCAttributeTypeUnknown,
    FFCAttributeTypeDecimalInteger,
    FFCAttributeTypeHexidecimalSequence,
    FFCAttributeTypeDecimalFloatingPoint,
    FFCAttributeTypeSignedDecimalFloatingPoint,
    FFCAttributeTypeQuotedString,
    FFCAttributeTypeEnumeratedString,
    FFCAttributeTypeDecimalResolution,
};

@protocol FFCAttributedTag <NSObject>

+ (FFCAttributeType)attributeTypeForKey:(NSString *)key;

- (nullable instancetype)initWithAttributes:(NSDictionary<NSString *, NSObject *> *)attributes;

@end

@interface FFCTag : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithName:(NSString *)name;

@property(nonatomic, readonly) NSString *name;

@end

/**
 A tag for EXT-X-VERSION
 */
@interface FFCVersionTag : FFCTag

- (instancetype)initWithName:(NSString *)name NS_UNAVAILABLE;

/**
 Initialized a version tag with the default version, 1
 */
- (instancetype)init;

- (instancetype)initWithIntegerAttribute:(NSInteger)version;

@property (nonatomic, readonly) NSInteger version;

@end

/**
 A tag for EXT-X-STREAM-INF
 */
@interface FFCStreamInfoTag : FFCTag <FFCAttributedTag>

/**
 Bits per second, represents the peak segment bit rate
 
 This is a required value and will always be present. Initialization will fail
 if this value isn't in the attributes dictionary.
 */
@property (nonatomic, readonly) NSUInteger bandwidth;

/**
 Average bandwidth in bits per second
 
 Not required. Will be zero if not present in attributes.
 */
@property (nonatomic, readonly) NSUInteger averageBandwidth;

/**
 List of formats RFC6381
 
 If CODECS attribute is not provided, this property will be an empty array.
 
 Strongly recommended.
 */
@property (nonatomic, readonly) NSArray<NSString *> *codecs;

/**
 Recommended for video content.
 
 Not required. Will be CGSizeZero if not present in attributes.
 */
@property (nonatomic, readonly) CGSize resolution;

/**
 Maximum frame rate for all video in the variant stream. 
 
 Rounded to 3 decimal places. Should be present if video is ever >30fps
 
 Not required. Will be zero if not present in attributes.
 */
@property (nonatomic, readonly) double frameRate;

/**
 The Group name of an associated Audio media
 
 Must match GROUP-ID attribute of an EXT-X-MEDIA tag with an AUDIO type
 */
@property (nonatomic, nullable, readonly, copy) NSString *audio;

/**
 The Group name of an associated Video media
 
 Must match GROUP-ID attribute of an EXT-X-MEDIA tag with an VIDEO type
 */
@property (nonatomic, nullable, readonly, copy) NSString *video;

/**
 The Group name of an associated Subtitles media
 
 Must match GROUP-ID attribute of an EXT-X-MEDIA tag with an SUBTITLES type
 */
@property (nonatomic, nullable, readonly, copy) NSString *subtitles;

/**
 The Group name of an associated Closed-Captions media
 
 Must match GROUP-ID attribute of an EXT-X-MEDIA tag with an CLOSED-CAPTIONS type
 */
@property (nonatomic, nullable, readonly, copy) NSString *closedCaptions;

- (instancetype)initWithName:(NSString *)name NS_UNAVAILABLE;

- (nullable instancetype)initWithAttributes:(NSDictionary<NSString *, NSObject *> *)attributes;

@end

/**
 A tag for EXT-X-I-FRAME-STREAM-INF
 */
@interface FFCIFrameStreamInfoTag : FFCTag <FFCAttributedTag>

/**
 Bits per second, represents the peak segment bit rate
 
 This is a required value and will always be present. Initialization will fail
 if this value isn't in the attributes dictionary.
 */
@property (nonatomic, readonly) NSUInteger bandwidth;

/**
 Average bandwidth in bits per second
 
 Not required. Will be zero if not present in attributes.
 */
@property (nonatomic, readonly) NSUInteger averageBandwidth;

/**
 List of formats RFC6381
 
 If CODECS attribute is not provided, this property will be an empty array.
 
 Strongly recommended.
 */
@property (nonatomic, readonly) NSArray<NSString *> *codecs;

/**
 Recommended for video content.
 
 Not required. Will be CGSizeZero if not present in attributes.
 */
@property (nonatomic, readonly) CGSize resolution;

/**
 Maximum frame rate for all video in the variant stream.
 
 Rounded to 3 decimal places. Should be present if video is ever >30fps
 
 Not required. Will be zero if not present in attributes.
 */
@property (nonatomic, readonly) double frameRate;

/**
 Identifies media playlist file.
 */
@property (nonatomic, readonly) NSURL *uri;

@end

typedef NS_ENUM(NSInteger, FFCMediaType) {
    FFCMediaTypeUnknown,
    FFCMediaTypeAudio,
    FFCMediaTypeVideo,
    FFCMediaTypeSubtitles,
    FFCMediaTypeClosedCaptions
};

/**
 A tag for EXT-X-MEDIA
 */
@interface FFCMediaTag : FFCTag <FFCAttributedTag>

/**
 The type of media represented by this Tag.
 */
@property (nonatomic, readonly) FFCMediaType type;

/**
 Identifies the Media Playlist
 */
@property (nonatomic, readonly, nullable) NSURL *uri;

/**
 Group to which Rendition belongs
 */
@property (nonatomic, readonly, copy) NSString *groupID;

/**
 Primary language used in the Rendition as a string described by RFC 5646
 */
@property (nonatomic, readonly, nullable, copy) NSString *language;

/**
 Associated language used in the Rendition as a string described by RFC 5646
 */
@property (nonatomic, readonly, nullable, copy) NSString *associatedLanguage;

/**
 Name of the rendition
 */
@property (nonatomic, readonly, copy) NSString *renditionName;

/**
 If YES, client should play this media until user says otherwise. Absence is NO
 
 Absence in attribute dictionary implies NO
 */
@property (nonatomic, readonly) BOOL defaultRendition;

/**
 Makes media eligible for automatic playback based on environment reasons 
 (e.g. language)
 
 Absence in attribute dictionary implies NO
 */
@property (nonatomic, readonly) BOOL autoselect;

/**
 Must only appear for TYPE=SUBTITLES. YES means content is essential.
 
 Absence in attribute dictionary implies NO.
 */
@property (nonatomic, readonly) BOOL forced;

@property (nonatomic, readonly, copy) NSString *instreamID;

/**
 UTIs
 */
@property (nonatomic, readonly, copy) NSArray<NSString *> *characteristics;

- (instancetype)initWithName:(NSString *)name NS_UNAVAILABLE;

@end

@interface FFCSessionDataTag : FFCTag <FFCAttributedTag>

/**
 Identifies the data value. Should use reverse DNS namespace to avoid collisions.
 
 Required value.
 */
@property (nonatomic, readonly) NSString *dataID;

/**
 Value. 
 
 If LANGUAGE is specified, value should be human-readable in that language. 
 Tag must have either VALUE or URI.
 */
@property (nonatomic, readonly, nullable) NSString *value;

/**
 URI to a JSON resource. 
 
 Tag must have either VALUE or URI
 */
@property (nonatomic, readonly, nullable) NSURL *uri;

/**
 Language
 
 RFC5646
 */
@property (nonatomic, readonly, nullable) NSString *language;

- (instancetype)initWithName:(NSString *)name NS_UNAVAILABLE;

@end


NS_ASSUME_NONNULL_END
