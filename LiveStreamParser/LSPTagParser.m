//
//  LSPTagParser.m
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "LSPTagParser.h"
#import "LSPTag.h"

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface LSPTagParser ()
@property (nonatomic, copy) NSScanner *scanner;
@end

typedef NS_ENUM(NSInteger, LSPTagParameterType) {
    LSPTagParameterTypeUnknown,
    LSPTagParameterTypeInteger,
    LSPTagParameterTypeAttribtueList,
    LSPTagParameterTypeNumberOptionalString,
    LSPTagParameterTypeByteRange,
    LSPTagParameterTypeDate,
};

@implementation LSPTagParser

+ (Class)classForTagName:(NSString *)tagName
{
    static NSDictionary<NSString *, Class> *tagParameterTypeMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tagParameterTypeMap = @{@"EXT-X-VERSION": [LSPVersionTag class],
                                @"EXT-X-STREAM-INF" : [LSPStreamInfoTag class],
                                @"EXT-X-I-FRAME-STREAM-INF" : [LSPIFrameStreamInfoTag class],
                                @"EXT-X-MEDIA" : [LSPMediaTag class],
                                @"EXT-X-SESSION-DATA" : [LSPSessionDataTag class],
                                @"EXT-X-SESSION-KEY" : [LSPSessionKeyTag class],
                                @"EXT-X-START" : [LSPStartTag class],
                                @"EXTINF" : [LSPInfoTag class],
                                @"EXT-X-MEDIA-SEQUENCE" : [LSPMediaSequenceTag class],
                                @"EXT-X-DISCONTINUITY-SEQUENCE" : [LSPDiscontinuitySequenceTag class],
                                @"EXT-X-TARGETDURATION" : [LSPTargetDurationTag class],
                                @"EXT-X-MAP" : [LSPMapTag class],
                                @"EXT-X-BYTERANGE" : [LSPByteRangeTag class],
                                @"EXT-X-KEY" : [LSPKeyTag class],
                                @"EXT-X-PROGRAM-DATE-TIME" : [LSPProgramDateTimeTag class],
                                };
    });
    return tagParameterTypeMap[tagName];
}

+ (LSPTagParameterType)parameterTypeForTagName:(NSString *)tagName
{
    static NSDictionary<NSString *, NSNumber *> *tagParameterTypeMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tagParameterTypeMap = @{@"EXT-X-VERSION" : @(LSPTagParameterTypeInteger),
                                @"EXT-X-STREAM-INF" : @(LSPTagParameterTypeAttribtueList),
                                @"EXT-X-I-FRAME-STREAM-INF" : @(LSPTagParameterTypeAttribtueList),
                                @"EXT-X-MEDIA" : @(LSPTagParameterTypeAttribtueList),
                                @"EXT-X-SESSION-DATA" : @(LSPTagParameterTypeAttribtueList),
                                @"EXT-X-SESSION-KEY" : @(LSPTagParameterTypeAttribtueList),
                                @"EXT-X-START" : @(LSPTagParameterTypeAttribtueList),
                                @"EXTINF" : @(LSPTagParameterTypeNumberOptionalString),
                                @"EXT-X-MEDIA-SEQUENCE" : @(LSPTagParameterTypeInteger),
                                @"EXT-X-DISCONTINUITY-SEQUENCE" : @(LSPTagParameterTypeInteger),
                                @"EXT-X-TARGETDURATION" : @(LSPTagParameterTypeInteger),
                                @"EXT-X-MAP" : @(LSPTagParameterTypeAttribtueList),
                                @"EXT-X-BYTERANGE" : @(LSPTagParameterTypeByteRange),
                                @"EXT-X-KEY" : @(LSPTagParameterTypeAttribtueList),
                                @"EXT-X-PROGRAM-DATE-TIME" : @(LSPTagParameterTypeDate),
                                };
    });
    return [tagParameterTypeMap[tagName] integerValue];
}

/**
 A Character Set that matches tag names (not including the preceeding #) and
 attribute names.
 
 [A..Z], [0..9] and -

 @return A character set for matching tags and attribute names
 */
+ (NSCharacterSet *)tagAndAttributeNameCharacterSet
{
    static NSMutableCharacterSet *set;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSMutableCharacterSet uppercaseLetterCharacterSet];
        [set formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
        [set addCharactersInString:@"-"];
    });
    return set;
}


/**
 A Character Set that matches byte ranges
 
 [0..9] and @
 
 @return A character set for matching byte ranges
 */
+ (NSCharacterSet *)byteRangeCharacterSet
{
    static NSMutableCharacterSet *set;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSMutableCharacterSet decimalDigitCharacterSet];
        [set addCharactersInString:@"@"];
    });
    return set;
}

/**
 Character set for matching enumerated strings in attribute values
 
 Attributes will never contain ", ', or whitespace. They will also not cross
 line breaks.

 @return A character set for matching enumerated strings in attribute values
 */
+ (NSCharacterSet *)enumeratedStringCharacterSet
{
    static NSMutableCharacterSet *set;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSMutableCharacterSet characterSetWithCharactersInString:@"\"'\n\r,"];
        [set formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [set invert];
    });
    return set;
}

/**
 A Character Set for matching hex values.

 Hex values are [0-9], [A-F]. Lower-case [a-f] are not allowed. The x or X from
 a hex prefix are also not included.
 
 @return A Character Set for matching hex values.
 */
+ (NSCharacterSet *)hexCharacterSet
{
    static NSCharacterSet *set;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
    });
    return set;
}

- (instancetype)initWithString:(NSString *)string
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    _scanner = [[NSScanner alloc] initWithString:[string copy]];
    _scanner.caseSensitive = YES;
    _scanner.charactersToBeSkipped = nil;
    
    return self;
}

- (NSArray<id<LSPTag>> *)parse
{
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    id<LSPTag> tag = nil;
    while ((tag = [self nextTag])) {
        [tags addObject:tag];
    }
    
    return tags;
}

- (nullable id<LSPTag>)nextTag
{
    id<LSPTag> tag = nil;
    
    NSString *name = nil;
    BOOL scanningTag = [self.scanner scanString:@"#" intoString:NULL];
    
    if (!scanningTag) {
        // Scanning URI, a line not starting in #, into stand-in tag
        NSString *urlString = [self scanToNextTag];
        LSPURITag *uriTag = [[LSPURITag alloc] initWithURIString:urlString];
        return uriTag;
    }
    
    [self.scanner scanCharactersFromSet:[LSPTagParser tagAndAttributeNameCharacterSet] intoString:&name];
    
    if (name == nil) {
        return nil;
    }
    
    BOOL hasParameters = [self.scanner scanString:@":" intoString:NULL];
    
    if (hasParameters) {
        
        switch ([LSPTagParser parameterTypeForTagName:name]) {
            case LSPTagParameterTypeInteger: {
                NSInteger number;
                if ([self.scanner scanInteger:&number]) {
                    tag = [[[LSPTagParser classForTagName:name] alloc] initWithIntegerAttribute:number];
                }
            }
                break;
            case LSPTagParameterTypeAttribtueList: {
                Class tagClass = [LSPTagParser classForTagName:name];
                NSDictionary<NSString *, id> *attributes = [self parseAttributeListForTagClass:tagClass];
                tag = [[tagClass alloc] initWithAttributes:attributes];
            }
                break;
            case LSPTagParameterTypeNumberOptionalString: {
                Class tagClass = [LSPTagParser classForTagName:name];
                double number;
                NSString *string = nil;
                if ([self.scanner scanDouble:&number]) {
                    [self.scanner scanString:@"," intoString:nil];
                    [self.scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&string];
                    tag = [[tagClass alloc] initWithDuration:number title:string];
                }
            }
                break;
            case LSPTagParameterTypeByteRange: {
                Class tagClass = [LSPTagParser classForTagName:name];
                
                if (![tagClass instancesRespondToSelector:@selector(initWithByteRange:)]) {
                    break;
                }
                
                NSString *byteRangeString = nil;
                
                if ([self.scanner scanCharactersFromSet:[LSPTagParser byteRangeCharacterSet] intoString:&byteRangeString]) {
                    LSPByteRange *byteRange = [[LSPByteRange alloc] initWithString:byteRangeString];
                    if (byteRange != nil) {
                        tag = [[[tagClass class] alloc] initWithByteRange:byteRange];
                    }
                }
            }
                break;
            case LSPTagParameterTypeDate: {
                Class tagClass = [LSPTagParser classForTagName:name];
                
                if (![tagClass instancesRespondToSelector:@selector(initWithDate:)]) {
                    break;
                }
                
                NSDate *date = [NSDate date];
                tag = [[[tagClass class] alloc] initWithDate:date];
            }
                break;
            default:
                tag = [[LSPBasicTag alloc] initWithName:name];
                break;
        }
    }
    
    if (tag == nil) {
        tag = [[LSPBasicTag alloc] initWithName:name];
    }
    
    [self scanToNextTag];
    return tag;
}

/**
 Parses and returns an attribute list into a dictionary

 @param tagClass A tag class conforming to LSPAttributedTag
 @return A dictionary mapping attribute keys to value objects.
 */
- (NSDictionary<NSString *, id> *)parseAttributeListForTagClass:(Class)tagClass
{
    NSParameterAssert([tagClass conformsToProtocol:@protocol(LSPAttributedTag)]);

    NSMutableDictionary<NSString *, id> *attributeList = [[NSMutableDictionary alloc] init];
    
    BOOL hasAttributes = YES;
    while (hasAttributes) {
        NSString *key = nil;
        [self.scanner scanCharactersFromSet:[LSPTagParser tagAndAttributeNameCharacterSet] intoString:&key];
        [self.scanner scanString:@"=" intoString:NULL];
        id value = [self parseAttributeValueOfType:[tagClass attributeTypeForKey:key]];
        if (value != nil) {
            attributeList[key] = value;
        }
        hasAttributes = [self.scanner scanString:@"," intoString:NULL];
    }

    return attributeList;
}

/**
 Parses and returns an attribute value of a specified type.
 
 @param type The type of attribute to parse
 @return An object representing the attribute value, or nil if an error ocurred.
 */
- (nullable id)parseAttributeValueOfType:(LSPAttributeType)type
{
    switch (type) {
        case LSPAttributeTypeDecimalInteger:{
            NSInteger integer;
            BOOL scanned = [self.scanner scanInteger:&integer];
            if (scanned) {
                return [NSNumber numberWithInteger:integer];
            }
            return nil;
        }
            break;
        case LSPAttributeTypeDecimalFloatingPoint:{
            if ([self.scanner scanString:@"-" intoString:NULL]) {
                return nil;
            }
        }
            // Fallthrough. Above we ensure an unsigned decimal float is not
            // preceeded by a negative sign. The scanner otherwise scans
            // positive or negative double values, and we don't want to
            // implement custom floating point scanning.
        case LSPAttributeTypeSignedDecimalFloatingPoint:{
            double floatValue;
            BOOL scanned = [self.scanner scanDouble:&floatValue];
            if (scanned) {
                return [NSNumber numberWithDouble:floatValue];
            }
            return nil;
        }
            break;
        case LSPAttributeTypeDecimalResolution:{
            NSInteger width;
            NSInteger height;
            BOOL scanned = [self.scanner scanInteger:&width];
            if (!scanned) {
                return nil;
            }
            scanned = [self.scanner scanString:@"x" intoString:NULL];
            if (!scanned) {
                return nil;
            }
            scanned = [self.scanner scanInteger:&height];
            if (!scanned) {
                return nil;
            }
            return [NSValue valueWithCGSize:CGSizeMake((CGFloat)width, (CGFloat)height)];
        }
            break;
        case LSPAttributeTypeQuotedString:{
            NSString *quotedString = nil;
            
            BOOL scanned = [self.scanner scanString:@"\"" intoString:NULL];
            if (!scanned) {
                return nil;
            }
            scanned = [self.scanner scanUpToString:@"\"" intoString:&quotedString];
            if (!scanned) {
                return nil;
            }
            scanned = [self.scanner scanString:@"\"" intoString:NULL];
            if (!scanned) {
                return nil;
            }
            return quotedString;
        }
            break;
        case LSPAttributeTypeEnumeratedString:{
            NSString *enumeratedString = nil;
            
            BOOL scanned = [self.scanner scanCharactersFromSet:[LSPTagParser enumeratedStringCharacterSet] intoString:&enumeratedString];
            if (!scanned) {
                return nil;
            }
            
            return enumeratedString;
        }
            break;
        case LSPAttributeTypeHexidecimalSequence:{
            NSString *prefixString = nil;
            NSString *hexValueString = nil;
            
            if (!([self.scanner scanString:@"0x" intoString:&prefixString] || [self.scanner scanString:@"0X" intoString:&prefixString])) {
                return nil;
            }
            
            if (![self.scanner scanCharactersFromSet:[LSPTagParser hexCharacterSet] intoString:&hexValueString]) {
                return nil;
            }
            
            // Output the original string.
            // We've validated it's in a good format.
            return [NSString stringWithFormat:@"%@%@", prefixString, hexValueString];
        }
            break;
        default:
            return nil;
            break;
    }

}

/**
 Scans and returns the remaining characters on the current line and scans past
 any remaining newline characters.

 @return A string from the scanner's current location to the next newline 
         character.
 */
- (nullable NSString *)scanToNextTag
{
    NSString *scanned = nil;
    [self.scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&scanned];
    [self.scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
    return scanned;
}


@end

NS_ASSUME_NONNULL_END
