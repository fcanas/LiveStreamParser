//
//  MasterPlaylistParseTests.m
//  FCHLSParser
//
//  Created by Fabian Canas on 3/4/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "FFCTagParser.h"
#import "FFCTag.h"

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
    
    FFCTagParser *parser = [[FFCTagParser alloc] initWithString:testPlaylistString];
    
    NSArray<id<FFCTag>> *playlist = [parser parse];
    XCTAssertEqual(playlist.count, (NSUInteger)18);
    
    XCTAssertEqualObjects(playlist[0].name, @"EXTM3U");
    
    XCTAssertEqualObjects(playlist[1].name, @"EXT-X-VERSION");
    XCTAssertTrue([playlist[1] isKindOfClass:[FFCVersionTag class]]);
    XCTAssertEqual(((FFCVersionTag *)playlist[1]).version, 6);
    
    XCTAssertEqualObjects(playlist[2].name, @"EXT-X-INDEPENDENT-SEGMENTS");
    
    FFCStreamInfoTag *streamInfoTag;
    XCTAssertEqualObjects(playlist[3].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[3] isKindOfClass:[FFCStreamInfoTag class]]);
    streamInfoTag = (FFCStreamInfoTag *)playlist[3];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)1290298);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)1304252);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"mp4a.40.2"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(768,432)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud1");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    XCTAssertEqualObjects(playlist[4].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[4] isKindOfClass:[FFCStreamInfoTag class]]);
    streamInfoTag = (FFCStreamInfoTag *)playlist[4];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)912621);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)924620);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"mp4a.40.2"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(640,360)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud1");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    XCTAssertEqualObjects(playlist[5].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[5] isKindOfClass:[FFCStreamInfoTag class]]);
    streamInfoTag = (FFCStreamInfoTag *)playlist[5];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)539420);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)550248);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.640015",@"mp4a.40.2"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(480,270)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud1");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    XCTAssertEqualObjects(playlist[6].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[6] isKindOfClass:[FFCStreamInfoTag class]]);
    streamInfoTag = (FFCStreamInfoTag *)playlist[6];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)1514297);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)1528250);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"ac-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(768,432)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud2");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    XCTAssertEqualObjects(playlist[7].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[7] isKindOfClass:[FFCStreamInfoTag class]]);
    streamInfoTag = (FFCStreamInfoTag *)playlist[7];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)1136619);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)1148619);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"ac-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(640,360)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud2");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    XCTAssertEqualObjects(playlist[8].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[8] isKindOfClass:[FFCStreamInfoTag class]]);
    streamInfoTag = (FFCStreamInfoTag *)playlist[8];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)763419);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)774247);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.640015",@"ac-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(480,270)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud2");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    XCTAssertEqualObjects(playlist[9].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[9] isKindOfClass:[FFCStreamInfoTag class]]);
    streamInfoTag = (FFCStreamInfoTag *)playlist[9];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)1322297);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)1336250);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"ec-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(768,432)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud3");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    XCTAssertEqualObjects(playlist[10].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[10] isKindOfClass:[FFCStreamInfoTag class]]);
    streamInfoTag = (FFCStreamInfoTag *)playlist[10];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)944619);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)956619);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.64001e",@"ec-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(640,360)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud3");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    XCTAssertEqualObjects(playlist[11].name, @"EXT-X-STREAM-INF");
    XCTAssertTrue([playlist[11] isKindOfClass:[FFCStreamInfoTag class]]);
    streamInfoTag = (FFCStreamInfoTag *)playlist[11];
    XCTAssertEqual(streamInfoTag.averageBandwidth, (NSUInteger)571419);
    XCTAssertEqual(streamInfoTag.bandwidth, (NSUInteger)582247);
    XCTAssertEqualObjects(streamInfoTag.codecs, (@[@"avc1.640015",@"ec-3"]));
    XCTAssertTrue(CGSizeEqualToSize(streamInfoTag.resolution, CGSizeMake(480,270)));
    XCTAssertEqualWithAccuracy(streamInfoTag.frameRate, 29.970, 0.0001);
    XCTAssertEqualObjects(streamInfoTag.closedCaptions, @"cc1");
    XCTAssertEqualObjects(streamInfoTag.audio, @"aud3");
    XCTAssertEqualObjects(streamInfoTag.subtitles, @"sub1");
    
    FFCIFrameStreamInfoTag *iFrameStreamInfoTag;
    XCTAssertEqualObjects(playlist[12].name, @"EXT-X-I-FRAME-STREAM-INF");
    XCTAssertTrue([playlist[12] isKindOfClass:[FFCIFrameStreamInfoTag class]]);
    iFrameStreamInfoTag = (FFCIFrameStreamInfoTag *)playlist[12];
    XCTAssertEqual(iFrameStreamInfoTag.averageBandwidth, (NSUInteger)80061);
    XCTAssertEqual(iFrameStreamInfoTag.bandwidth, (NSUInteger)83389);
    XCTAssertEqualObjects(iFrameStreamInfoTag.codecs, (@[@"avc1.64001e"]));
    XCTAssertTrue(CGSizeEqualToSize(iFrameStreamInfoTag.resolution, CGSizeMake(768,432)));
    
    XCTAssertEqualObjects(playlist[13].name, @"EXT-X-I-FRAME-STREAM-INF");
    XCTAssertTrue([playlist[13] isKindOfClass:[FFCIFrameStreamInfoTag class]]);
    iFrameStreamInfoTag = (FFCIFrameStreamInfoTag *)playlist[13];
    XCTAssertEqual(iFrameStreamInfoTag.averageBandwidth, (NSUInteger)63776);
    XCTAssertEqual(iFrameStreamInfoTag.bandwidth, (NSUInteger)64939);
    XCTAssertEqualObjects(iFrameStreamInfoTag.codecs, (@[@"avc1.64001e"]));
    XCTAssertTrue(CGSizeEqualToSize(iFrameStreamInfoTag.resolution, CGSizeMake(640,360)));
    
    XCTAssertEqualObjects(playlist[14].name, @"EXT-X-I-FRAME-STREAM-INF");
    XCTAssertTrue([playlist[14] isKindOfClass:[FFCIFrameStreamInfoTag class]]);
    iFrameStreamInfoTag = (FFCIFrameStreamInfoTag *)playlist[14];
    XCTAssertEqual(iFrameStreamInfoTag.averageBandwidth, (NSUInteger)39837);
    XCTAssertEqual(iFrameStreamInfoTag.bandwidth, (NSUInteger)40568);
    XCTAssertEqualObjects(iFrameStreamInfoTag.codecs, (@[@"avc1.640015"]));
    XCTAssertTrue(CGSizeEqualToSize(iFrameStreamInfoTag.resolution, CGSizeMake(480,270)));
    
    FFCMediaTag *mediaTag;
    XCTAssertEqualObjects(playlist[15].name, @"EXT-X-MEDIA");
    XCTAssertTrue([playlist[15] isKindOfClass:[FFCMediaTag class]]);
    mediaTag = (FFCMediaTag *)playlist[15];
    XCTAssertEqual(mediaTag.type, FFCMediaTypeAudio);
    XCTAssertEqualObjects(mediaTag.groupID, @"aud1");
    XCTAssertEqualObjects(mediaTag.language, @"eng");
    XCTAssertEqualObjects(mediaTag.renditionName, @"English");
    XCTAssertTrue(mediaTag.autoselect);
    XCTAssertTrue(mediaTag.defaultRendition);
    XCTAssertFalse(mediaTag.forced);
    XCTAssertEqualObjects(mediaTag.uri, [NSURL URLWithString:@"a1/prog_index.m3u8"]);
    
    XCTAssertEqualObjects(playlist[16].name, @"EXT-X-MEDIA");
    XCTAssertTrue([playlist[16] isKindOfClass:[FFCMediaTag class]]);
    mediaTag = (FFCMediaTag *)playlist[16];
    XCTAssertEqual(mediaTag.type, FFCMediaTypeSubtitles);
    XCTAssertEqualObjects(mediaTag.groupID, @"sub1");
    XCTAssertEqualObjects(mediaTag.language, @"eng");
    XCTAssertEqualObjects(mediaTag.renditionName, @"English");
    XCTAssertTrue(mediaTag.autoselect);
    XCTAssertTrue(mediaTag.defaultRendition);
    XCTAssertFalse(mediaTag.forced);
    XCTAssertEqualObjects(mediaTag.uri, [NSURL URLWithString:@"s1/eng/prog_index.m3u8"]);
    
    XCTAssertEqualObjects(playlist[17].name, @"EXT-X-MEDIA");
    XCTAssertTrue([playlist[17] isKindOfClass:[FFCMediaTag class]]);
    mediaTag = (FFCMediaTag *)playlist[17];
    XCTAssertEqual(mediaTag.type, FFCMediaTypeClosedCaptions);
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
        FFCTagParser *parser = [[FFCTagParser alloc] initWithString:testPlaylistString];
        [parser parse];
    }];
}

@end
