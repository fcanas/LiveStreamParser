//
//  LSPByteRange.m
//  LiveStreamParser
//
//  Created by Fabian Canas on 4/10/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "LSPByteRange.h"

@implementation LSPByteRange

- (instancetype)initWithString:(NSString *)string
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:string];
    unsigned long long length;

    if ([scanner scanUnsignedLongLong:&length]) {
        _length = (NSUInteger)length;
    } else {
        return nil;
    }
    
    if ([scanner isAtEnd]) {
        return self;
    }
    
    unsigned long long offset;
    if ([scanner scanString:@"@" intoString:nil] && [scanner scanUnsignedLongLong:&offset]) {
        _offset = @((NSUInteger)offset);
    } else {
        return nil;
    }
    
    return self;
}

- (instancetype)initWithLength:(NSUInteger)length offset:(NSUInteger)offset
{
    self = [super init];
    
    if (self) {
        _length = length;
        _offset = @(offset);
    }
    
    return self;
}

- (NSUInteger)hash
{
    NSUInteger offsetHash = [_offset hash];
    return ((_length << 4) | (_length >> 4)) ^ offsetHash;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[LSPByteRange class]]) {
        return NO;
    }
    LSPByteRange *other = object;
    
    if (other.length != self.length) {
        return NO;
    }
    
    if ((other.offset == nil) != (self.offset == nil)) {
        return NO;
    }

    if ([other.offset unsignedIntegerValue] != [self.offset unsignedIntegerValue]) {
        return NO;
    }

    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"LSPByteRange(length:%@, offset:%@)", @(self.length), self.offset];
}

@end
