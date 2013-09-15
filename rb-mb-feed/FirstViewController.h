//
//  FirstViewController.h
//  rb-mb-feed
//
//  Created by Marat Saytakov on 02.09.13.
//  Copyright (c) 2013 Marat Saytakov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManagingClass.h"

@interface FirstViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DataManagerDelegate>

@property (nonatomic, strong) id dataManager;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *treillageTrash;
@property (nonatomic, strong) UIButton *treillageInbox;
@property (nonatomic, strong) UIButton *treillageDone;

@property (nonatomic, strong) UIRefreshControl *refreshControl;


@end
