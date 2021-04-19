//
//  NSLogOperator.m
//  SimpleLogReader
//
//  Created by Vladislav Garifulin on 20/02/2019.
//  Copyright © 2019 Vladislav Garifulin. All rights reserved.
//

#import "LogOperator.h"

/**
    Оператор лог файлов (на данный момент, реализована единственная операция - поиск строк, удовлетворяющих фильтру)
 */
@interface NSLogOperator ()

@end

@implementation NSLogOperator

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static id obj = nil;
    
    dispatch_once(&onceToken, ^{
        obj = [[super alloc] initUniqueInstance];
    });
    
    return obj;
}

- (instancetype)initUniqueInstance {
    if (self = [super init]) {
        session = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil] retain];
        
        linkDictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    
    return self;
}

/**
 Запуск операции поиска строк, удовлетворяющих фильтру
 @param beginingHandler Обработчик успешного старта операции
 @param matchingHandler Обработчик нахождения строки, удовлетворяющей фильтру
 @param errorHandler Обработчик ошибки
 @param completionHandler Обработчик окончания операции
 */
- (void)matchWithFileUrl:(NSURL *)fileUrl filter:(NSString *)filter
    beginingHandler:(void (^)(void))beginingHandler
    matchingHandler:(void (^)(NSArray *matchedStrings))matchingHandler
    errorHandler:(void (^)(NSString *errorDescription))errorHandler
    completionHandler:(void (^)(void))completionHandler {
    
    self.matchingBeginingHandler = beginingHandler;
    self.matchingHandler = matchingHandler;
    self.matchingErrorHandler = errorHandler;
    self.matchingCompletionHandler = completionHandler;
        
    size_t size = filter.length + 1;
    char *cFilter = (char *)malloc(size);
    [filter getCString:cFilter maxLength:size encoding:NSWindowsCP1251StringEncoding];
    CLogReader *logReader = new CLogReader(cFilter);
    NSURLSessionDataTask *task = [session dataTaskWithURL:fileUrl];
    [task resume];
            
    self.matchingBeginingHandler();
    [linkDictionary setObject:[NSNumber numberWithInteger:(NSInteger)logReader] forKey:[NSNumber numberWithInteger:task.taskIdentifier]];
    free(cFilter);
}

- (void)processResultOf:(CLogReader *)logReader {
    std::vector <char *> matched_strings = logReader->MatchedStrings();
    
    if (matched_strings.size() > 0) {
        NSMutableArray *matchesStrings = [NSMutableArray arrayWithCapacity:matched_strings.size()];
        for(int i = 0; i < matched_strings.size(); i++) {
            NSString *s = [[NSString alloc] initWithCString:matched_strings[i] encoding:NSWindowsCP1251StringEncoding];
            if (s)
                [matchesStrings addObject:s];
            [s release];
        }
        
        self.matchingHandler(matchesStrings);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    CLogReader *logReader = (CLogReader *)[[linkDictionary objectForKey:[NSNumber numberWithInteger:task.taskIdentifier]] integerValue];
    if (logReader)
        [linkDictionary removeObjectForKey:[NSNumber numberWithInteger:task.taskIdentifier]];
    
    if (error == nil) {
        if (logReader) {
            logReader->Parse(false);
            [self processResultOf:logReader];
            self.matchingCompletionHandler();
        }
    }else
        self.matchingErrorHandler(error.description);
    
    if (logReader) {
        delete logReader;
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    //@synchronized (self) {
    CLogReader *logReader = (CLogReader *)[[linkDictionary objectForKey:[NSNumber numberWithInteger:dataTask.taskIdentifier]] integerValue];
    /*if (logReader) {
        #warning todo
        [data enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
            const char *chars = (char *)bytes;
            
    
            //dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
                logReader->AddSourceBlock(&chars[byteRange.location], byteRange.length);
                [self processResultOf:logReader];
     
            //dispatch_semaphore_signal(semaphore);
        }];
    }
    //}*/
    if (logReader) {
        const char *chars = (char *)data.bytes;
        logReader->AddSourceBlock(chars, data.length);
        [self processResultOf:logReader];
    }
}

- (NSInteger)tasksCount {
    return [linkDictionary count];
}

@end
