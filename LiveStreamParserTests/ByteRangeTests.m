//
//  ByteRangeTests.m
//  LiveStreamParser
//
//  Created by Fabian Canas on 4/16/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "LSPByteRange.h"

@import XCTest;

@interface ByteRangeTests : XCTestCase

@end

@implementation ByteRangeTests

- (void)testValues
{
    LSPByteRange *byteRange = [[LSPByteRange alloc] initWithLength:10 offset:12];
    XCTAssertEqual(byteRange.length, (NSUInteger)10);
    XCTAssertEqual(byteRange.offset.unsignedIntegerValue, (NSUInteger)12);
    
    byteRange = [[LSPByteRange alloc] initWithLength:1 offset:22];
    XCTAssertEqual(byteRange.length, (NSUInteger)1);
    XCTAssertEqual(byteRange.offset.unsignedIntegerValue, (NSUInteger)22);
    
    byteRange = [[LSPByteRange alloc] init];
    byteRange.length = 10;
    byteRange.offset = @(12);
    XCTAssertEqual(byteRange.length, (NSUInteger)10);
    XCTAssertEqual(byteRange.offset.unsignedIntegerValue, (NSUInteger)12);
    
    byteRange = [[LSPByteRange alloc] init];
    byteRange.length = 10;
    XCTAssertEqual(byteRange.length, (NSUInteger)10);
    XCTAssertNil(byteRange.offset);
}

- (void)testEquality
{
    LSPByteRange *byteRange = [[LSPByteRange alloc] initWithLength:10 offset:12];
    LSPByteRange *other = [[LSPByteRange alloc] initWithLength:10 offset:12];
    XCTAssertEqualObjects(byteRange, other);
    
    byteRange = [[LSPByteRange alloc] initWithLength:12 offset:10];
    other = [[LSPByteRange alloc] initWithLength:10 offset:12];
    XCTAssertNotEqualObjects(byteRange, other);
    
    byteRange = [[LSPByteRange alloc] initWithLength:12 offset:10];
    other = [[LSPByteRange alloc] initWithLength:12 offset:12];
    XCTAssertNotEqualObjects(byteRange, other);
    
    byteRange = [[LSPByteRange alloc] initWithLength:12 offset:10];
    other = [[LSPByteRange alloc] initWithLength:1 offset:10];
    XCTAssertNotEqualObjects(byteRange, other);
}

- (void)testEqualityWithNilOffsets
{
    LSPByteRange *byteRange = [[LSPByteRange alloc] init];
    byteRange.length = 10;
    LSPByteRange *other = [[LSPByteRange alloc] init];
    other.length = 10;
    XCTAssertEqualObjects(byteRange, other);
    
    byteRange = [[LSPByteRange alloc] init];
    byteRange.length = 12;
    other = [[LSPByteRange alloc] init];
    other.length = 10;
    XCTAssertNotEqualObjects(byteRange, other);
    
    byteRange = [[LSPByteRange alloc] init];
    byteRange.length = 10;
    byteRange.offset = @(12);
    other = [[LSPByteRange alloc] init];
    other.length = 10;
    XCTAssertNotEqualObjects(byteRange, other);
    
    byteRange = [[LSPByteRange alloc] init];
    byteRange.length = 10;
    byteRange.offset = @(0);
    other = [[LSPByteRange alloc] init];
    other.length = 10;
    XCTAssertNotEqualObjects(byteRange, other, @"No offset is not the same as zero offset.");
}

@end
