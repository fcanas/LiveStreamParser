//
//  FFCTagParser.m
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "FFCTagParser.h"
#import "FFCTag.h"

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface FFCTagParser ()
@property (nonatomic, copy) NSScanner *scanner;
@end

typedef NS_ENUM(NSInteger, FFCTagParameterType) {
    FFCTagParameterTypeUnknown,
    FFCTagParameterTypeNumber,
    FFCTagParameterTypeAttribtueList,
};

@implementation FFCTagParser

+ (Class)classForTagName:(NSString *)tagName
{
    static NSDictionary<NSString *, Class> *tagParameterTypeMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tagParameterTypeMap = @{@"EXT-X-VERSION": [FFCVersionTag class],
                                @"EXT-X-STREAM-INF" : [FFCStreamInfoTag class],
                                @"EXT-X-I-FRAME-STREAM-INF" : [FFCIFrameStreamInfoTag class],
                                @"EXT-X-MEDIA" : [FFCMediaTag class],
                                @"EXT-X-SESSION-DATA" : [FFCSessionDataTag class],
                                @"EXT-X-SESSION-KEY" : [FFCSessionKeyTag class]};
    });
    return tagParameterTypeMap[tagName];
}

+ (FFCTagParameterType)parameterTypeForTagName:(NSString *)tagName
{
    static NSDictionary<NSString *, NSNumber *> *tagParameterTypeMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tagParameterTypeMap = @{@"EXT-X-VERSION" : @(FFCTagParameterTypeNumber),
                                @"EXT-X-STREAM-INF" : @(FFCTagParameterTypeAttribtueList),
                                @"EXT-X-I-FRAME-STREAM-INF" : @(FFCTagParameterTypeAttribtueList),
                                @"EXT-X-MEDIA" : @(FFCTagParameterTypeAttribtueList),
                                @"EXT-X-SESSION-DATA" : @(FFCTagParameterTypeAttribtueList),
                                @"EXT-X-SESSION-KEY" : @(FFCTagParameterTypeAttribtueList),};
    });
    return [tagParameterTypeMap[tagName] integerValue];
}

+ (NSCharacterSet *)uppercaseAlphanumericCharacterSet
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
    
    return self;
}

- (NSArray<FFCTag *> *)parse
{
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    FFCTag *tag = nil;
    while ((tag = [self nextTag])) {
        [tags addObject:tag];
    }
    
    return tags;
}

- (nullable __kindof FFCTag *)nextTag
{
    FFCTag *tag = nil;
    [self scanToNextTag];
    
    NSString *name = nil;
    [self.scanner scanString:@"#" intoString:NULL];
    [self.scanner scanCharactersFromSet:[FFCTagParser uppercaseAlphanumericCharacterSet] intoString:&name];
    
    if (name == nil) {
        return nil;
    }
    
    BOOL hasParameters = [self.scanner scanString:@":" intoString:NULL];
    
    if (hasParameters) {
        
        switch ([FFCTagParser parameterTypeForTagName:name]) {
            case FFCTagParameterTypeNumber: {
                NSInteger number;
                if ([self.scanner scanInteger:&number]) {
                    tag = [[[FFCTagParser classForTagName:name] alloc] initWithIntegerAttribute:number];
                }
            }
                break;
            case FFCTagParameterTypeAttribtueList: {
                Class tagClass = [FFCTagParser classForTagName:name];
                NSDictionary<NSString *, id> *attributes = [self parseAttributeListForTagClass:tagClass];
                tag = [[tagClass alloc] initWithAttributes:attributes];
            }
                break;
            default:
                tag = [[FFCTag alloc] initWithName:name];
                break;
        }
    }
    
    if (tag == nil) {
        tag = [[FFCTag alloc] initWithName:name];
    }
    
    return tag;
}

/**
 Parses and returns an attribute list into a dictionary

 @param tagClass A tag class conforming to FFCAttributedTag
 @return A dictionary mapping attribute keys to value objects.
 */
- (NSDictionary<NSString *, id> *)parseAttributeListForTagClass:(Class)tagClass
{
    NSParameterAssert([tagClass conformsToProtocol:@protocol(FFCAttributedTag)]);
    
    NSMutableDictionary<NSString *, id> *attributeList = [[NSMutableDictionary alloc] init];
    
    BOOL hasAttributes = YES;
    while (hasAttributes) {
        NSString *key = nil;
        [self.scanner scanCharactersFromSet:[FFCTagParser uppercaseAlphanumericCharacterSet] intoString:&key];
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
- (nullable id)parseAttributeValueOfType:(FFCAttributeType)type
{
    switch (type) {
        case FFCAttributeTypeDecimalInteger:{
            NSInteger integer;
            BOOL scanned = [self.scanner scanInteger:&integer];
            if (scanned) {
                return [NSNumber numberWithInteger:integer];
            }
            return nil;
        }
            break;
        case FFCAttributeTypeDecimalFloatingPoint:{
            double floatValue;
            BOOL scanned = [self.scanner scanDouble:&floatValue];
            if (scanned) {
                return [NSNumber numberWithDouble:floatValue];
            }
            return nil;
        }
            break;
        case FFCAttributeTypeDecimalResolution:{
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
        case FFCAttributeTypeQuotedString:{
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
        case FFCAttributeTypeEnumeratedString:{
            NSString *enumeratedString = nil;
            
            BOOL scanned = [self.scanner scanCharactersFromSet:[FFCTagParser enumeratedStringCharacterSet] intoString:&enumeratedString];
            if (!scanned) {
                return nil;
            }
            
            return enumeratedString;
        }
            break;
        case FFCAttributeTypeHexidecimalSequence:{
            NSString *prefixString = nil;
            NSString *hexValueString = nil;
            
            if (!([self.scanner scanString:@"0x" intoString:&prefixString] || [self.scanner scanString:@"0X" intoString:&prefixString])) {
                return nil;
            }
            
            if (![self.scanner scanCharactersFromSet:[FFCTagParser hexCharacterSet] intoString:&hexValueString]) {
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

- (nullable NSString *)scanToNextTag
{
    NSString *scanned = nil;
    [self.scanner scanUpToString:@"#" intoString:&scanned];
    return scanned;
}


@end

NS_ASSUME_NONNULL_END
