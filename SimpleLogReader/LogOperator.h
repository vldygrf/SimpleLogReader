//
//  NSLogOperator.h
//  SimpleLogReader
//
//  Created by Vladislav Garifulin on 20/02/2019.
//  Copyright © 2019 Vladislav Garifulin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogReader.hpp"

@interface NSLogOperator : NSObject <NSURLSessionTaskDelegate, NSURLSessionDataDelegate> {
    NSURLSession *session;
    NSMutableDictionary <NSNumber *, NSNumber *> *linkDictionary;
}

@property (nonatomic, copy) void (^matchingErrorHandler)(NSString *errorDescription);
@property (nonatomic, copy) void (^matchingHandler)(NSArray *matchedStrings);
@property (nonatomic, copy) void (^matchingBeginingHandler)(void);
@property (nonatomic, copy) void (^matchingCompletionHandler)(void);

+(instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
-(instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+(instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

+ (NSLogOperator *)shared;

- (void)matchWithFileUrl:(NSURL *)fileUrl filter:(NSString *)filter
    beginingHandler:(void (^)(void))beginingHandler
    matchingHandler:(void (^)(NSArray *matchedStrings))matchingHandler
    errorHandler:(void (^)(NSString *errorDescription))errorHandler
    completionHandler:(void (^)(void))completionHandler;

- (NSInteger)tasksCount;

@end
