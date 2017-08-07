//
//  LSPSerializable.h
//  LiveStreamParser
//
//  Created by Fabian Canas on 8/5/17.
//  Copyright © 2017 Fabián Cañas. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LSPSerializable <NSObject>

- (NSString *)serialize;

@end
