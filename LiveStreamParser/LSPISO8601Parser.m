//
//  LSPISO8601Parser.m
//  LiveStreamParser
//
//  Created by Fabian Canas on 4/18/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import "LSPISO8601Parser.h"

@interface LSPISO8601Parser ()

@property (nonatomic, nonnull) NSScanner *scanner;

@end


@implementation LSPISO8601Parser

- (instancetype)initWithScanner:(NSScanner *)scanner
{
    self = [super init];
    
    if (self) {
        _scanner = scanner;
    }

    
    return self;
}

@end
