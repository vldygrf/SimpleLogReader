//
//  ViewController.m
//  SimpleLogReader
//
//  Created by Vladislav Garifulin on 19/02/2019.
//  Copyright © 2019 Vladislav Garifulin. All rights reserved.
//

#import "MatchViewController.h"

@interface UIMatchViewController ()

@end

@implementation UIMatchViewController

- (void)dealloc {
    [fileQueue release];
    [batchQueue release];
    [matchView release];
    [strings release];
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!matchView) {
        matchView = [[[UIMatchView alloc] initWithFrame:CGRectZero] autorelease];
        [self.view addSubview:matchView];
        [matchView.startButton addTarget:self action:@selector(actionOfStartButton:) forControlEvents:UIControlEventTouchUpInside];
        matchView.filePathTextField.text = @"https://www.dropbox.com/s/w9c6n2ts4toedln/bookW.txt?dl=1";
    }
    
    if (!batchQueue) {
        batchQueue = [[NSOperationQueue alloc] init];
        batchQueue.maxConcurrentOperationCount = 1;
    }
    
    if (!fileQueue) {
        fileQueue = [[NSOperationQueue alloc] init];
        fileQueue.maxConcurrentOperationCount = 1;
    }
    
    if (!strings)
        strings = [[NSMutableArray alloc] initWithCapacity:50];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    matchView.frame = CGRectMake(0, UIApplication.sharedApplication.statusBarFrame.size.height,
        self.view.bounds.size.width, self.view.bounds.size.height - UIApplication.sharedApplication.statusBarFrame.size.height);
}

- (void)updateTasksCountLabel {
    dispatch_async(dispatch_get_main_queue(), ^{
        matchView.tasksCountLabel.text = [NSString stringWithFormat:@"tasks count = %li", (long)NSLogOperator.shared.tasksCount];
    });
}

- (NSString *)filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[paths firstObject] stringByAppendingPathComponent:@"results.log"];
    return filePath;
}

- (void)actionOfStartButton:(id)sender {
    if (matchView.filePathTextField.text.length == 0)
        return;
    
    __block NSLogOperator *bLogOperator = NSLogOperator.shared; //возможен retain cycle (хотя в данном решении это невозможно в силу того, что NSLogOperator.shared живет весь цикл жизни приложения)
    
    [[NSLogOperator shared] matchWithFileUrl:[NSURL URLWithString:matchView.filePathTextField.text]
        filter:matchView.filterTextField.text
        beginingHandler:^{
            if (bLogOperator.tasksCount == 0) {
                [NSFileManager.defaultManager createFileAtPath:self.filePath contents:nil attributes:nil];
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [matchView.strings removeAllObjects];
                    [matchView.stringsTableView reloadData];
                    [strings removeAllObjects];
                });
            }
            
            [self updateTasksCountLabel];
        }matchingHandler:^(NSArray *matchedStrings) {
            [strings addObjectsFromArray:matchedStrings];
            //добавление большого кол-ва строк в таблицу за раз может сильно нагружать основной поток, поэтому реализовано постепенное добавление
            NSBatchOperation *batchOperation = [[NSBatchOperation alloc] initWithBatchArray:matchedStrings
                subBatchHandler:^(NSArray *subBatchArray) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray arrayWithCapacity:subBatchArray.count];
                        for(NSInteger i = 0; i < subBatchArray.count; i++)
                            [indexPaths addObject:[NSIndexPath indexPathForRow:matchView.strings.count + i inSection:0]];
                        
                        [matchView.strings addObjectsFromArray:subBatchArray];
                        [matchView.stringsTableView beginUpdates];
                        [matchView.stringsTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                        [matchView.stringsTableView endUpdates];
                    });
                }];
            
            [batchQueue addOperation:batchOperation];
            [batchOperation release];
            
            //результаты парсинга пишем в файл
            [fileQueue addOperationWithBlock:^{
                NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
                if (file) {
                    [file seekToEndOfFile];
                    
                    for(NSString *s in matchedStrings)
                        [file writeData:[[s stringByAppendingString:@"\n"] dataUsingEncoding:NSWindowsCP1251StringEncoding]];
                    
                    [file closeFile];
                }
            }];
        }errorHandler:^(NSString *errorDescription) {
            NSLog(@"%@", errorDescription);
            [self updateTasksCountLabel];
        }completionHandler:^{
            if (bLogOperator.tasksCount == 0) {
                [batchQueue cancelAllOperations];
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (strings.count > matchView.strings.count) {
                        //добавляем оставшиеся строки
                        [matchView.strings addObjectsFromArray:[strings subarrayWithRange:NSMakeRange(matchView.strings.count, strings.count - matchView.strings.count)]];
                        [matchView.stringsTableView reloadData];
                        [strings removeAllObjects];
                    }
                });
            }
            
            [self updateTasksCountLabel];
        }];
}

@end
