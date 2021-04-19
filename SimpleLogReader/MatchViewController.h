//
//  ViewController.h
//  SimpleLogReader
//
//  Created by Vladislav Garifulin on 19/02/2019.
//  Copyright © 2019 Vladislav Garifulin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchView.h"
#import "LogOperator.h"
#import "BatchOperation.h"

@interface UIMatchViewController : UIViewController {
    UIMatchView         *matchView;
    NSOperationQueue    *batchQueue;
    NSOperationQueue    *fileQueue;
    NSMutableArray      *strings;
}

@end

