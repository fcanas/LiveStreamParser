//
//  TagTests.m
//  FCHLSParser
//
//  Created by Fabian Canas on 2/25/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "FFCTag.h"

@import XCTest;

@interface TagTests : XCTestCase

@end

@implementation TagTests

- (void)testTagNameEquality {
    FFCBasicTag *tag1 = [[FFCBasicTag alloc] initWithName:@"EXTM3U"];
    FFCBasicTag *tag2 = [[FFCBasicTag alloc] initWithName:@"EXT-X-VERSION"];
    FFCBasicTag *tag3 = [[FFCBasicTag alloc] initWithName:@"EXTM3U"];
    
    XCTAssertNotEqualObjects(tag1.name, tag2.name);
    XCTAssertEqualObjects(tag1.name, tag3.name);
}

- (void)testVersionTag
{
    FFCVersionTag *versionTag = [[FFCVersionTag alloc] init];
    XCTAssert(versionTag.version == 1);
    versionTag = [[FFCVersionTag alloc] initWithIntegerAttribute:3];
    XCTAssert(versionTag.version == 3);
    versionTag = [[FFCVersionTag alloc] initWithIntegerAttribute:0];
    XCTAssert(versionTag.version == 1);
}

@end

@interface URITagTests : XCTestCase

@end

@implementation URITagTests

- (void)testURITag
{
    FFCURITag *tag = [[FFCURITag alloc] initWithURIString:@" "];
    XCTAssertNil(tag, @"Must be initialized with a string that could be a url");
    
    tag = [[FFCURITag alloc] initWithURIString:@"http://www.example.com"];
    XCTAssertTrue([tag isKindOfClass:[FFCURITag class]]);
    XCTAssertEqualObjects(tag.uri, [NSURL URLWithString:@"http://www.example.com"]);
}

@end

@interface StreamInfoTagTests : XCTestCase

@end

@implementation StreamInfoTagTests

#pragma mark - Stream Info Tag

- (void)testBasicStreamInfoTag
{
    FFCStreamInfoTag *infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{}];
    XCTAssertNil(infoTag, @"Info Tag needs bandwidth attribute");
    infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @"1"}];
    XCTAssertNil(infoTag, @"Bandwidth needs to be a number");
    infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1.2}];
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1, @"Bandwidth will be rounded to an integer");
    
    infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqualObjects(infoTag.name, @"EXT-X-STREAM-INF");
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1);
    infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1234568}];
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1234568);
}

- (void)testAverageBandwidth
{
    FFCStreamInfoTag *infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)0, @"When no bandwidth is present, value should be zero since we're not indicating a missing value otherwise");
    
    infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AVERAGE-BANDWIDTH":@12}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)12);
    
    infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AVERAGE-BANDWIDTH":@9876}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)9876);
}

- (void)testCodecs
{
    FFCStreamInfoTag *infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqualObjects(infoTag.codecs, @[]);
    
    NSArray *testCodecs = @[@"a", @"b", @"c"];
    
    infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CODECS":@"a,b,c"}];
    XCTAssertEqualObjects(infoTag.codecs, testCodecs);
    
    infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CODECS":@"single codec"}];
    XCTAssertEqualObjects(infoTag.codecs, @[@"single codec"]);
}

- (void)testResolution
{
    FFCStreamInfoTag *infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssert(CGSizeEqualToSize(infoTag.resolution, CGSizeZero));
    
    CGSize testSize = CGSizeMake(123, 456);
    infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"RESOLUTION":[NSValue valueWithCGSize:testSize]}];
    XCTAssert(CGSizeEqualToSize(infoTag.resolution, testSize));
}

- (void)testFrameRate
{
    FFCStreamInfoTag *infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqual(infoTag.frameRate, (NSUInteger)0, @"When no framerate is present, value should be zero since we're not indicating a missing value otherwise");
    
    infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"FRAME-RATE":@24}];
    XCTAssertEqual(infoTag.frameRate, (double)24);
    
    infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"FRAME-RATE":@65}];
    XCTAssertEqual(infoTag.frameRate, (double)65);
    
    infoTag = [[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"FRAME-RATE":@(-24.0)}];
    XCTAssertEqual(infoTag.frameRate, 0, @"Frame rate must be positive");
}

- (void)testAudio
{
    FFCStreamInfoTag *infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertNil(infoTag.audio);
    
    infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AUDIO":@1}];
    XCTAssertNil(infoTag.audio, @"audio attribute must be a string");
    
    infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AUDIO":@"audio group"}];
    XCTAssertEqualObjects(infoTag.audio, @"audio group");
}

- (void)testVideo
{
    FFCStreamInfoTag *infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertNil(infoTag.video);
    
    infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"VIDEO":@1}];
    XCTAssertNil(infoTag.video, @"video attribute must be a string");
    
    infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"VIDEO":@"video group"}];
    XCTAssertEqualObjects(infoTag.video, @"video group");
}

- (void)testSubtitles
{
    FFCStreamInfoTag *infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertNil(infoTag.subtitles);

    infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"SUBTITLES":@1}];
    XCTAssertNil(infoTag.subtitles, @"subtitles attribute must be a string");
    
    infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"SUBTITLES":@"subtitles group"}];
    XCTAssertEqualObjects(infoTag.subtitles, @"subtitles group");
}

- (void)testClosedCaptions
{
    FFCStreamInfoTag *infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertNil(infoTag.closedCaptions);
    
    infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CLOSED-CAPTIONS":@1}];
    XCTAssertNil(infoTag.closedCaptions, @"cloed captions attribute must be a string");
    
    infoTag =[[FFCStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CLOSED-CAPTIONS":@"closed captions group"}];
    XCTAssertEqualObjects(infoTag.closedCaptions, @"closed captions group");
}

@end

@interface IFrameStreamInfoTagTests : XCTestCase

@end

@implementation IFrameStreamInfoTagTests

- (void)testBasicIFrameStreamInfoTag
{
    FFCIFrameStreamInfoTag *infoTag = [[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{}];
    XCTAssertNil(infoTag, @"Info Tag needs bandwidth attribute");
    infoTag = [[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @"1"}];
    
    XCTAssertNil(infoTag, @"Bandwidth needs to be a number");
    
    infoTag = [[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1.2}];
    XCTAssertEqualObjects(infoTag.name, @"EXT-X-I-FRAME-STREAM-INF");
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1, @"Bandwidth will be rounded to an integer");
    
    infoTag = [[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1);
    infoTag = [[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1234568}];
    XCTAssertEqual(infoTag.bandwidth, (NSUInteger)1234568);
}

- (void)testAverageBandwidth
{
    FFCIFrameStreamInfoTag *infoTag =[[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)0, @"When no bandwidth is present, value should be zero since we're not indicating a missing value otherwise");
    
    infoTag = [[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AVERAGE-BANDWIDTH":@12}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)12);
    
    infoTag = [[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"AVERAGE-BANDWIDTH":@9876}];
    XCTAssertEqual(infoTag.averageBandwidth, (NSUInteger)9876);
}

- (void)testCodecs
{
    FFCIFrameStreamInfoTag *infoTag =[[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqualObjects(infoTag.codecs, @[]);
    
    NSArray *testCodecs = @[@"a", @"b", @"c"];
    
    infoTag = [[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CODECS":@"a,b,c"}];
    XCTAssertEqualObjects(infoTag.codecs, testCodecs);
    
    infoTag = [[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"CODECS":@"single codec"}];
    XCTAssertEqualObjects(infoTag.codecs, @[@"single codec"]);
}

- (void)testResolution
{
    FFCIFrameStreamInfoTag *infoTag =[[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssert(CGSizeEqualToSize(infoTag.resolution, CGSizeZero));
    
    CGSize testSize = CGSizeMake(123, 456);
    infoTag =[[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"RESOLUTION":[NSValue valueWithCGSize:testSize]}];
    XCTAssert(CGSizeEqualToSize(infoTag.resolution, testSize));
}

- (void)testFrameRate
{
    FFCIFrameStreamInfoTag *infoTag =[[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1}];
    XCTAssertEqual(infoTag.frameRate, (NSUInteger)0, @"When no framerate is present, value should be zero since we're not indicating a missing value otherwise");
    
    infoTag = [[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"FRAME-RATE":@24}];
    XCTAssertEqual(infoTag.frameRate, (double)24);
    
    infoTag = [[FFCIFrameStreamInfoTag alloc] initWithAttributes:@{@"BANDWIDTH" : @1, @"FRAME-RATE":@65}];
    XCTAssertEqual(infoTag.frameRate, (double)65);
}

@end

@interface MediaTagTests : XCTestCase

@end

@implementation MediaTagTests

- (void)testMediaTagRequiredFields
{
    FFCMediaTag *tag = [[FFCMediaTag alloc] initWithAttributes:@{}];
    XCTAssertNil(tag, @"Media tags require a type");
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO"}];
    XCTAssertNil(tag, @"Media tags require a group-id");
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group"}];
    XCTAssertNil(tag, @"Media tags require a name");
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"NAME":@"rendition name"}];
    XCTAssertNil(tag, @"Media tags require a group-id");
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"GROUP-ID": @"group"}];
    XCTAssertNil(tag, @"Media tags require a name");
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertNil(tag, @"Media tags require a type");
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"NAME":@"rendition name"}];
    XCTAssertNil(tag, @"Media tags require a type");
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertTrue([tag isKindOfClass:[FFCMediaTag class]]);
    
    XCTAssertEqualObjects(tag.name, @"EXT-X-MEDIA");
    XCTAssertEqual(tag.type, FFCMediaTypeVideo);
    XCTAssertEqualObjects(tag.renditionName, @"rendition name");
    XCTAssertEqualObjects(tag.groupID, @"group");
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"AUDIO", @"GROUP-ID": @"xyz", @"NAME":@"abc"}];
    XCTAssertEqual(tag.type, FFCMediaTypeAudio);
    XCTAssertEqualObjects(tag.renditionName, @"abc");
    XCTAssertEqualObjects(tag.groupID, @"xyz");
}

- (void)testMediaTypeEnum
{
    FFCMediaTag *tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqual(tag.type, FFCMediaTypeVideo);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"AUDIO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqual(tag.type, FFCMediaTypeAudio);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"SUBTITLES", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqual(tag.type, FFCMediaTypeSubtitles);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"CLOSED-CAPTIONS", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqual(tag.type, FFCMediaTypeClosedCaptions);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"OTHER", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqual(tag.type, FFCMediaTypeUnknown); // Should this fail instead?
}

- (void)testLanguage
{
    FFCMediaTag *tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertNil(tag.language);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"LANGUAGE":@"en"}];
    XCTAssertEqualObjects(tag.language, @"en");
}

- (void)testAssociatedLanguage
{
    FFCMediaTag *tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertNil(tag.associatedLanguage);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"ASSOC-LANGUAGE":@"en"}];
    XCTAssertEqualObjects(tag.associatedLanguage, @"en");
}

- (void)testURI
{
    FFCMediaTag *tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertNil(tag.uri);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"URI":@"../media.m3u"}];
    XCTAssertTrue([tag.uri isKindOfClass:[NSURL class]]);
    XCTAssertEqualObjects(tag.uri, [NSURL URLWithString:@"../media.m3u"]); // This might be made more stringent.
}

- (void)testDefault
{
    FFCMediaTag *tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertFalse(tag.defaultRendition);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"DEFAULT":@"YES"}];
    XCTAssertTrue(tag.defaultRendition);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"DEFAULT":@"NO"}];
    XCTAssertFalse(tag.defaultRendition);
}

- (void)testAutoselect
{
    FFCMediaTag *tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertFalse(tag.autoselect);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"AUTOSELECT":@"YES"}];
    XCTAssertTrue(tag.autoselect);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"AUTOSELECT":@"NO"}];
    XCTAssertFalse(tag.autoselect);
}

- (void)testForced
{
    FFCMediaTag *tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertFalse(tag.forced);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"FORCED":@"YES"}];
    XCTAssertTrue(tag.forced);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"FORCED":@"NO"}];
    XCTAssertFalse(tag.forced);
}

- (void)testInstreamID
{
    FFCMediaTag *tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertNil(tag.instreamID);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"INSTREAM-ID":@"Something?"}];
    XCTAssertEqualObjects(tag.instreamID, @"Something?");
}

- (void)testCharacteristics
{
    FFCMediaTag *tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name"}];
    XCTAssertEqualObjects(tag.characteristics, @[]);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"CHARACTERISTICS":@"one"}];
    NSArray *one = @[@"one"];
    XCTAssertEqualObjects(tag.characteristics, one);
    
    tag = [[FFCMediaTag alloc] initWithAttributes:@{@"TYPE":@"VIDEO", @"GROUP-ID": @"group", @"NAME":@"rendition name", @"CHARACTERISTICS":@"one,two,three"}];
    NSArray *three = @[@"one", @"two", @"three"];
    XCTAssertEqualObjects(tag.characteristics, three);

}

@end

@interface SessionDataTests : XCTestCase

@end

@implementation SessionDataTests

- (void)testSessionDataTagRequiredFields
{
    FFCSessionDataTag *tag = [[FFCSessionDataTag alloc] initWithAttributes:@{}];
    XCTAssertNil(tag, @"Session Data tags require a data id");
    
    tag = [[FFCSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value"}];
    XCTAssertNil(tag, @"Session data requires euther a VALUE or a URI");
    
    
    tag = [[FFCSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"VALUE":@"session data value"}];
    XCTAssertEqualObjects(tag.value, @"session data value");
    
    tag = [[FFCSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"URI":@"session/data/path.json"}];
    XCTAssertEqualObjects(tag.uri, [NSURL URLWithString:@"session/data/path.json"]);
}

- (void)testLanguage
{
    FFCSessionDataTag *tag = [[FFCSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"VALUE":@"session data value"}];
    XCTAssertNil(tag.language);
    
    tag = [[FFCSessionDataTag alloc] initWithAttributes:@{@"DATA-ID" : @"data id value", @"VALUE":@"session data value", @"LANGUAGE":@"en"}];
    XCTAssertEqualObjects(tag.language, @"en");
}

@end

@interface SessionKeyTests : XCTestCase

@end

@implementation SessionKeyTests

- (void)testSessionKeyRequiredFields
{
    FFCSessionKeyTag *tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{}];
    XCTAssertNil(tag, @"METHOD is required");
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertEqualObjects(tag.name, @"EXT-X-SESSION-KEY");
    XCTAssertEqual(tag.method, FFCEncryptionMethodNone);
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"AES-128"}];
    XCTAssertNil(tag,@"URI is required if method is not none");
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"SAMPLE-AES"}];
    XCTAssertNil(tag,@"URI is required if method is not none");
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"AES-128", @"URI":@"http://example.com/key"}];
    XCTAssertEqualObjects(tag.name, @"EXT-X-SESSION-KEY");
    XCTAssertEqual(tag.method, FFCEncryptionMethodAES128);
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"SAMPLE-AES", @"URI":@"http://example.com/key"}];
    XCTAssertEqualObjects(tag.name, @"EXT-X-SESSION-KEY");
    XCTAssertEqual(tag.method, FFCEncryptionMethodSampleAES);
}

- (void)testKeyFormat
{
    FFCSessionKeyTag *tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertEqualObjects(tag.keyFormat, @"identity");
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMAT":@2}];
    XCTAssertEqualObjects(tag.keyFormat, @"identity", @"Incompatible class for quoted string key format will be ignored and have default value");
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMAT":@"SomeKeyFormat"}];
    XCTAssertEqualObjects(tag.keyFormat, @"SomeKeyFormat");
}

- (void)testKeyFormatVersions
{
    FFCSessionKeyTag *tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[]);
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : @"1"}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[@1]);

    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : @1}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[]);
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : @"1/2/3/4"}];
    NSArray *oneToFourArray = @[@1, @2, @3, @4];
    XCTAssertEqualObjects(tag.keyFormatVersions, oneToFourArray);
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"KEYFORMATVERSIONS" : oneToFourArray}];
    XCTAssertEqualObjects(tag.keyFormatVersions, @[]);
}

- (void)testInitializationVector
{
    FFCSessionKeyTag *tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE"}];
    XCTAssertNil(tag.initializationVector);
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"IV":@"1234567890abcdef"}];
    XCTAssertEqualObjects(tag.initializationVector, @"1234567890abcdef");
    
    tag = [[FFCSessionKeyTag alloc] initWithAttributes:@{@"METHOD":@"NONE", @"IV":@1324}];
    XCTAssertNil(tag.initializationVector);
}

@end

@interface StartTagTests : XCTestCase

@end

@implementation StartTagTests

- (void)testRequiredFields
{
    FFCStartTag *tag = [[FFCStartTag alloc] initWithAttributes:@{}];
    XCTAssertNil(tag, @"TIME-OFFSET is required");
    
    tag = [[FFCStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5)}];
    XCTAssertNotNil(tag);
    XCTAssertTrue([tag isKindOfClass:[FFCStartTag class]]);
    XCTAssertEqualObjects(tag.name, @"EXT-X-START");
    XCTAssertEqualWithAccuracy(tag.timeOffset, 1.5, 0.0001);

    tag = [[FFCStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@"1.5"}];
    XCTAssertNil(tag, @"TIME-OFFSET must be a number");
}

- (void)testPrecise
{
    FFCStartTag *tag = [[FFCStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5)}];
    XCTAssertFalse(tag.precise);
    
    tag = [[FFCStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5), @"PRECISE":@YES}];
    XCTAssertFalse(tag.precise, @"PRECISE needs to be a string");
    
    tag = [[FFCStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5), @"PRECISE":@"NO"}];
    XCTAssertFalse(tag.precise);
    
    tag = [[FFCStartTag alloc] initWithAttributes:@{@"TIME-OFFSET":@(1.5), @"PRECISE":@"YES"}];
    XCTAssertTrue(tag.precise);
}

@end



