//
//  TagParserTests.m
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "LSPTagParser.h"
#import "LSPTag.h"

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
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:@""];
    XCTAssertNil([parser nextTag]);
}

- (void)testOneTag
{
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:@"#EXTM3U"];
    LSPBasicTag *tag = [parser nextTag];
    XCTAssertTrue([tag isKindOfClass:[LSPBasicTag class]]);
    XCTAssertEqualObjects(tag.name, @"EXTM3U");
    
    tag = [parser nextTag];
    XCTAssertNil(tag);
}

- (void)testSequentialTags
{
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:@"#EXTM3U\n#EXT-X-VERSION:6\n#EXT-X-INDEPENDENT-SEGMENTS"];
    LSPBasicTag *tag = [parser nextTag];
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
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:@"#EXTM3U\n#EXT-X-VERSION:6\n#EXT-X-INDEPENDENT-SEGMENTS"];
    NSArray *tags = [parser parse];
    
    XCTAssertEqual(tags.count, (NSUInteger)3);
}

#pragma mark - Specific Tag Parsing

- (void)testParseVersionTag
{
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:@"#EXT-X-VERSION:6"];
    LSPVersionTag *versionTag = (LSPVersionTag *)[parser nextTag];
    XCTAssert([versionTag isKindOfClass:[LSPVersionTag class]]);
    XCTAssertEqual(versionTag.version, 6);
    
    parser = [[LSPTagParser alloc] initWithString:@"#EXT-X-VERSION:3"];
    versionTag = (LSPVersionTag *)[parser nextTag];
    XCTAssertEqual(versionTag.version, 3);
}

- (void)testStreamInfoTagParsing
{
    NSString *tagString = @"#EXT-X-STREAM-INF:AVERAGE-BANDWIDTH=1290298,BANDWIDTH=1304252,CODECS=\"avc1.64001e,mp4a.40.2\",RESOLUTION=768x432,FRAME-RATE=29.970,CLOSED-CAPTIONS=\"cc1\",AUDIO=\"aud1\",SUBTITLES=\"sub1\"";
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:tagString];
    
    LSPStreamInfoTag *tag = (LSPStreamInfoTag *)[parser nextTag];
    XCTAssertNotNil(tag);
    XCTAssert([tag isKindOfClass:[LSPStreamInfoTag class]]);
    
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

- (void)testUnsignedDecimalFloatParsing
{
    NSString *tagString = @"#EXT-X-STREAM-INF:BANDWIDTH=1304252,FRAME-RATE=-29.970";
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:tagString];
    
    LSPStreamInfoTag *tag = (LSPStreamInfoTag *)[parser nextTag];
    XCTAssertNotNil(tag);
    XCTAssert([tag isKindOfClass:[LSPStreamInfoTag class]]);
    XCTAssertEqual(tag.bandwidth, (NSUInteger)1304252);
    XCTAssertEqual(tag.frameRate, 0);
}

- (void)testIFrameStreamInfoTagParsing
{
    NSString *tagString = @"#EXT-X-I-FRAME-STREAM-INF:AVERAGE-BANDWIDTH=80061,BANDWIDTH=83389,CODECS=\"avc1.64001e\",RESOLUTION=768x432,URI=\"v3/iframe_index.m3u8\"";
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:tagString];
    
    LSPIFrameStreamInfoTag *tag = (LSPIFrameStreamInfoTag *)[parser nextTag];
    XCTAssertNotNil(tag);
    XCTAssert([tag isKindOfClass:[LSPIFrameStreamInfoTag class]]);
    
    XCTAssertEqual(tag.bandwidth, (NSUInteger)83389);
    XCTAssertEqual(tag.averageBandwidth, (NSUInteger)80061);
    NSArray *codecs = @[@"avc1.64001e"];
    XCTAssertEqualObjects(tag.codecs, codecs);
    XCTAssertTrue(CGSizeEqualToSize(tag.resolution, CGSizeMake(768,432)));
}

- (void)testAudioMediaTag
{
    NSString *tagString = @"#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"aud1\",LANGUAGE=\"eng\",NAME=\"English\",AUTOSELECT=YES,DEFAULT=YES,URI=\"a1/prog_index.m3u8\"";
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:tagString];
    
    LSPMediaTag *tag = (LSPMediaTag *)[parser nextTag];
    XCTAssertNotNil(tag);
    XCTAssertTrue([tag isKindOfClass:[LSPMediaTag class]]);
    
    XCTAssertEqual(tag.type, LSPMediaTypeAudio);
    XCTAssertEqualObjects(tag.groupID, @"aud1");
    XCTAssertEqualObjects(tag.language, @"eng");
    XCTAssertEqualObjects(tag.renditionName, @"English");
    XCTAssertTrue(tag.autoselect);
    XCTAssertTrue(tag.defaultRendition);
    XCTAssertFalse(tag.forced);
    XCTAssertEqualObjects(tag.uri, [NSURL URLWithString:@"a1/prog_index.m3u8"]);
}

- (void)testSubtitlesMediaTag
{
    NSString *tagString = @"#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"sub1\",NAME=\"English\",LANGUAGE=\"eng\",DEFAULT=YES,AUTOSELECT=YES,FORCED=NO,URI=\"s1/eng/prog_index.m3u8\"";
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:tagString];
    
    LSPMediaTag *tag = (LSPMediaTag *)[parser nextTag];
    XCTAssertNotNil(tag);
    XCTAssertTrue([tag isKindOfClass:[LSPMediaTag class]]);
    
    XCTAssertEqual(tag.type, LSPMediaTypeSubtitles);
    XCTAssertEqualObjects(tag.groupID, @"sub1");
    XCTAssertEqualObjects(tag.language, @"eng");
    XCTAssertEqualObjects(tag.renditionName, @"English");
    XCTAssertTrue(tag.autoselect);
    XCTAssertTrue(tag.defaultRendition);
    XCTAssertFalse(tag.forced);
    XCTAssertEqualObjects(tag.uri, [NSURL URLWithString:@"s1/eng/prog_index.m3u8"]);
}

- (void)testSessionDataTag
{
    NSString *tagString = @"#EXT-X-SESSION-DATA:DATA-ID=\"com.example.hls.sessiondata\",VALUE=\"Session Value\",LANGUAGE=\"eng\"";
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:tagString];
    
    LSPSessionDataTag *tag = (LSPSessionDataTag *)[parser nextTag];
    XCTAssertNotNil(tag);
    XCTAssertTrue([tag isKindOfClass:[LSPSessionDataTag class]]);
    
    XCTAssertEqualObjects(tag.dataID, @"com.example.hls.sessiondata");
    XCTAssertEqualObjects(tag.value, @"Session Value");
    XCTAssertEqualObjects(tag.language, @"eng");
}

- (void)testSessionKeyTag
{
    NSString *tagString = @"#EXT-X-SESSION-KEY:METHOD=AES-128,URI=\"http://example.com/key\",IV=0x12345678901234567890123456ABCDEF,KEYFORMATVERSIONS=\"6/7/10\"";
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:tagString];
    
    LSPSessionKeyTag *tag = (LSPSessionKeyTag *)[parser nextTag];
    XCTAssertNotNil(tag);
    XCTAssertTrue([tag isKindOfClass:[LSPSessionKeyTag class]]);
    
    XCTAssertEqual(tag.method, LSPEncryptionMethodAES128);
    XCTAssertEqualObjects(tag.uri, [NSURL URLWithString:@"http://example.com/key"]);
    XCTAssertEqualObjects(tag.initializationVector, @"0x12345678901234567890123456ABCDEF");
    NSArray *versionsArray = @[@6, @7, @10];
    XCTAssertEqualObjects(tag.keyFormatVersions, versionsArray);
}

- (void)testStartTag
{
    NSString *tagString = @"#EXT-X-START:TIME-OFFSET=-1.5,PRECISE=YES";
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:tagString];
    
    LSPStartTag *tag = (LSPStartTag *)[parser nextTag];
    XCTAssertNotNil(tag);
    XCTAssertTrue([tag isKindOfClass:[LSPStartTag class]]);
}

- (void)testInfoTag
{
    NSString *tagString = @"#EXTINF:6.00000,";
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:tagString];
    
    LSPInfoTag *tag = (LSPInfoTag *)[parser nextTag];
    XCTAssertNotNil(tag);
    XCTAssertTrue([tag isKindOfClass:[LSPInfoTag class]]);
}

@end
