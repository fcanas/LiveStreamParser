//
//  LSPTag.h
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

 - LSPAttributeTypeUnknown: For use when an attribute name is unknown. May result in short-circuiting parsing for the current tag.
 - LSPAttributeTypeDecimalInteger: [0-9] in range 0 to 2^64-1 (implies 1 to 20 digits)
 - LSPAttributeTypeHexidecimalSequence: 0x or 0X prefix with characters [0..9], [A..F]. Max length is variable.
 - LSPAttributeTypeDecimalFloatingPoint: [0..9] and ., non-negative decimal
 - LSPAttributeTypeSignedDecimalFloatingPoint: [0..9], - and .
 - LSPAttributeTypeQuotedString:  within a pair of quotes (0x22). Must not contain CR (0xD) or LF (0xA) or " (0x22). Equality is determined by bytewise comparison.
 - LSPAttributeTypeEnumeratedString: unquoted string pre-defined by the Attribute it's used in. will never contain ", ', or whitespace.
 - LSPAttributeTypeDecimalResolution: two decimal-integer separated by x define a width and a height
 */
typedef NS_ENUM(NSInteger, LSPAttributeType) {
    LSPAttributeTypeUnknown,
    LSPAttributeTypeDecimalInteger,
    LSPAttributeTypeHexidecimalSequence,
    LSPAttributeTypeDecimalFloatingPoint,
    LSPAttributeTypeSignedDecimalFloatingPoint,
    LSPAttributeTypeQuotedString,
    LSPAttributeTypeEnumeratedString,
    LSPAttributeTypeDecimalResolution,
};

/**
 A common protocol for all HLS tags.
 */
@protocol LSPTag <NSObject>

/**
 The name of the tag. This is how the tag appears in a playlist, excluding the
 # prefix.
 
 For example, #EXTM3U is the first line of a playlist. An LSPTag representing it
 would have the name EXTM3U
 */
@property(nonatomic, readonly) NSString *name;

@end

/**
 A protocol for tags that have attribute lists.
 
 The protocol provides a mechanism for the tag to specify the type of a specific
 attribute and for initializing a tag with an atttribute list.
 */
@protocol LSPAttributedTag <LSPTag>

/**
 Allows an AttributedTag to specify the type of the attribute for a given
 attribute key.
 
 A tag parser will determine the tag class based on the tag string that is
 parsed. If that tag expects to have an attribute list each attribue will be
 parsed according to its expected type. First the attribute name is parsed, then
 the tag class is asked what the expected type is via @c +attributeTypeForKey:.
 The parser will then parse the value according to rules for that type. If the
 value does not validate for that type, the attribute will be skipped. All
 attribute name-value pairs are accumulated into a dictionary passed to the
 initializer for the tag class, @c -initWithAttributes:

 @see -initWithAttributes:
 @param key An attribute name
 @return The type of the attribute, or nil if the tag does not recognize the
         attribute.
 */
+ (LSPAttributeType)attributeTypeForKey:(NSString *)key;

/**
 Initialized the receiving attribute tag class with parsed attribute list.

 @see +attributeTypeForKey:
 @param attributes Key-value pairs for attribute names and their values
 @return An initialized tag or nil if the tag cannot be properly initialized
         with the provided attributes.
 */
- (nullable instancetype)initWithAttributes:(NSDictionary<NSString *, id> *)attributes;

@end

/**
 A tag to stand-in for URIs that occupy an entire line in a playlist.
 */
@interface LSPURITag : NSObject <LSPTag>

- (instancetype)init NS_UNAVAILABLE;

- (nullable instancetype)initWithURIString:(NSString *)URIString;

@property (nonatomic, nonnull, readonly) NSURL *uri;

@end


/**
 A basic tag class.
 
 Tags such as EXTM3U that have no additional parameters should be of this type.
 */
@interface LSPBasicTag : NSObject <LSPTag>

- (instancetype)init NS_UNAVAILABLE;

/**
 Initializes a basic tag whose only information is its name.

 @param name The name of the tag
 @return An initialized tag
 */
- (instancetype)initWithName:(NSString *)name;

@end

/**
 A tag for EXT-X-VERSION
 */
@interface LSPVersionTag : NSObject<LSPTag>

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
@interface LSPStreamInfoTag : NSObject <LSPAttributedTag>

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

@end

/**
 A tag for EXT-X-I-FRAME-STREAM-INF
 */
@interface LSPIFrameStreamInfoTag : NSObject <LSPAttributedTag>

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

/**
 The type of media specified in a media tag.

 - LSPMediaTypeUnknown: The media type is unknown
 - LSPMediaTypeAudio: Audio
 - LSPMediaTypeVideo: Video
 - LSPMediaTypeSubtitles: Subtitles
 - LSPMediaTypeClosedCaptions: Closed Captions
 */
typedef NS_ENUM(NSInteger, LSPMediaType) {
    LSPMediaTypeUnknown,
    LSPMediaTypeAudio,
    LSPMediaTypeVideo,
    LSPMediaTypeSubtitles,
    LSPMediaTypeClosedCaptions
};

/**
 A tag for EXT-X-MEDIA
 */
@interface LSPMediaTag : NSObject <LSPAttributedTag>

/**
 The type of media represented by this Tag.
 */
@property (nonatomic, readonly) LSPMediaType type;

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

/**
 A tag reprenenting EXT-X-SESSION-DATA
 */
@interface LSPSessionDataTag : NSObject <LSPAttributedTag>

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

typedef NS_ENUM(NSInteger, LSPEncryptionMethod) {
    LSPEncryptionMethodNone,
    LSPEncryptionMethodAES128,
    LSPEncryptionMethodSampleAES
};

@interface LSPSessionKeyTag : NSObject <LSPAttributedTag>

/**
 AES-128, or SAMPLE-AES
 */
@property (nonatomic, readonly) LSPEncryptionMethod method;

/**
 Where to obtain the key. Required if method is not NONE
 */
@property (nonatomic, nullable, readonly) NSURL *uri;

/**
 128-bit initialization vector for use with the key as a hex string.
 
 Compatibility version >= 2
 */
@property (nonatomic, nullable, readonly) NSString *initializationVector;

/**
 How the key is represented. Absence is implicit "identity"
 
 Version >= 5.
 */
@property (nonatomic, readonly) NSString *keyFormat;

/**
 Array of integers, indicates version compatibility of key
 
 Initialized with a string consisting of integers separated by "/".
 If parameter is omitted, will be an empyy array
 
 Version >= 5
 */
@property (nonatomic, readonly) NSArray<NSNumber *> *keyFormatVersions;

- (instancetype)initWithName:(NSString *)name NS_UNAVAILABLE;

@end

/**
 Tag for #EXT-X-START

 Represents the preferred point to start playing a playlist.
 */
@interface LSPStartTag : NSObject <LSPAttributedTag>

/**
 Time offset from beginning of the playlist if positive. Time offset before the
 end of playlist if negative.
 */
@property (nonatomic, readonly) NSTimeInterval timeOffset;

/**
  If yes, then presentation should start at TIME-OFFSET and media before that
 point should not be rendered. If NO, then the whole segment containing 
 TIME-OFFSET should be rendered.
 */
@property (nonatomic, readonly) BOOL precise;

@end

#pragma mark - Media Segment Tags

/**
 Tag for #EXTINF
 */
@interface LSPInfoTag : NSObject <LSPTag>

- (instancetype)init NS_UNAVAILABLE;

/**
 The duration of the next segment.
 */
@property (nonatomic) NSTimeInterval duration;

/**
 A human-readable title of the segment
 */
@property (nonatomic, nullable, readonly, copy) NSString *title;

/**
 Initializes a new LSPInfoTag.
 
 An EXTINF tag has one or two arguments, not in an argument list. The duration
 is not optional, and the title is. Because the tag is unique in its
 construction, it has its own initializer.

 @param duration duration of the segment the tag represents
 @param title the title of the segment the tag represents
 @return an initialized LSPInfoTag
 */
- (instancetype)initWithDuration:(NSTimeInterval)duration title:(nullable NSString *)title;

@end

#pragma mark - Media Playlist Tags

/**
 A tag for EXT-X-MEDIA-SEQUENCE
 */
@interface LSPMediaSequenceTag : NSObject<LSPTag>

- (instancetype)initWithName:(NSString *)name NS_UNAVAILABLE;

/**
 Initialized a version tag with the default version, 1
 */
- (instancetype)init;

- (instancetype)initWithIntegerAttribute:(NSInteger)number;

@property (nonatomic, readonly) NSInteger number;

@end

/**
 A tag for EXT-X-DISCONTINUITY-SEQUENCE
 */
@interface LSPDiscontinuitySequenceTag : NSObject<LSPTag>

- (instancetype)initWithName:(NSString *)name NS_UNAVAILABLE;

/**
 Initialized a version tag with the default version, 1
 */
- (instancetype)init;

- (instancetype)initWithIntegerAttribute:(NSInteger)number;

@property (nonatomic, readonly) NSInteger number;

@end


NS_ASSUME_NONNULL_END
