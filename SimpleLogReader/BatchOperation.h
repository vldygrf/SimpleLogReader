//
//  NSBatchOperation.h
//  SimpleLogReader
//
//  Created by Vladislav Garifulin on 22/02/2019.
//  Copyright © 2019 Vladislav Garifulin. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSBatchOperation : NSOperation {
    NSArray *batchArray;
}

- (instancetype)initWithBatchArray:(NSArray *)_batchArray subBatchHandler:(void (^)(NSArray *subBatchArray))subBatchHandler;
@property (nonatomic, copy) void (^subBatchHandler)(NSArray *subBatchArray);

@end
