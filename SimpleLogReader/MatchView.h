//
//  UIMatchView.h
//  SimpleLogReader
//
//  Created by Vladislav Garifulin on 20/02/2019.
//  Copyright © 2019 Vladislav Garifulin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIMatchView : UIView <UITableViewDelegate, UITableViewDataSource> {
    CGSize keyboardSize;
}

@property (nonatomic, retain) UIButton *startButton;
@property (nonatomic, retain) UITextField *filePathTextField;
@property (nonatomic, retain) UITextField *filterTextField;
@property (nonatomic, retain) UITableView *stringsTableView;
@property (nonatomic, retain) UILabel *tasksCountLabel;
@property (nonatomic, retain) NSMutableArray *strings;

@end
