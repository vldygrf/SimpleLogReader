//
//  NSBatchOperation.m
//  SimpleLogReader
//
//  Created by Vladislav Garifulin on 22/02/2019.
//  Copyright © 2019 Vladislav Garifulin. All rights reserved.
//

#import "BatchOperation.h"

@implementation NSBatchOperation

- (instancetype)initWithBatchArray:(NSArray *)_batchArray subBatchHandler:(void (^)(NSArray *subBatchArray))subBatchHandler {
    self = [super init];
    
    if (self != nil) {
        batchArray = [[NSArray alloc] initWithArray:_batchArray];
        self.subBatchHandler = subBatchHandler;
    }
    
    return self;
}

- (void)dealloc {
    [batchArray release];
    self.subBatchHandler = nil;
    
    [super dealloc];
}

- (void)main {
    int batchSize = 10;
    NSRange range = {0, batchSize};
    
    while (range.location < batchArray.count) {
        range.length = (batchArray.count > (range.location + range.length))?batchSize:batchArray.count - range.location;
        if ([self isCancelled]) return;
        self.subBatchHandler([batchArray subarrayWithRange:range]);
        range.location += range.length;
        [NSThread sleepForTimeInterval:0.1];
    }    
}

@end
