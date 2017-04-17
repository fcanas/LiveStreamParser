//
//  TagTests.m
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "LSPTag.h"

@import XCTest;

@interface TagTests : XCTestCase

@end

@implementation TagTests

- (void)testTagNameEquality {
    LSPBasicTag *tag1 = [[LSPBasicTag alloc] initWithName:@"EXTM3U"];
    LSPBasicTag *tag2 = [[LSPBasicTag alloc] initWithName:@"EXT-X-VERSION"];
    LSPBasicTag *tag3 = [[LSPBasicTag alloc] initWithName:@"EXTM3U"];
    
    XCTAssertNotEqualObjects(tag1.name, tag2.name);
    XCTAssertEqualObjects(tag1.name, tag3.name);
}

- (void)testVersionTag
{
    LSPVersionTag *versionTag = [[LSPVersionTag alloc] init];
    XCTAssert(versionTag.version == 1);
    versionTag = [[LSPVersionTag alloc] initWithIntegerAttribute:3];
    XCTAssert(versionTag.version == 3);
    versionTag = [[LSPVersionTag alloc] initWithIntegerAttribute:0];
    XCTAssert(versionTag.version == 1);
}

@end

@interface URITagTests : XCTestCase

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

@end

@interface StreamInfoTagTests : XCTestCase

@end

@implementation StreamInfoTagTests

#pragma mark - Stream Info Tag

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

@end

@interface IFrameStreamInfoTagTests : XCTestCase

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

- (void)testFrameRate
{
    LSPIFrameStreamInfoTag *infoTag =[[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqual(infoTag.frameRate, (NSUInteger)0, @"When no framerate is present, value should be zero since we're not indicating a missing value otherwise");
    
    infoTag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"FRAME-RATE":@24}];
    XCTAssertEqual(infoTag.frameRate, (double)24);
    
    infoTag = [[LSPIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"FRAME-RATE":@65}];
    XCTAssertEqual(infoTag.frameRate, (double)65);
}

@end

@interface MediaTagTests : XCTestCase

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

@end

@interface SessionDataTests : XCTestCase

@end

@implementation SessionDataTests

- (void)testSessionDataTagRequiredFields
{
    LSPSessionDataTag *tag = [[LSPSessionDataTag alloc] initWithAttributes:@{}];
    XCTAssertNil(tag, @"Session Data tags require a data id");
    
    tag = [[LSPSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value"}];
    XCTAssertNil(tag, @"Session data requires euther a VALUE or a URI");
    
    
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

@end

@interface SessionKeyTests : XCTestCase

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

@end

@interface StartTagTests : XCTestCase

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

@end

@interface InfoTagTests : XCTestCase

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

@end

@interface MapTagTests : XCTestCase

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

@end

@interface ByteRangeTagTests : XCTestCase

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

@end


@interface KeyTests : XCTestCase

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

@end

@interface ProgramDateTimeTagTests : XCTestCase

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

@end

@interface PlaylistTypeTagTests : XCTestCase

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
    
    tag = [[LSPPlaylistTypeTag alloc] initWithEnumeratedString:@"EVENT"];
    XCTAssertEqual(tag.type, LSPPlaylistTypeEvent);

    tag = [[LSPPlaylistTypeTag alloc] initWithEnumeratedString:@"COD"];
    XCTAssertNil(tag);
}

@end


