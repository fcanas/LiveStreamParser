//
//  LSPISO8601ParserTests.m
//  LiveStreamParser
//
//  Created by Fabian Canas on 4/18/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "LSPISO8601Parser.h"

@import XCTest;

@interface LSPISO8601ParserTests : XCTestCase

@end

@implementation LSPISO8601ParserTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitialization {
    NSScanner *scanner = [NSScanner scannerWithString:@""];
    LSPISO8601Parser *parser = [[LSPISO8601Parser alloc] initWithScanner:scanner];
    XCTAssertTrue([parser isKindOfClass:[LSPISO8601Parser class]]);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
