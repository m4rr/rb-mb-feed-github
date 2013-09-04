//
//  FirstViewController.h
//  rb-mb-feed
//
//  Created by Marat Saytakov on 02.09.13.
//  Copyright (c) 2013 Marat Saytakov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property UIButton *tre01;
@property UIButton *tre02;
@property UIButton *tre03;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) UISearchBar *searchBar;

@property NSDictionary *pages;
@property NSMutableArray *emails;
@property NSMutableArray *emails_x;
@property NSMutableArray *emails_v;
@property NSMutableDictionary *unreadEmails;




@end
