//
//  TagTests.m
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "LSPTag.h"

@import XCTest;

@interface AbstractTagTestCase : XCTestCase
@end

@implementation AbstractTagTestCase

- (void)testSerialization
{
    if (![[self class] isEqual:[AbstractTagTestCase class]]) {
        XCTFail(@"Must be overridden by a subclass");
    }
}

- (void)testTagEquality
{
    if (![[self class] isEqual:[AbstractTagTestCase class]]) {
        XCTFail(@"Must be overridden by a subclass");
    }
}

@end

@interface TagTests : AbstractTagTestCase

@end

@implementation TagTests

- (void)testTagNameEquality {
    LSPBasicTag *tag1 = [[LSPBasicTag alloc] initWithName:@"EXTM3U"];
    LSPBasicTag *tag2 = [[LSPBasicTag alloc] initWithName:@"EXT-X-VERSION"];
    LSPBasicTag *tag3 = [[LSPBasicTag alloc] initWithName:@"EXTM3U"];
    
    XCTAssertNotEqualObjects(tag1.name, tag2.name);
    XCTAssertEqualObjects(tag1.name, tag3.name);
}

- (void)testSerialization
{
    LSPBasicTag *tag1 = [[LSPBasicTag alloc] initWithName:@"EXTM3U"];
    LSPBasicTag *tag2 = [[LSPBasicTag alloc] initWithName:@"EXT-X-VERSION"];

    XCTAssertEqualObjects([tag1 serialize], @"#EXTM3U");
    XCTAssertEqualObjects([tag2 serialize], @"#EXT-X-VERSION");
}

- (void)testTagEquality
{
    LSPBasicTag *tag1 = [[LSPBasicTag alloc] initWithName:@"EXTM3U"];
    LSPBasicTag *tag2 = [[LSPBasicTag alloc] initWithName:@"EXTM3U"];
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPBasicTag *tag3 = [[LSPBasicTag alloc] initWithName:@"EXT-X-VERSION"];
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

@interface VersionTagTests : AbstractTagTestCase

@end

@implementation VersionTagTests

- (void)testVersionTag
{
    LSPVersionTag *versionTag = [[LSPVersionTag alloc] init];
    XCTAssert(versionTag.version == 1);
    versionTag = [[LSPVersionTag alloc] initWithIntegerAttribute:3];
    XCTAssert(versionTag.version == 3);
    versionTag = [[LSPVersionTag alloc] initWithIntegerAttribute:0];
    XCTAssert(versionTag.version == 1);
}

- (void)testSerialization
{
    LSPVersionTag *versionTag = [[LSPVersionTag alloc] initWithIntegerAttribute:3];
    XCTAssertEqualObjects([versionTag serialize], @"#EXT-X-VERSION:3");
    versionTag = [[LSPVersionTag alloc] initWithIntegerAttribute:10];
    XCTAssertEqualObjects([versionTag serialize], @"#EXT-X-VERSION:10");
}

- (void)testTagEquality
{
    LSPVersionTag *tag1 = [[LSPVersionTag alloc] initWithIntegerAttribute:3];
    LSPVersionTag *tag2 = [[LSPVersionTag alloc] initWithIntegerAttribute:3];
    XCTAssertEqualObjects(tag1, tag2);
    LSPVersionTag *tag3 = [[LSPVersionTag alloc] initWithIntegerAttribute:4];
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

@interface URITagTests : AbstractTagTestCase

@end

@implementation URITagTests

- (void)testURITag
{
    LSPURITag *tag = [[LSPURITag alloc] initWithURIString:@" "];
    XCTAssertNil(tag, @"Must be initialized with a string that could be a url");
    
    tag = [[LSPURITag alloc] initWithURIString:@"http://www.example.com"];
    XCTAssertTrue([tag isKindOfClass:[LSPURITag class]]);
    XCTAssertEqualObjects(tag.uri, [NSURL URLWithString:@"http://www.example.com"]);
}

- (void)testSerialization
{
    LSPURITag *tag = [[LSPURITag alloc] initWithURIString:@"http://www.example.com"];
    XCTAssertEqualObjects([tag serialize], @"http://www.example.com");
    tag = [[LSPURITag alloc] initWithURIString:@"http://www.fabiancanas.com/12/13/14"];
    XCTAssertEqualObjects([tag serialize], @"http://www.fabiancanas.com/12/13/14");
}

- (void)testTagEquality
{
    LSPURITag *tag1 = [[LSPURITag alloc] initWithURIString:@"http://www.example.com"];
    LSPURITag *tag2 = [[LSPURITag alloc] initWithURIString:@"http://www.example.com"];
    
    XCTAssertEqualObjects(tag1, tag2);
}

@end

#pragma mark - Stream Info Tag

@interface StreamInfoTagTests : AbstractTagTestCase

@end

@implementation StreamInfoTagTests

- (void)testBasicStreamInfoTag
{
    LSPStreamInfoTag *infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{}];
    XCTAssertNil(infoTag, @"Info Tag needs bandwidth attribute");
    infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @"1"}];
    XCTAssertNil(infoTag, @"Bandwidth needs to be a number");
    infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1.2}];
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1, @"Bandwidth will be rounded to an integer");
    
    infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqualObjects(infoTag.name, @"EXT-X-STREAM-INF");
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1);
    infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1234568}];
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1234568);
}

- (void)testAverageBandwidth
{
    LSPStreamInfoTag *infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)0, @"When no bandwidth is present, value should be zero since we're not indicating a missing value otherwise");
    
    infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AVERAGE-BANDWIDTH":@12}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)12);
    
    infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AVERAGE-BANDWIDTH":@9876}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)9876);
}

- (void)testCodecs
{
    LSPStreamInfoTag *infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqualObjects(infoTag.codecs, @[]);
    
    NSArray *testCodecs = @[@"a", @"b", @"c"];
    
    infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CODECS":@"a,b,c"}];
    XCTAssertEqualObjects(infoTag.codecs, testCodecs);
    
    infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CODECS":@"single codec"}];
    XCTAssertEqualObjects(infoTag.codecs, @[@"single codec"]);
}

- (void)testResolution
{
    LSPStreamInfoTag *infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssert(CGSizeEqualToSize(infoTag.resolution, CGSizeZero));
    
    CGSize testSize = CGSizeMake(123, 456);
    infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"RESOLUTION":[NSValue valueWithCGSize:testSize]}];
    XCTAssert(CGSizeEqualToSize(infoTag.resolution, testSize));
}

- (void)testFrameRate
{
    LSPStreamInfoTag *infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqual(infoTag.frameRate, (NSUInteger)0, @"When no framerate is present, value should be zero since we're not indicating a missing value otherwise");
    
    infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"FRAME-RATE":@24}];
    XCTAssertEqual(infoTag.frameRate, (double)24);
    
    infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"FRAME-RATE":@65}];
    XCTAssertEqual(infoTag.frameRate, (double)65);
    
    infoTag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"FRAME-RATE":@(-24.0)}];
    XCTAssertEqual(infoTag.frameRate, 0, @"Frame rate must be positive");
}

- (void)testAudio
{
    LSPStreamInfoTag *infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertNil(infoTag.audio);
    
    infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AUDIO":@1}];
    XCTAssertNil(infoTag.audio, @"audio attribute must be a string");
    
    infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AUDIO":@"audio group"}];
    XCTAssertEqualObjects(infoTag.audio, @"audio group");
}

- (void)testVideo
{
    LSPStreamInfoTag *infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertNil(infoTag.video);
    
    infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"VIDEO":@1}];
    XCTAssertNil(infoTag.video, @"video attribute must be a string");
    
    infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"VIDEO":@"video group"}];
    XCTAssertEqualObjects(infoTag.video, @"video group");
}

- (void)testSubtitles
{
    LSPStreamInfoTag *infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertNil(infoTag.subtitles);

    infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"SUBTITLES":@1}];
    XCTAssertNil(infoTag.subtitles, @"subtitles attribute must be a string");
    
    infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"SUBTITLES":@"subtitles group"}];
    XCTAssertEqualObjects(infoTag.subtitles, @"subtitles group");
}

- (void)testClosedCaptions
{
    LSPStreamInfoTag *infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertNil(infoTag.closedCaptions);
    
    infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CLOSED-CAPTIONS":@1}];
    XCTAssertNil(infoTag.closedCaptions, @"cloed captions attribute must be a string");
    
    infoTag =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CLOSED-CAPTIONS":@"closed captions group"}];
    XCTAssertEqualObjects(infoTag.closedCaptions, @"closed captions group");
}

- (void)testHDCP
{
    // No HDCP
    LSPStreamInfoTag *specifiedNoHDCP =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"HDCP-LEVEL" : @"NONE"}];
    LSPStreamInfoTag *unspecifiedHDCP =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqualObjects(unspecifiedHDCP, specifiedNoHDCP);
    XCTAssertEqual(specifiedNoHDCP.hdcpLevel, LSPHDCPLevelNone);
    
    // Type-0 HDCP
    LSPStreamInfoTag *type0HDCP =[[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"HDCP-LEVEL" : @"TYPE-0"}];
    XCTAssertEqual(type0HDCP.hdcpLevel, LSPHDCPLevelType0);
}

- (void)testSerialization
{
    LSPStreamInfoTag *tag = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1,
                                                                           @"AVERAGE-BANDWIDTH":@9876,
                                                                           @"CODECS":@"a,b,c",
                                                                           @"RESOLUTION":[NSValue valueWithCGSize:CGSizeMake(123, 456)],
                                                                           @"FRAME-RATE":@(28.1),
                                                                           @"AUDIO":@"AAA",
                                                                           @"VIDEO":@"VVV",
                                                                           @"SUBTITLES":@"STSTST",
                                                                           @"CLOSED-CAPTIONS":@"CCCCCC",
                                                                           }];
    NSString *expectedTag = @"#EXT-X-STREAM-INF:BANDWIDTH=1,AVERAGE-BANDWIDTH=9876,CODECS=\"a,b,c\",RESOLUTION=123x456,FRAME-RATE=28.1,AUDIO=\"AAA\",VIDEO=\"VVV\",SUBTITLES=\"STSTST\",CLOSED-CAPTIONS=\"CCCCCC\"";
    XCTAssertEqualObjects([tag serialize], expectedTag);
}

- (void)testTagEquality
{
    LSPStreamInfoTag *tag1 = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1,
                                                                           @"AVERAGE-BANDWIDTH":@9876,
                                                                           @"CODECS":@"a,b,c",
                                                                           @"RESOLUTION":[NSValue valueWithCGSize:CGSizeMake(123, 456)],
                                                                           @"FRAME-RATE":@(28.1),
                                                                           @"AUDIO":@"AAA",
                                                                           @"VIDEO":@"VVV",
                                                                           @"SUBTITLES":@"STSTST",
                                                                           @"CLOSED-CAPTIONS":@"CCCCCC",
                                                                           }];
    LSPStreamInfoTag *tag2 = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1,
                                                                           @"AVERAGE-BANDWIDTH":@9876,
                                                                           @"CODECS":@"a,b,c",
                                                                           @"RESOLUTION":[NSValue valueWithCGSize:CGSizeMake(123, 456)],
                                                                           @"FRAME-RATE":@(28.1),
                                                                           @"AUDIO":@"AAA",
                                                                           @"VIDEO":@"VVV",
                                                                           @"SUBTITLES":@"STSTST",
                                                                           @"CLOSED-CAPTIONS":@"CCCCCC",
                                                                           }];
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPStreamInfoTag *tag3 = [[LSPStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @2,
                                                                            @"AVERAGE-BANDWIDTH":@9876,
                                                                            @"CODECS":@"a,b,c",
                                                                            @"RESOLUTION":[NSValue valueWithCGSize:CGSizeMake(123, 456)],
                                                                            @"FRAME-RATE":@(28.1),
                                                                            @"AUDIO":@"AAA",
                                                                            @"VIDEO":@"VVV",
                                                                            @"SUBTITLES":@"STSTST",
                                                                            @"CLOSED-CAPTIONS":@"CCCCCC",
                                                                            }];
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

#pragma mark - IFrame Stream Info Tag

@interface IFrameStreamInfoTagTests : AbstractTagTestCase

@end

@implementation IFrameStreamInfoTagTests

- (void)testBasicIFrameStreamInfoTag
{
    LSPIFrameStreamInfoTag *infoTag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{}];
    XCTAssertNil(infoTag, @"Info Tag needs bandwidth attribute");
    infoTag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @"1"}];
    
    XCTAssertNil(infoTag, @"Bandwidth needs to be a number");
    
    infoTag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1.2}];
    XCTAssertEqualObjects(infoTag.name, @"EXT-X-I-FRAME-STREAM-INF");
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1, @"Bandwidth will be rounded to an integer");
    
    infoTag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1);
    infoTag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1234568}];
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1234568);
}

- (void)testAverageBandwidth
{
    LSPIFrameStreamInfoTag *infoTag =[[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)0, @"When no bandwidth is present, value should be zero since we're not indicating a missing value otherwise");
    
    infoTag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AVERAGE-BANDWIDTH":@12}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)12);
    
    infoTag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AVERAGE-BANDWIDTH":@9876}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)9876);
}

- (void)testCodecs
{
    LSPIFrameStreamInfoTag *infoTag =[[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqualObjects(infoTag.codecs, @[]);
    
    NSArray *testCodecs = @[@"a", @"b", @"c"];
    
    infoTag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CODECS":@"a,b,c"}];
    XCTAssertEqualObjects(infoTag.codecs, testCodecs);
    
    infoTag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CODECS":@"single codec"}];
    XCTAssertEqualObjects(infoTag.codecs, @[@"single codec"]);
}

- (void)testResolution
{
    LSPIFrameStreamInfoTag *infoTag =[[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssert(CGSizeEqualToSize(infoTag.resolution, CGSizeZero));
    
    CGSize testSize = CGSizeMake(123, 456);
    infoTag =[[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"RESOLUTION":[NSValue valueWithCGSize:testSize]}];
    XCTAssert(CGSizeEqualToSize(infoTag.resolution, testSize));
}

- (void)testHDCP
{
    // No HDCP
    LSPIFrameStreamInfoTag *specifiedNoHDCP =[[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"HDCP-LEVEL" : @"NONE"}];
    LSPIFrameStreamInfoTag *unspecifiedHDCP =[[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqualObjects(unspecifiedHDCP, specifiedNoHDCP);
    XCTAssertEqual(specifiedNoHDCP.hdcpLevel, LSPHDCPLevelNone);
    
    // Type-0 HDCP
    LSPIFrameStreamInfoTag *type0HDCP =[[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"HDCP-LEVEL" : @"TYPE-0"}];
    XCTAssertEqual(type0HDCP.hdcpLevel, LSPHDCPLevelType0);
}

- (void)testSerialization
{
    LSPIFrameStreamInfoTag *tag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1,
                                                                                       @"AVERAGE-BANDWIDTH":@9876,
                                                                                       @"CODECS":@"a,b,c",
                                                                                       @"RESOLUTION":[NSValue valueWithCGSize:CGSizeMake(123, 456)],
                                                                                       }];
    NSString *expectedTag = @"#EXT-X-I-FRAME-STREAM-INF:BANDWIDTH=1,AVERAGE-BANDWIDTH=9876,CODECS=\"a,b,c\",RESOLUTION=123x456";
    XCTAssertEqualObjects([tag serialize], expectedTag);
}

- (void)testTagEquality
{
    LSPIFrameStreamInfoTag *tag1 = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1,
                                                                                        @"AVERAGE-BANDWIDTH":@9876,
                                                                                        @"CODECS":@"a,b,c",
                                                                                        @"RESOLUTION":[NSValue valueWithCGSize:CGSizeMake(123, 456)],
                                                                                        }];
    LSPIFrameStreamInfoTag *tag2 = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1,
                                                                                        @"AVERAGE-BANDWIDTH":@9876,
                                                                                        @"CODECS":@"a,b,c",
                                                                                        @"RESOLUTION":[NSValue valueWithCGSize:CGSizeMake(123, 456)],
                                                                                        }];
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPIFrameStreamInfoTag *tag3 = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @2,
                                                                                        @"AVERAGE-BANDWIDTH":@9876,
                                                                                        @"CODECS":@"a,b,c",
                                                                                        @"RESOLUTION":[NSValue valueWithCGSize:CGSizeMake(123, 456)],
                                                                                        }];
    
    XCTAssertNotEqualObjects(tag3, tag1);
}

@end

#pragma mark - Media Tag

@interface MediaTagTests : AbstractTagTestCase

@end

@implementation MediaTagTests

- (void)testMediaTagRequiredFields
{
    LSPMediaTag *tag = [[LSPMediaTag alloc] initWithAttributes:@{}];
    XCTAssertNil(tag, @"Media tags require a type");
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO"}];
    XCTAssertNil(tag, @"Media tags require a group-id");
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group"}];
    XCTAssertNil(tag, @"Media tags require a name");
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"NAME":@"rendition name"}];
    XCTAssertNil(tag, @"Media tags require a group-id");
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"GROUP-ID": @"group"}];
    XCTAssertNil(tag, @"Media tags require a name");
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertNil(tag, @"Media tags require a type");
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"NAME":@"rendition name"}];
    XCTAssertNil(tag, @"Media tags require a type");
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertTrue([tag isKindOfClass:[LSPMediaTag class]]);
    
    XCTAssertEqualObjects(tag.name, @"EXT-X-MEDIA");
    XCTAssertEqual(tag.type, LSPMediaTypeVideo);
    XCTAssertEqualObjects(tag.renditionName, @"rendition name");
    XCTAssertEqualObjects(tag.groupID, @"group");
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"AUDIO", @"GROUP-ID": @"xyz", @"NAME":@"abc"}];
    XCTAssertEqual(tag.type, LSPMediaTypeAudio);
    XCTAssertEqualObjects(tag.renditionName, @"abc");
    XCTAssertEqualObjects(tag.groupID, @"xyz");
}

- (void)testMediaTypeEnum
{
    LSPMediaTag *tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqual(tag.type, LSPMediaTypeVideo);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"AUDIO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqual(tag.type, LSPMediaTypeAudio);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"SUBTITLES", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqual(tag.type, LSPMediaTypeSubtitles);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"CLOSED-CAPTIONS", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqual(tag.type, LSPMediaTypeClosedCaptions);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"OTHER", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqual(tag.type, LSPMediaTypeUnknown); // Should this fail instead?
}

- (void)testLanguage
{
    LSPMediaTag *tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertNil(tag.language);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"LANGUAGE":@"en"}];
    XCTAssertEqualObjects(tag.language, @"en");
}

- (void)testAssociatedLanguage
{
    LSPMediaTag *tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertNil(tag.associatedLanguage);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"ASSOC-LANGUAGE":@"en"}];
    XCTAssertEqualObjects(tag.associatedLanguage, @"en");
}

- (void)testURI
{
    LSPMediaTag *tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertNil(tag.uri);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"URI":@"../media.m3u"}];
    XCTAssertTrue([tag.uri isKindOfClass:[NSURL class]]);
    XCTAssertEqualObjects(tag.uri, [NSURL URLWithString:@"../media.m3u"]); // This might be made more stringent.
}

- (void)testDefault
{
    LSPMediaTag *tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertFalse(tag.defaultRendition);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"DEFAULT":@"YES"}];
    XCTAssertTrue(tag.defaultRendition);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"DEFAULT":@"NO"}];
    XCTAssertFalse(tag.defaultRendition);
}

- (void)testAutoselect
{
    LSPMediaTag *tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertFalse(tag.autoselect);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"AUTOSELECT":@"YES"}];
    XCTAssertTrue(tag.autoselect);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"AUTOSELECT":@"NO"}];
    XCTAssertFalse(tag.autoselect);
}

- (void)testForced
{
    LSPMediaTag *tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertFalse(tag.forced);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"FORCED":@"YES"}];
    XCTAssertTrue(tag.forced);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"FORCED":@"NO"}];
    XCTAssertFalse(tag.forced);
}

- (void)testInstreamID
{
    LSPMediaTag *tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertNil(tag.instreamID);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"INSTREAM-ID":@"Something?"}];
    XCTAssertEqualObjects(tag.instreamID, @"Something?");
}

- (void)testCharacteristics
{
    LSPMediaTag *tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqualObjects(tag.characteristics, @[]);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"CHARACTERISTICS":@"one"}];
    NSArray *one = @[@"one"];
    XCTAssertEqualObjects(tag.characteristics, one);
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"CHARACTERISTICS":@"one,two,three"}];
    NSArray *three = @[@"one", @"two", @"three"];
    XCTAssertEqualObjects(tag.characteristics, three);
}

- (void)testSerialization
{
    LSPMediaTag *tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"AUDIO",
                                                                 @"GROUP-ID":@"aud1",
                                                                 @"LANGUAGE":@"eng",
                                                                 @"NAME":@"English",
                                                                 @"AUTOSELECT":@"YES",
                                                                 @"DEFAULT":@"YES",
                                                                 @"URI":@"a1/prog_index.m3u8"}];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID=\"aud1\",LANGUAGE=\"eng\",NAME=\"English\",DEFAULT=YES,AUTOSELECT=YES,URI=\"a1/prog_index.m3u8\"");
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE" : @"CLOSED-CAPTIONS",
                                                    @"GROUP-ID" : @"cc1",
                                                    @"NAME" : @"English",
                                                    @"LANGUAGE" : @"eng",
                                                    @"DEFAULT" : @"YES",
                                                    @"AUTOSELECT" : @"YES",
                                                    @"INSTREAM-ID" : @"CC1"}];
    
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-MEDIA:TYPE=CLOSED-CAPTIONS,GROUP-ID=\"cc1\",LANGUAGE=\"eng\",NAME=\"English\",DEFAULT=YES,AUTOSELECT=YES,INSTREAM-ID=\"CC1\"");
    
    tag = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE" : @"SUBTITLES",
                                                    @"GROUP-ID" : @"sub1",
                                                    @"NAME" : @"English",
                                                    @"LANGUAGE" : @"eng",
                                                    @"DEFAULT" : @"YES",
                                                    @"AUTOSELECT" : @"YES",
                                                    @"FORCED" : @"YES",
                                                    @"URI" : @"s1/eng/prog_index.m3u8"}];
    
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID=\"sub1\",LANGUAGE=\"eng\",NAME=\"English\",DEFAULT=YES,AUTOSELECT=YES,FORCED=YES,URI=\"s1/eng/prog_index.m3u8\"");
}

- (void)testTagEquality
{
    LSPMediaTag *tag1 = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"AUDIO",
                                                                  @"GROUP-ID":@"aud1",
                                                                  @"LANGUAGE":@"eng",
                                                                  @"NAME":@"English",
                                                                  @"AUTOSELECT":@"YES",
                                                                  @"DEFAULT":@"YES",
                                                                  @"URI":@"a1/prog_index.m3u8"}];
    LSPMediaTag *tag2 = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE":@"AUDIO",
                                                                  @"GROUP-ID":@"aud1",
                                                                  @"LANGUAGE":@"eng",
                                                                  @"NAME":@"English",
                                                                  @"AUTOSELECT":@"YES",
                                                                  @"DEFAULT":@"YES",
                                                                  @"URI":@"a1/prog_index.m3u8"}];
    
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPMediaTag *tag3 = [[LSPMediaTag alloc] initWithAttributes:@{@"TYPE" : @"CLOSED-CAPTIONS",
                                                                  @"GROUP-ID" : @"cc1",
                                                                  @"NAME" : @"English",
                                                                  @"LANGUAGE" : @"eng",
                                                                  @"DEFAULT" : @"YES",
                                                                  @"AUTOSELECT" : @"YES",
                                                                  @"INSTREAM-ID" : @"CC1"}];
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

#pragma mark - Session Data Tag

@interface SessionDataTests : AbstractTagTestCase

@end

@implementation SessionDataTests

- (void)testSessionDataTagRequiredFields
{
    LSPSessionDataTag *tag = [[LSPSessionDataTag alloc] initWithAttributes:@{}];
    XCTAssertNil(tag, @"Session Data tags require a data id");
    
    tag = [[LSPSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value"}];
    XCTAssertNil(tag, @"Session data requires either a VALUE or a URI");
    
    
    tag = [[LSPSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"VALUE":@"session data value"}];
    XCTAssertEqualObjects(tag.value, @"session data value");
    
    tag = [[LSPSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"URI":@"session/data/path.json"}];
    XCTAssertEqualObjects(tag.uri, [NSURL URLWithString:@"session/data/path.json"]);
}

- (void)testLanguage
{
    LSPSessionDataTag *tag = [[LSPSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"VALUE":@"session data value"}];
    XCTAssertNil(tag.language);
    
    tag = [[LSPSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"VALUE":@"session data value", @"LANGUAGE":@"en"}];
    XCTAssertEqualObjects(tag.language, @"en");
}

- (void)testSerialization
{
    LSPSessionDataTag *tag = [[LSPSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"VALUE":@"session data value"}];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-SESSION-DATA:DATA-ID=\"data id value\",VALUE=\"session data value\"");
    
    tag = [[LSPSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"URI":@"session/data/path.json"}];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-SESSION-DATA:DATA-ID=\"data id value\",URI=\"session/data/path.json\"");
}

- (void)testTagEquality
{
    LSPSessionDataTag *tag1 = [[LSPSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"VALUE":@"session data value"}];
    LSPSessionDataTag *tag2 = [[LSPSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"VALUE":@"session data value"}];
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPSessionDataTag *tag3 = [[LSPSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"URI":@"session/data/path.json"}];
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

#pragma mark - Session Key Tag

@interface SessionKeyTests : AbstractTagTestCase

@end

@implementation SessionKeyTests

- (void)testSessionKeyRequiredFields
{
    LSPSessionKeyTag *tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{}];
    XCTAssertNil(tag, @"METHOD is required");
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertEqualObjects(tag.name, @"EXT-X-SESSION-KEY");
    XCTAssertEqual(tag.method, LSPEncryptionMethodNone);
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"AES-128"}];
    XCTAssertNil(tag,@"URI is required if method is not none");
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"SAMPLE-AES"}];
    XCTAssertNil(tag,@"URI is required if method is not none");
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"AES-128", @"URI":@"http://example.com/key"}];
    XCTAssertEqualObjects(tag.name, @"EXT-X-SESSION-KEY");
    XCTAssertEqual(tag.method, LSPEncryptionMethodAES128);
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"SAMPLE-AES", @"URI":@"http://example.com/key"}];
    XCTAssertEqualObjects(tag.name, @"EXT-X-SESSION-KEY");
    XCTAssertEqual(tag.method, LSPEncryptionMethodSampleAES);
}

- (void)testKeyFormat
{
    LSPSessionKeyTag *tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertEqualObjects(tag.keyFormat, @"identity");
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMAT":@2}];
    XCTAssertEqualObjects(tag.keyFormat, @"identity", @"Incompatible class for quoted string key format will be ignored and have default value");
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMAT":@"SomeKeyFormat"}];
    XCTAssertEqualObjects(tag.keyFormat, @"SomeKeyFormat");
}

- (void)testKeyFormatVersions
{
    LSPSessionKeyTag *tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[]);
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : @"1"}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[@1]);

    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : @1}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[]);
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : @"1/2/3/4"}];
    NSArray *oneToFourArray = @[@1, @2, @3, @4];
    XCTAssertEqualObjects(tag.keyFormatVersions, oneToFourArray);
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : oneToFourArray}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[]);
}

- (void)testInitializationVector
{
    LSPSessionKeyTag *tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertNil(tag.initializationVector);
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"IV":@"1234567890abcdef"}];
    XCTAssertEqualObjects(tag.initializationVector, @"1234567890abcdef");
    
    tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"IV":@1324}];
    XCTAssertNil(tag.initializationVector);
}

- (void)testSerialization
{
    LSPSessionKeyTag *tag = [[LSPSessionKeyTag alloc] initWithAttributes:@{
                                                                           @"METHOD":@"AES-128",
                                                                           @"URI":@"s1/keys/k1",
                                                                           @"KEYFORMAT":@"key-format",
                                                                           @"KEYFORMATVERSIONS":@"1/2/3/4",
                                                                           }];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-SESSION-KEY:METHOD=AES-128,URI=\"s1/keys/k1\",KEYFORMAT=\"key-format\",KEYFORMATVERSIONS=\"1/2/3/4\"");
}

- (void)testTagEquality
{
    LSPSessionKeyTag *tag1 = [[LSPSessionKeyTag alloc] initWithAttributes:@{
                                                                            @"METHOD":@"AES-128",
                                                                            @"URI":@"s1/keys/k1",
                                                                            @"KEYFORMAT":@"key-format",
                                                                            @"KEYFORMATVERSIONS":@"1/2/3/4",
                                                                            }];
    LSPSessionKeyTag *tag2 = [[LSPSessionKeyTag alloc] initWithAttributes:@{
                                                                            @"METHOD":@"AES-128",
                                                                            @"URI":@"s1/keys/k1",
                                                                            @"KEYFORMAT":@"key-format",
                                                                            @"KEYFORMATVERSIONS":@"1/2/3/4",
                                                                            }];
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPSessionKeyTag *tag3 = [[LSPSessionKeyTag alloc] initWithAttributes:@{
                                                                            @"METHOD":@"AES-128",
                                                                            @"URI":@"s1/keys/k2",
                                                                            @"KEYFORMAT":@"key-format",
                                                                            @"KEYFORMATVERSIONS":@"1/2/3/4",
                                                                            }];
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

#pragma mark - Start Tag

@interface StartTagTests : AbstractTagTestCase

@end

@implementation StartTagTests

- (void)testRequiredFields
{
    LSPStartTag *tag = [[LSPStartTag alloc] initWithAttributes:@{}];
    XCTAssertNil(tag, @"TIME-OFFSET is required");
    
    tag = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5)}];
    XCTAssertNotNil(tag);
    XCTAssertTrue([tag isKindOfClass:[LSPStartTag class]]);
    XCTAssertEqualObjects(tag.name, @"EXT-X-START");
    XCTAssertEqualWithAccuracy(tag.timeOffset, 1.5, 0.0001);

    tag = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@"1.5"}];
    XCTAssertNil(tag, @"TIME-OFFSET must be a number");
}

- (void)testPrecise
{
    LSPStartTag *tag = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5)}];
    XCTAssertFalse(tag.precise);
    
    tag = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5), @"PRECISE":@YES}];
    XCTAssertFalse(tag.precise, @"PRECISE needs to be a string");
    
    tag = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5), @"PRECISE":@"NO"}];
    XCTAssertFalse(tag.precise);
    
    tag = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5), @"PRECISE":@"YES"}];
    XCTAssertTrue(tag.precise);
}

- (void)testSerialization
{
    LSPStartTag *tag = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5)}];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-START:TIME-OFFSET=1.5");
    
    tag = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5), @"PRECISE":@"NO"}];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-START:TIME-OFFSET=1.5");
    
    tag = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5), @"PRECISE":@"YES"}];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-START:TIME-OFFSET=1.5,PRECISE=YES");
}

- (void)testTagEquality
{
    LSPStartTag *tag1 = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5)}];
    
    LSPStartTag *tag2 = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5), @"PRECISE":@"NO"}];
    
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPStartTag *tag3 = [[LSPStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5), @"PRECISE":@"YES"}];
    
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

#pragma mark - Info Tag

@interface InfoTagTests : AbstractTagTestCase

@end

@implementation InfoTagTests

- (void)testName
{
    LSPInfoTag *tag = [[LSPInfoTag alloc] initWithDuration:1.0 title:nil];
    XCTAssertEqualObjects([tag name], @"EXTINF");
}

- (void)testDuration
{
    LSPInfoTag *tag = [[LSPInfoTag alloc] initWithDuration:1.0 title:nil];
    XCTAssertEqual(tag.duration, 1.0);
    
    tag = [[LSPInfoTag alloc] initWithDuration:3.0 title:nil];
    XCTAssertEqual(tag.duration, 3.0);
}

- (void)testTitle
{
    LSPInfoTag *tag = [[LSPInfoTag alloc] initWithDuration:1.0 title:nil];
    XCTAssertNil(tag.title);
    
    tag = [[LSPInfoTag alloc] initWithDuration:1.0 title:@"title"];
    XCTAssertEqualObjects(tag.title, @"title");
    
    NSMutableString *s = [@"mutable" mutableCopy];
    tag = [[LSPInfoTag alloc] initWithDuration:1.0 title:s];
    [s appendString:@" string"];
    XCTAssertEqualObjects(tag.title, @"mutable");
}

- (void)testSerialization
{
    LSPInfoTag *tag = [[LSPInfoTag alloc] initWithDuration:1.0 title:nil];
    XCTAssertEqualObjects([tag serialize], @"#EXTINF:1,");
    
    tag = [[LSPInfoTag alloc] initWithDuration:3.0 title:@"serialize"];
    XCTAssertEqualObjects([tag serialize], @"#EXTINF:3,serialize");
    
    tag = [[LSPInfoTag alloc] initWithDuration:3.2 title:@"serialize"];
    XCTAssertEqualObjects([tag serialize], @"#EXTINF:3.2,serialize");
}

- (void)testTagEquality
{
    LSPInfoTag *tag1 = [[LSPInfoTag alloc] initWithDuration:1.0 title:nil];
    LSPInfoTag *tag2 = [[LSPInfoTag alloc] initWithDuration:1.0 title:nil];
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPInfoTag *tag3 = [[LSPInfoTag alloc] initWithDuration:1.0 title:@"title"];
    LSPInfoTag *tag4 = [[LSPInfoTag alloc] initWithDuration:1.0 title:@"title"];
    XCTAssertEqualObjects(tag3, tag4);
    
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

#pragma mark - Map Tag

@interface MapTagTests : AbstractTagTestCase

@end

@implementation MapTagTests

- (void)testName
{
    LSPMapTag *tag = [[LSPMapTag alloc] initWithURI:[NSURL URLWithString:@"http://www.example.com"] byteRange:nil];
    XCTAssertEqualObjects(tag.name, @"EXT-X-MAP");
}

- (void)testURI
{
    NSURL *uri = [NSURL URLWithString:@"http://www.example.com"];
    LSPMapTag *tag = [[LSPMapTag alloc] initWithURI:uri byteRange:nil];
    XCTAssertEqualObjects(tag.uri, uri);
}

- (void)testByteRange
{
    NSURL *uri = [NSURL URLWithString:@"http://www.example.com"];
    LSPByteRange *byteRange = [[LSPByteRange alloc] init];
    LSPMapTag *tag = [[LSPMapTag alloc] initWithURI:uri byteRange:byteRange];
    XCTAssertEqualObjects(tag.byteRange, byteRange);
}

- (void)testAttributeTypes
{
    XCTAssertTrue([LSPMapTag conformsToProtocol:@protocol(LSPAttributedTag
                                                          )]);
    XCTAssertEqual([[LSPMapTag class] attributeTypeForKey:@"URI"], LSPAttributeTypeQuotedString);
    XCTAssertEqual([[LSPMapTag class] attributeTypeForKey:@"BYTERANGE"], LSPAttributeTypeQuotedString);
}

- (void)testSerialization
{
    LSPMapTag *tag = [[LSPMapTag alloc] initWithURI:[NSURL URLWithString:@"http://www.example.com/map/url"] byteRange:[[LSPByteRange alloc] initWithLength:123 offset:4567]];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-MAP:URI=\"http://www.example.com/map/url\",BYTERANGE=123@4567");
}

- (void)testTagEquality
{
    LSPMapTag *tag1 = [[LSPMapTag alloc] initWithURI:[NSURL URLWithString:@"http://www.example.com/map/url"] byteRange:[[LSPByteRange alloc] initWithLength:123 offset:4567]];
    LSPMapTag *tag2 = [[LSPMapTag alloc] initWithURI:[NSURL URLWithString:@"http://www.example.com/map/url"] byteRange:[[LSPByteRange alloc] initWithLength:123 offset:4567]];
    
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPMapTag *tag3 = [[LSPMapTag alloc] initWithURI:[NSURL URLWithString:@"http://www.example.com/map/other"] byteRange:[[LSPByteRange alloc] initWithLength:123 offset:4567]];
    
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

#pragma mark - Byte Range Tag

@interface ByteRangeTagTests : AbstractTagTestCase

@end

@implementation ByteRangeTagTests

- (void)testName
{
    LSPByteRange *byteRange = [[LSPByteRange alloc] init];
    LSPByteRangeTag *tag = [[LSPByteRangeTag alloc] initWithByteRange:byteRange];
    XCTAssertEqualObjects(tag.name, @"EXT-X-BYTERANGE");
}

- (void)testByteRange
{
    LSPByteRange *byteRange = [[LSPByteRange alloc] init];
    LSPByteRangeTag *tag = [[LSPByteRangeTag alloc] initWithByteRange:byteRange];
    XCTAssertEqualObjects(tag.byteRange, byteRange);
}

- (void)testSerialization
{
    LSPByteRange *byteRange = [[LSPByteRange alloc] init];
    XCTAssertEqualObjects([byteRange serialize], @"0");
    LSPByteRangeTag *tag = [[LSPByteRangeTag alloc] initWithByteRange:byteRange];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-BYTERANGE:0");
    
    byteRange = [[LSPByteRange alloc] initWithString:@"7890"];
    XCTAssertEqualObjects([byteRange serialize], @"7890");
    tag = [[LSPByteRangeTag alloc] initWithByteRange:byteRange];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-BYTERANGE:7890");
    
    byteRange = [[LSPByteRange alloc] initWithLength:1204 offset:80];
    XCTAssertEqualObjects([byteRange serialize], @"1204@80");
    tag = [[LSPByteRangeTag alloc] initWithByteRange:byteRange];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-BYTERANGE:1204@80");
}

- (void)testTagEquality
{
    LSPByteRange *byteRange = [[LSPByteRange alloc] initWithString:@"7890"];
    LSPByteRangeTag *tag1 = [[LSPByteRangeTag alloc] initWithByteRange:byteRange];
    
    byteRange = [[LSPByteRange alloc] initWithLength:1204 offset:80];
    LSPByteRangeTag *tag2 = [[LSPByteRangeTag alloc] initWithByteRange:byteRange];
    XCTAssertNotEqualObjects(tag1, tag2);
    
    byteRange = [[LSPByteRange alloc] initWithLength:1204 offset:80];
    LSPByteRangeTag *tag3 = [[LSPByteRangeTag alloc] initWithByteRange:byteRange];
    XCTAssertEqualObjects(tag2, tag3);
}

@end

#pragma mark - Key Tag

@interface KeyTests : AbstractTagTestCase

@end

@implementation KeyTests

- (void)testSessionKeyRequiredFields
{
    LSPKeyTag *tag = [[LSPKeyTag alloc] initWithAttributes:@{}];
    XCTAssertNil(tag, @"METHOD is required");
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertEqualObjects(tag.name, @"EXT-X-KEY");
    XCTAssertEqual(tag.method, LSPEncryptionMethodNone);
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"AES-128"}];
    XCTAssertNil(tag,@"URI is required if method is not none");
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"SAMPLE-AES"}];
    XCTAssertNil(tag,@"URI is required if method is not none");
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"AES-128", @"URI":@"http://example.com/key"}];
    XCTAssertEqualObjects(tag.name, @"EXT-X-KEY");
    XCTAssertEqual(tag.method, LSPEncryptionMethodAES128);
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"SAMPLE-AES", @"URI":@"http://example.com/key"}];
    XCTAssertEqualObjects(tag.name, @"EXT-X-KEY");
    XCTAssertEqual(tag.method, LSPEncryptionMethodSampleAES);
}

- (void)testKeyFormat
{
    LSPKeyTag *tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertEqualObjects(tag.keyFormat, @"identity");
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMAT":@2}];
    XCTAssertEqualObjects(tag.keyFormat, @"identity", @"Incompatible class for quoted string key format will be ignored and have default value");
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMAT":@"SomeKeyFormat"}];
    XCTAssertEqualObjects(tag.keyFormat, @"SomeKeyFormat");
}

- (void)testKeyFormatVersions
{
    LSPKeyTag *tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[]);
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : @"1"}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[@1]);
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : @1}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[]);
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : @"1/2/3/4"}];
    NSArray *oneToFourArray = @[@1, @2, @3, @4];
    XCTAssertEqualObjects(tag.keyFormatVersions, oneToFourArray);
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : oneToFourArray}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[]);
}

- (void)testInitializationVector
{
    LSPKeyTag *tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertNil(tag.initializationVector);
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"IV":@"1234567890abcdef"}];
    XCTAssertEqualObjects(tag.initializationVector, @"1234567890abcdef");
    
    tag = [[LSPKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"IV":@1324}];
    XCTAssertNil(tag.initializationVector);
}

- (void)testSerialization
{
    LSPKeyTag *tag = [[LSPKeyTag alloc] initWithAttributes:@{
                                                             @"METHOD":@"AES-128",
                                                             @"URI":@"s1/keys/k1",
                                                             @"KEYFORMAT":@"key-format",
                                                             @"KEYFORMATVERSIONS":@"1/2/3/4",
                                                             }];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-KEY:METHOD=AES-128,URI=\"s1/keys/k1\",KEYFORMAT=\"key-format\",KEYFORMATVERSIONS=\"1/2/3/4\"");
}

- (void)testTagEquality
{
    LSPKeyTag *tag1 = [[LSPKeyTag alloc] initWithAttributes:@{
                                                             @"METHOD":@"AES-128",
                                                             @"URI":@"s1/keys/k1",
                                                             @"KEYFORMAT":@"key-format",
                                                             @"KEYFORMATVERSIONS":@"1/2/3/4",
                                                             }];
    LSPKeyTag *tag2 = [[LSPKeyTag alloc] initWithAttributes:@{
                                                              @"METHOD":@"AES-128",
                                                              @"URI":@"s1/keys/k1",
                                                              @"KEYFORMAT":@"key-format",
                                                              @"KEYFORMATVERSIONS":@"1/2/3/4",
                                                              }];
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPKeyTag *tag3 = [[LSPKeyTag alloc] initWithAttributes:@{
                                                              @"METHOD":@"AES-128",
                                                              @"URI":@"s1/keys/k3",
                                                              @"KEYFORMAT":@"key-format",
                                                              @"KEYFORMATVERSIONS":@"1/2/3/4",
                                                              }];
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

#pragma mark - Program Date Time Tag

@interface ProgramDateTimeTagTests : AbstractTagTestCase

@end

@implementation ProgramDateTimeTagTests

- (void)testName
{
    NSDate *date = [NSDate date];
    LSPProgramDateTimeTag *tag = [[LSPProgramDateTimeTag alloc] initWithDate:date];
    XCTAssertEqualObjects(tag.name, @"EXT-X-PROGRAM-DATE-TIME");
}

- (void)testDate
{
    NSDate *date = [NSDate date];
    LSPProgramDateTimeTag *tag = [[LSPProgramDateTimeTag alloc] initWithDate:date];
    XCTAssertEqualObjects(tag.name, @"EXT-X-PROGRAM-DATE-TIME");
    XCTAssertEqualObjects(tag.date, date);
}

- (void)testSerialization
{
    // TODO
}

- (void)testTagEquality
{
    // TODO
}

@end

#pragma mark - Playlist Type Tag

@interface PlaylistTypeTagTests : AbstractTagTestCase

@end

@implementation PlaylistTypeTagTests

- (void)testName
{
    LSPPlaylistTypeTag *tag = [[LSPPlaylistTypeTag alloc] init];
    XCTAssertEqualObjects(tag.name, @"EXT-X-PLAYLIST-TYPE");
}

- (void)testType
{
    LSPPlaylistTypeTag *tag = [[LSPPlaylistTypeTag alloc] initWithEnumeratedString:@"VOD"];
    XCTAssertEqual(tag.type, LSPPlaylistTypeVOD);
    tag = [[LSPPlaylistTypeTag alloc] initWithType:LSPPlaylistTypeVOD];
    XCTAssertEqual(tag.type, LSPPlaylistTypeVOD);
    
    tag = [[LSPPlaylistTypeTag alloc] initWithEnumeratedString:@"EVENT"];
    XCTAssertEqual(tag.type, LSPPlaylistTypeEvent);
    tag = [[LSPPlaylistTypeTag alloc] initWithType:LSPPlaylistTypeEvent];
    XCTAssertEqual(tag.type, LSPPlaylistTypeEvent);

    tag = [[LSPPlaylistTypeTag alloc] initWithEnumeratedString:@"COD"];
    XCTAssertNil(tag);
}

- (void)testSerialization
{
    LSPPlaylistTypeTag *tag = [[LSPPlaylistTypeTag alloc] initWithEnumeratedString:@"VOD"];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-PLAYLIST-TYPE:VOD");
    tag = [[LSPPlaylistTypeTag alloc] initWithType:LSPPlaylistTypeVOD];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-PLAYLIST-TYPE:VOD");
    
    tag = [[LSPPlaylistTypeTag alloc] initWithEnumeratedString:@"EVENT"];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-PLAYLIST-TYPE:EVENT");
    tag = [[LSPPlaylistTypeTag alloc] initWithType:LSPPlaylistTypeEvent];
    XCTAssertEqual(tag.type, LSPPlaylistTypeEvent);
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-PLAYLIST-TYPE:EVENT");
}

- (void)testTagEquality
{
    LSPPlaylistTypeTag *tag1 = [[LSPPlaylistTypeTag alloc] initWithType:LSPPlaylistTypeVOD];
    LSPPlaylistTypeTag *tag2 = [[LSPPlaylistTypeTag alloc] initWithEnumeratedString:@"VOD"];
    
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPPlaylistTypeTag *tag3 = [[LSPPlaylistTypeTag alloc] initWithType:LSPPlaylistTypeEvent];
    
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

@interface TargetDurationTagTests : AbstractTagTestCase

@end

@implementation TargetDurationTagTests

- (void)testSerialization
{
    LSPTargetDurationTag *tag = [[LSPTargetDurationTag alloc] initWithIntegerAttribute:1];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-TARGETDURATION:1");
    
    tag = [[LSPTargetDurationTag alloc] initWithIntegerAttribute:2];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-TARGETDURATION:2");
    
    tag = [[LSPTargetDurationTag alloc] initWithIntegerAttribute:3];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-TARGETDURATION:3");
}

- (void)testTagEquality
{
    LSPTargetDurationTag *tag1 = [[LSPTargetDurationTag alloc] initWithIntegerAttribute:1];
    LSPTargetDurationTag *tag2 = [[LSPTargetDurationTag alloc] initWithIntegerAttribute:1];
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPTargetDurationTag *tag3 = [[LSPTargetDurationTag alloc] initWithIntegerAttribute:2];
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

@interface DiscontinuitySequenceTagTests : AbstractTagTestCase

@end

@implementation DiscontinuitySequenceTagTests

- (void)testSerialization
{
    LSPDiscontinuitySequenceTag *tag = [[LSPDiscontinuitySequenceTag alloc] initWithIntegerAttribute:1];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-DISCONTINUITY-SEQUENCE:1");
    
    tag = [[LSPDiscontinuitySequenceTag alloc] initWithIntegerAttribute:2];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-DISCONTINUITY-SEQUENCE:2");
    
    tag = [[LSPDiscontinuitySequenceTag alloc] initWithIntegerAttribute:3];
    XCTAssertEqualObjects([tag serialize], @"#EXT-X-DISCONTINUITY-SEQUENCE:3");
}

- (void)testTagEquality
{
    LSPDiscontinuitySequenceTag *tag1 = [[LSPDiscontinuitySequenceTag alloc] initWithIntegerAttribute:1];
    LSPDiscontinuitySequenceTag *tag2 = [[LSPDiscontinuitySequenceTag alloc] initWithIntegerAttribute:1];
    XCTAssertEqualObjects(tag1, tag2);
    
    LSPDiscontinuitySequenceTag *tag3 = [[LSPDiscontinuitySequenceTag alloc] initWithIntegerAttribute:2];
    XCTAssertNotEqualObjects(tag1, tag3);
}

@end

