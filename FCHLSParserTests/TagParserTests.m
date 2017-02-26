//
//  TagParserTests.m
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "FFCTagParser.h"
#import "FFCTag.h"

@import CoreGraphics;
@import XCTest;

@interface TagParserTests : XCTestCase

@end

@implementation TagParserTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testNoTagToParse
{
    FFCTagParser *parser = [[FFCTagParser alloc] initWithString:@""];
    XCTAssertNil([parser nextTag]);
}

- (void)testOneTag
{
    FFCTagParser *parser = [[FFCTagParser alloc] initWithString:@"#EXTM3U"];
    FFCTag *tag = [parser nextTag];
    XCTAssertTrue([tag isKindOfClass:[FFCTag class]]);
    XCTAssertEqualObjects(tag.name, @"EXTM3U");
    
    tag = [parser nextTag];
    XCTAssertNil(tag);
}

- (void)testSequentialTags
{
    FFCTagParser *parser = [[FFCTagParser alloc] initWithString:@"#EXTM3U\n#EXT-X-VERSION:6\n#EXT-X-INDEPENDENT-SEGMENTS"];
    FFCTag *tag = [parser nextTag];
    XCTAssertEqualObjects(tag.name, @"EXTM3U");
    tag = [parser nextTag];
    XCTAssertEqualObjects(tag.name, @"EXT-X-VERSION");
    tag = [parser nextTag];
    XCTAssertEqualObjects(tag.name, @"EXT-X-INDEPENDENT-SEGMENTS");
    tag = [parser nextTag];
    XCTAssertNil(tag);
}

- (void)testParseMethodReturnsCorrectNumberOfTags
{
    FFCTagParser *parser = [[FFCTagParser alloc] initWithString:@"#EXTM3U\n#EXT-X-VERSION:6\n#EXT-X-INDEPENDENT-SEGMENTS"];
    NSArray *tags = [parser parse];
    
    XCTAssertEqual(tags.count, (NSUInteger)3);
}

#pragma mark - Specific Tag Parsing

- (void)testParseVersionTag
{
    FFCTagParser *parser = [[FFCTagParser alloc] initWithString:@"#EXT-X-VERSION:6"];
    FFCVersionTag *versionTag = [parser nextTag];
    XCTAssert([versionTag isKindOfClass:[FFCVersionTag class]]);
    XCTAssertEqual(versionTag.version, 6);
    
    parser = [[FFCTagParser alloc] initWithString:@"#EXT-X-VERSION:3"];
    versionTag = [parser nextTag];
    XCTAssertEqual(versionTag.version, 3);
}

- (void)testStreamInfoTagParsing
{
    NSString *tagString = @"#EXT-X-STREAM-INF:AVERAGE-BANDWIDTH=1290298,BANDWIDTH=1304252,CODECS=\"avc1.64001e,mp4a.40.2\",RESOLUTION=768x432,FRAME-RATE=29.970,CLOSED-CAPTIONS=\"cc1\",AUDIO=\"aud1\",SUBTITLES=\"sub1\"";
    FFCTagParser *parser = [[FFCTagParser alloc] initWithString:tagString];
    
    FFCStreamInfoTag *tag = (FFCStreamInfoTag *)[parser nextTag];
    XCTAssertNotNil(tag);
    XCTAssert([tag isKindOfClass:[FFCStreamInfoTag class]]);
    
    XCTAssertEqual(tag.bandwidth, (NSUInteger)1304252);
    XCTAssertEqual(tag.averageBandwidth, (NSUInteger)1290298);
    XCTAssertTrue(CGSizeEqualToSize(tag.resolution, CGSizeMake(768,432)));
    XCTAssertEqualWithAccuracy(tag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(tag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(tag.audio, @"aud1");
    XCTAssertEqualObjects(tag.subtitles, @"sub1");
    NSArray *codecs = @[@"avc1.64001e", @"mp4a.40.2"];
    XCTAssertEqualObjects(tag.codecs, codecs);
}

- (void)testIFrameStreamInfoTagParsing
{
    NSString *tagString = @"#EXT-X-I-FRAME-STREAM-INF:AVERAGE-BANDWIDTH=80061,BANDWIDTH=83389,CODECS=\"avc1.64001e\",RESOLUTION=768x432,URI=\"v3/iframe_index.m3u8\"";
    FFCTagParser *parser = [[FFCTagParser alloc] initWithString:tagString];
    
    FFCIFrameStreamInfoTag *tag = (FFCIFrameStreamInfoTag *)[parser nextTag];
    XCTAssertNotNil(tag);
    XCTAssert([tag isKindOfClass:[FFCIFrameStreamInfoTag class]]);
    
    XCTAssertEqual(tag.bandwidth, (NSUInteger)83389);
    XCTAssertEqual(tag.averageBandwidth, (NSUInteger)80061);
    NSArray *codecs = @[@"avc1.64001e"];
    XCTAssertEqualObjects(tag.codecs, codecs);
    XCTAssertTrue(CGSizeEqualToSize(tag.resolution, CGSizeMake(768,432)));
}


#pragma mark - Performance

- (void)testPerformanceExample
{
    NSString *testPlaylistString = [NSString stringWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"master" withExtension:@"m3u8"] encoding:NSUTF8StringEncoding error:nil];
    
    // Sanity check to make sure we've loaded the test playlist
    XCTAssertEqual(testPlaylistString.length, (NSUInteger)2621);
    
    [self measureBlock:^{
        FFCTagParser *parser = [[FFCTagParser alloc] initWithString:testPlaylistString];
        [parser parse];
    }];
}

@end
