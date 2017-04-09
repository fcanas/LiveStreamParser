//
//  MediaPlaylistParseTests.m
//  LiveStreamParser
//
//  Created by Fabian Canas on 4/9/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "LSPTagParser.h"
#import "LSPTag.h"

@import XCTest;

@interface MediaPlaylistParseTests : XCTestCase

@end

@implementation MediaPlaylistParseTests

- (void)testCompletePlaylist
{
    NSString *testPlaylistString = [NSString stringWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"prog_index" withExtension:@"m3u8"] encoding:NSUTF8StringEncoding error:nil];
    
    // Sanity check to make sure we've loaded the test playlist
    XCTAssertEqual(testPlaylistString.length, (NSUInteger)5731);
    
    LSPTagParser *parser = [[LSPTagParser alloc] initWithString:testPlaylistString];
    
    NSArray<id<LSPTag>> *playlist = [parser parse];
    XCTAssertEqual(playlist.count, (NSUInteger)307);
    
    NSUInteger tagIndex = 0;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXTM3U");
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-TARGETDURATION");
    // TODO : parse target duration tag
    //    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPVersionTag class]]);
    //    XCTAssertEqual(((LSPVersionTag *)playlist[tagIndex]).version, 6);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-VERSION");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPVersionTag class]]);
    XCTAssertEqual(((LSPVersionTag *)playlist[tagIndex]).version, 3);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-MEDIA-SEQUENCE");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPMediaSequenceTag class]]);
    XCTAssertEqual(((LSPMediaSequenceTag *)playlist[tagIndex]).number, 0);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-PLAYLIST-TYPE");
    // TODO : parse playlist type tag
    //    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPVersionTag class]]);
    //    XCTAssertEqual(((LSPVersionTag *)playlist[tagIndex]).version, 6);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXT-X-INDEPENDENT-SEGMENTS");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPBasicTag class]]);
    
    tagIndex++;
    
    XCTAssertEqualObjects(playlist[tagIndex].name, @"EXTINF");
    XCTAssertTrue([playlist[tagIndex] isKindOfClass:[LSPInfoTag class]]);
    XCTAssertEqualWithAccuracy(((LSPInfoTag *)playlist[tagIndex]).duration, 6.0, 0.00001);
    
    
    
    XCTAssertEqualObjects(playlist[306].name, @"EXT-X-ENDLIST");
    XCTAssertTrue([playlist[306] isKindOfClass:[LSPBasicTag class]]);
}

@end
