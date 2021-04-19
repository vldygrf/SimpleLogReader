//
//  UIMatchView.m
//  SimpleLogReader
//
//  Created by Vladislav Garifulin on 20/02/2019.
//  Copyright © 2019 Vladislav Garifulin. All rights reserved.
//

#import "MatchView.h"

@implementation UIMatchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.filePathTextField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
        self.filePathTextField.borderStyle = UITextBorderStyleLine;
        self.filePathTextField.placeholder = NSLocalizedString(@"Text file URL (ANSI only)", nil);
        self.filePathTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.filePathTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.filePathTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self addSubview:self.filePathTextField];
        
        self.filterTextField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
        self.filterTextField.borderStyle = UITextBorderStyleLine;
        self.filterTextField.placeholder = NSLocalizedString(@"Filter (*?)", nil);
        self.filterTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.filterTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.filterTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [self addSubview:self.filterTextField];
        
        self.startButton = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
        self.startButton.backgroundColor = [UIColor blackColor];
        [self.startButton addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
        [self.startButton setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self addSubview:self.startButton];
        
        self.tasksCountLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.tasksCountLabel.font = [UIFont boldSystemFontOfSize:12];
        self.tasksCountLabel.textColor = [UIColor blackColor];
        [self addSubview:self.tasksCountLabel];
        
        self.stringsTableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
        self.stringsTableView.rowHeight = UITableViewAutomaticDimension;
        self.stringsTableView.estimatedRowHeight = 44;
        self.stringsTableView.delegate = self;
        self.stringsTableView.dataSource = self;
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide:)] autorelease];
        [self.stringsTableView addGestureRecognizer:gr];
        [self addSubview:self.stringsTableView];
        
        self.strings = [NSMutableArray arrayWithCapacity:50];
        
        keyboardSize = CGSizeZero;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
            name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
            name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    self.filePathTextField = nil;
    self.filterTextField = nil;
    self.startButton = nil;
    self.stringsTableView = nil;
    self.tasksCountLabel = nil;
    self.strings = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.strings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdent = @"stringCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    
    if (!cell)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdent] autorelease];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [self.strings objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    frame.size.height -= keyboardSize.height;
    
    CGSize bs = CGSizeMake(100, 40);
    CGFloat offset = 5;
    CGFloat y = 0;
    self.filePathTextField.frame = CGRectMake(offset, y += offset, frame.size.width - offset * 2, bs.height);
    self.filterTextField.frame = CGRectMake(offset, y += offset + bs.height, frame.size.width - offset * 2, bs.height);
    self.startButton.frame = CGRectMake((frame.size.width - bs.width) / 2, y += offset + bs.height, bs.width, bs.height);
    self.tasksCountLabel.frame = CGRectMake(self.startButton.frame.origin.x + self.startButton.frame.size.width + offset * 4,
          self.startButton.frame.origin.y, bs.width, bs.height);

    self.stringsTableView.frame = CGRectMake(0, y += offset + bs.height, frame.size.width, frame.size.height - y);
}

- (void)keyboardWillShow:(NSNotification *)notification {
    keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self setFrame:self.frame];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    keyboardSize = CGSizeZero;
    [self setFrame:self.frame];
}

- (void)hide:(id)sender {
    [self.filePathTextField resignFirstResponder];
    [self.filterTextField resignFirstResponder];
}

@end
