//
//  MasterPlaylistParseTests.m
//  FCHLSParser
//
//  Created by Fabian Canas on 3/4/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "LSPTagParser.h"
#import "LSPTag.h"

@import XCTest;

@interface MasterPlaylistParseTests : XCTestCase

@end

@implementation MasterPlaylistParseTests

#pragma mark - Realistic Playlist Tests

- (void)testCompletePlaylist
{
    NSString *testPlaylistString = [NSString stringWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"master" withExtension:@"m3u8"] encoding:NSUTF8StringEncoding error:nil];
    
    // Sanity check to make sure we've loaded the test playlist
    XCTAssertEqual(testPlaylistString.length, (NSUInteger)2621);
    
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:testPlaylistString];
    
    NSArray<id<LSPTag>> *playlist = [parser parse];
    XCTAssertEqual(playlist.count, (NSUInteger)27);
    
    NSUInteger tagIndex = 0;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXTM3U");
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-VERSION");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPVersionTag class]]);
    XCTAssertEqual(((LSPVersionTag *)playlist[tagIndex]).version, 6);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-INDEPENDENT-SEGMENTS");
    
    tagIndex++;
    
    LSPStreamInfoTag *streamInfoTag;
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPStreamInfoTag class]]);
    streamInfoTag = (LSPStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)1290298);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)1304252);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"mp4a.40.2"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(768,432)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud1");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"uri-tag");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPURITag class]]);
    LSPURITag *uri = playlist[tagIndex];
    XCTAssertEqualObjects(uri.uri, [NSURL URLWithString:@"v3/prog_index.m3u8"]);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPStreamInfoTag class]]);
    streamInfoTag = (LSPStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)912621);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)924620);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"mp4a.40.2"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(640,360)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud1");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"uri-tag");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPURITag class]]);
    uri = playlist[tagIndex];
    XCTAssertEqualObjects(uri.uri, [NSURL URLWithString:@"v2/prog_index.m3u8"]);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPStreamInfoTag class]]);
    streamInfoTag = (LSPStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)539420);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)550248);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.640015",@"mp4a.40.2"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(480,270)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud1");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"uri-tag");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPURITag class]]);
    uri = playlist[tagIndex];
    XCTAssertEqualObjects(uri.uri, [NSURL URLWithString:@"v1/prog_index.m3u8"]);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPStreamInfoTag class]]);
    streamInfoTag = (LSPStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)1514297);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)1528250);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"ac-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(768,432)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud2");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"uri-tag");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPURITag class]]);
    uri = playlist[tagIndex];
    XCTAssertEqualObjects(uri.uri, [NSURL URLWithString:@"v3/prog_index.m3u8"]);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPStreamInfoTag class]]);
    streamInfoTag = (LSPStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)1136619);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)1148619);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"ac-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(640,360)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud2");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"uri-tag");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPURITag class]]);
    uri = playlist[tagIndex];
    XCTAssertEqualObjects(uri.uri, [NSURL URLWithString:@"v2/prog_index.m3u8"]);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPStreamInfoTag class]]);
    streamInfoTag = (LSPStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)763419);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)774247);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.640015",@"ac-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(480,270)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud2");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"uri-tag");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPURITag class]]);
    uri = playlist[tagIndex];
    XCTAssertEqualObjects(uri.uri, [NSURL URLWithString:@"v1/prog_index.m3u8"]);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPStreamInfoTag class]]);
    streamInfoTag = (LSPStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)1322297);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)1336250);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"ec-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(768,432)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud3");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"uri-tag");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPURITag class]]);
    uri = playlist[tagIndex];
    XCTAssertEqualObjects(uri.uri, [NSURL URLWithString:@"v3/prog_index.m3u8"]);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPStreamInfoTag class]]);
    streamInfoTag = (LSPStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)944619);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)956619);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"ec-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(640,360)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud3");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"uri-tag");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPURITag class]]);
    uri = playlist[tagIndex];
    XCTAssertEqualObjects(uri.uri, [NSURL URLWithString:@"v2/prog_index.m3u8"]);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPStreamInfoTag class]]);
    streamInfoTag = (LSPStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)571419);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)582247);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.640015",@"ec-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(480,270)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud3");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"uri-tag");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPURITag class]]);
    uri = playlist[tagIndex];
    XCTAssertEqualObjects(uri.uri, [NSURL URLWithString:@"v1/prog_index.m3u8"]);
    
    tagIndex++;
    
    LSPIFrameStreamInfoTag *iFrameStreamInfoTag;
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-I-FRAME-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPIFrameStreamInfoTag class]]);
    iFrameStreamInfoTag = (LSPIFrameStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(iFrameStreamInfoTag.averageBandwidth, (NSUInteger)80061);
    XCTAssertEqual(iFrameStreamInfoTag.bandwidth, (NSUInteger)83389);
    XCTAssertEqualObjects(iFrameStreamInfoTag.codecs, (@[@"avc1.64001e"]));
    XCTAssertTrue(CGSizeEqualToSize(iFrameStreamInfoTag.resolution, CGSizeMake(768,432)));
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-I-FRAME-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPIFrameStreamInfoTag class]]);
    iFrameStreamInfoTag = (LSPIFrameStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(iFrameStreamInfoTag.averageBandwidth, (NSUInteger)63776);
    XCTAssertEqual(iFrameStreamInfoTag.bandwidth, (NSUInteger)64939);
    XCTAssertEqualObjects(iFrameStreamInfoTag.codecs, (@[@"avc1.64001e"]));
    XCTAssertTrue(CGSizeEqualToSize(iFrameStreamInfoTag.resolution, CGSizeMake(640,360)));
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-I-FRAME-STREAM-INF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPIFrameStreamInfoTag class]]);
    iFrameStreamInfoTag = (LSPIFrameStreamInfoTag *)playlist[tagIndex];
    XCTAssertEqual(iFrameStreamInfoTag.averageBandwidth, (NSUInteger)39837);
    XCTAssertEqual(iFrameStreamInfoTag.bandwidth, (NSUInteger)40568);
    XCTAssertEqualObjects(iFrameStreamInfoTag.codecs, (@[@"avc1.640015"]));
    XCTAssertTrue(CGSizeEqualToSize(iFrameStreamInfoTag.resolution, CGSizeMake(480,270)));
    
    tagIndex++;
    
    LSPMediaTag *mediaTag;
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-MEDIA");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPMediaTag class]]);
    mediaTag = (LSPMediaTag *)playlist[tagIndex];
    XCTAssertEqual(mediaTag.type, LSPMediaTypeAudio);
    XCTAssertEqualObjects(mediaTag.groupID, @"aud1");
    XCTAssertEqualObjects(mediaTag.language, @"eng");
    XCTAssertEqualObjects(mediaTag.renditionName, @"English");
    XCTAssertTrue(mediaTag.autoselect);
    XCTAssertTrue(mediaTag.defaultRendition);
    XCTAssertFalse(mediaTag.forced);
    XCTAssertEqualObjects(mediaTag.uri, [NSURL URLWithString:@"a1/prog_index.m3u8"]);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-MEDIA");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPMediaTag class]]);
    mediaTag = (LSPMediaTag *)playlist[tagIndex];
    XCTAssertEqual(mediaTag.type, LSPMediaTypeSubtitles);
    XCTAssertEqualObjects(mediaTag.groupID, @"sub1");
    XCTAssertEqualObjects(mediaTag.language, @"eng");
    XCTAssertEqualObjects(mediaTag.renditionName, @"English");
    XCTAssertTrue(mediaTag.autoselect);
    XCTAssertTrue(mediaTag.defaultRendition);
    XCTAssertFalse(mediaTag.forced);
    XCTAssertEqualObjects(mediaTag.uri, [NSURL URLWithString:@"s1/eng/prog_index.m3u8"]);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-MEDIA");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPMediaTag class]]);
    mediaTag = (LSPMediaTag *)playlist[tagIndex];
    XCTAssertEqual(mediaTag.type, LSPMediaTypeClosedCaptions);
    XCTAssertEqualObjects(mediaTag.groupID, @"cc1");
    XCTAssertEqualObjects(mediaTag.language, @"eng");
    XCTAssertEqualObjects(mediaTag.renditionName, @"English");
    XCTAssertTrue(mediaTag.autoselect);
    XCTAssertTrue(mediaTag.defaultRendition);
    XCTAssertFalse(mediaTag.forced);
    XCTAssertEqualObjects(mediaTag.instreamID, @"CC1");
}

#pragma mark - Performance

- (void)testPerformanceExample
{
    NSString *testPlaylistString = [NSString stringWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"master" withExtension:@"m3u8"] encoding:NSUTF8StringEncoding error:nil];
    
    // Sanity check to make sure we've loaded the test playlist
    XCTAssertEqual(testPlaylistString.length, (NSUInteger)2621);
    
    [self measureBlock:^{
        LSPTagParser *parser = [[LSPTagParser alloc] initWithString:testPlaylistString];
        [parser parse];
    }];
}

@end
