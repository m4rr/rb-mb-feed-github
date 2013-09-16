//
//  FirstViewController.m
//  rb-mb-feed
//
//  Created by Marat Saytakov on 02.09.13.
//  Copyright (c) 2013 Marat Saytakov. All rights reserved.
//

#import "FirstViewController.h"
#import "DataManagingClass.h"
#import "MCSwipeTableViewCell.h"
#import "GUIConsts.h"

@implementation FirstViewController

@synthesize tableView, treillageTrash, treillageInbox, treillageDone, refreshControl;



#pragma mark - Init


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		tableView = [[UITableView alloc] initWithFrame:GUITableViewFrame style:UITableViewStylePlain];
		[self setView:tableView];
		
		[self.tableView setDataSource:self];
		[self.tableView setDelegate:self];
    }
    return self;
}


- (id)initWithStyle:(UITableViewStyle)style
{
	return [self init];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_dataManager = [[DataManagingClass alloc] init];
	[_dataManager setDelegate:self];

	
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:GUINavigationBarBg] forBarMetrics:UIBarMetricsDefault];
	
}


- (void)viewWillAppear:(BOOL)animated
{
	UIView *treillageView = [[UIView alloc] initWithFrame:GUITreillageFrame];
	
	treillageTrash = [[UIButton alloc] initWithFrame:GUITreillageTrashFrame];
	treillageInbox = [[UIButton alloc] initWithFrame:GUITreillageInboxFrame];
	treillageDone  = [[UIButton alloc] initWithFrame:GUITreillageDoneFrame];
	
	[treillageTrash addTarget:self action:@selector(treillageTrashFired) forControlEvents:UIControlEventTouchUpInside];
	[treillageInbox addTarget:self action:@selector(treillageInboxFired) forControlEvents:UIControlEventTouchUpInside];
	[treillageDone  addTarget:self action:@selector(treillageDoneFired)  forControlEvents:UIControlEventTouchUpInside];
	
	[treillageTrash setBackgroundImage:[UIImage imageNamed:GUITreillageTrashBgNormal]      forState:UIControlStateNormal];
	[treillageTrash setBackgroundImage:[UIImage imageNamed:GUITreillageTrashBgSelected]    forState:UIControlStateSelected];
	[treillageTrash setBackgroundImage:[UIImage imageNamed:GUITreillageTrashBgHighlighted] forState:UIControlStateHighlighted];
	[treillageTrash setBackgroundImage:[UIImage imageNamed:GUITreillageTrashBgHighlighted] forState:UIControlStateSelected | UIControlStateHighlighted];
	[treillageTrash setAdjustsImageWhenHighlighted:NO];
	
	[treillageInbox setBackgroundImage:[UIImage imageNamed:GUITreillageInboxBgNormal]      forState:UIControlStateNormal];
	[treillageInbox setBackgroundImage:[UIImage imageNamed:GUITreillageInboxBgSelected]    forState:UIControlStateSelected];
	[treillageInbox setBackgroundImage:[UIImage imageNamed:GUITreillageInboxBgHighlighted] forState:UIControlStateHighlighted];
	[treillageInbox setBackgroundImage:[UIImage imageNamed:GUITreillageInboxBgHighlighted] forState:UIControlStateSelected | UIControlStateHighlighted];
	[treillageInbox setAdjustsImageWhenHighlighted:NO];
	[treillageInbox setSelected:YES];
	
	[treillageDone setBackgroundImage:[UIImage imageNamed:GUITreillageDoneBgNormal]      forState:UIControlStateNormal];
	[treillageDone setBackgroundImage:[UIImage imageNamed:GUITreillageDoneBgSelected]    forState:UIControlStateSelected];
	[treillageDone setBackgroundImage:[UIImage imageNamed:GUITreillageDoneBgHighlighted] forState:UIControlStateHighlighted];
	[treillageDone setBackgroundImage:[UIImage imageNamed:GUITreillageDoneBgHighlighted] forState:UIControlStateSelected | UIControlStateHighlighted];
	[treillageDone setAdjustsImageWhenHighlighted:NO];
	
	[treillageView addSubview:treillageTrash];
	[treillageView addSubview:treillageInbox];
	[treillageView addSubview:treillageDone];
	
	[[self navigationItem] setTitleView:treillageView];

	
	UIImageView *mailListView = [[UIImageView alloc] initWithFrame:GUIMailListViewFrame];
	[mailListView setImage:[UIImage imageNamed:GUIMailListViewBg]];
	[[self tableView] setBackgroundView:mailListView];
		
	refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self
					   action:@selector(handleRefresh)
			 forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:refreshControl];
	
	[self.tableView setRowHeight:GUITableViewRowHeight];
	
	[self forceRefresh];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table View requirements


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataManager messagesCount];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MCSwipeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:nil];
	
    if (cell == nil) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	}
	
	
	UILabel *fromToLabel, *subjectLabel, *messageBodyLabel, *timeLabel, *counter;
	UIImageView *starIndicator, *disclosureIndicator, *unreadIndicator;
	
	UIFont *chevinMedium = [UIFont fontWithName:@"ChevinPro-Medium" size:15.0];
	UIFont *chevinMediumSmall = [UIFont fontWithName:@"ChevinPro-Medium" size:14.0];
	UIFont *chevinBold = [UIFont fontWithName:@"ChevinCyrillic-Bold" size:15.0];
	UIFont *chevinBoldXSmall = [UIFont fontWithName:@"ChevinCyrillic-Bold" size:12.0];
	
	
	NSDictionary *message = [_dataManager messageForIndexPath:indexPath];
	
	fromToLabel = [[UILabel alloc] initWithFrame:GUICellFromLabelFrame];
	[fromToLabel setFont:chevinMedium];
	[fromToLabel setTextColor:[UIColor darkGrayColor]];
	[fromToLabel setBackgroundColor:[UIColor clearColor]];
	[cell.contentView addSubview:fromToLabel];
	
	
	timeLabel = [[UILabel alloc] initWithFrame:GUICellTimeLabelFrame];
	[timeLabel setFont:chevinMediumSmall];
	[timeLabel setTextColor:[UIColor lightGrayColor]];
	[timeLabel setTextAlignment:NSTextAlignmentRight];
	[timeLabel setBackgroundColor:[UIColor clearColor]];
	[cell.contentView addSubview:timeLabel];
	
	
	subjectLabel = [[UILabel alloc] initWithFrame:GUICellSubjectLabelFrame];
	[subjectLabel setFont:chevinBold];
	[subjectLabel setTextColor:[UIColor blackColor]];
	[subjectLabel setBackgroundColor:[UIColor clearColor]];
	[cell.contentView addSubview:subjectLabel];
	
	
	messageBodyLabel = [[UILabel alloc] initWithFrame:GUICellMessageBodyLabelFrame];
	[messageBodyLabel setFont:chevinMedium];
	[messageBodyLabel setTextColor:[UIColor lightGrayColor]];
	[messageBodyLabel setNumberOfLines:2];
	[messageBodyLabel setBackgroundColor:[UIColor clearColor]];
	[cell.contentView addSubview:messageBodyLabel];
	
	
	if ([[message objectForKey:@"unread"] integerValue] == 1) {
		unreadIndicator = [[UIImageView alloc] initWithFrame:GUICellUnreadIndicatorFrame];
		[unreadIndicator setImage:[UIImage imageNamed:GUICellUnreadIndicatorImg]];
		[unreadIndicator setCenter:GUICellUnreadIndicatorCenter];
		[cell.contentView addSubview:unreadIndicator];
	}
	
	
	if ([[message objectForKey:@"starred"] integerValue] == 1) {
		starIndicator = [[UIImageView alloc] initWithFrame:GUICellStarIndicatorFrame];
		[starIndicator setImage:[UIImage imageNamed:GUICellStarIndicatorImg]];
		[starIndicator setCenter:GUICellStarIndicatorCenter];
		[cell.contentView addSubview:starIndicator];
	}
	
	
	if ([[message objectForKey:@"count"] integerValue] != 0) {
		counter = [[UILabel alloc] initWithFrame:GUICellCounterFrame];
		[counter setFont:chevinBoldXSmall];
		[counter setTextAlignment:NSTextAlignmentCenter];
		[counter setTextColor:[UIColor whiteColor]];
		[counter setNumberOfLines:1];
		[counter setMinimumScaleFactor:0.5];
		[counter setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
		[counter setAdjustsFontSizeToFitWidth:YES];
		[counter setBackgroundColor:[UIColor clearColor]];
		
		UIImageView *counterView = [[UIImageView alloc] initWithFrame:GUICellCounterViewFrame];
		[counterView setCenter:GUICellCounterViewCenter];
		[counterView setImage:[UIImage imageNamed:GUICellCounterViewImg]];
		[counterView addSubview:counter];
		
		[cell.contentView addSubview:counterView];
	}
	
	
	disclosureIndicator = [[UIImageView alloc] initWithFrame:GUICellDisclosureIndicatorFrame];
	[disclosureIndicator setCenter:GUICellDisclosureIndicatorCenter];
	[disclosureIndicator setImage:[UIImage imageNamed:GUICellDisclosureIndicatorImg]];
	[cell.contentView addSubview:disclosureIndicator];
	
	
	
	[fromToLabel setText:[message objectForKey:@"fromto"]];
	
	[timeLabel setText:[message objectForKey:@"time"]];
	
	[subjectLabel setText:[message objectForKey:@"subject"]];
	
	[counter setText:[[message objectForKey:@"count"] stringValue]];
	
	[messageBodyLabel setText:[message objectForKey:@"body"]];
	
	
	
	[cell setMode:MCSwipeTableViewCellModeExit];

	if ([_dataManager currentState] == DMCurrentStateInbox) {
		[cell setFirstStateIconName:@"check"
						 firstColor:[UIColor GUISwipeCheckColor]
				secondStateIconName:nil
						secondColor:nil
					  thirdIconName:@"cross"
						 thirdColor:[UIColor GUISwipeCrossColor]
					 fourthIconName:nil
						fourthColor:nil
		 ];
	} else if ([_dataManager currentState] == DMCurrentStateTrash) {
		[cell setFirstStateIconName:@"box"
						 firstColor:[UIColor GUISwipeBoxColor]
				secondStateIconName:@"check"
						secondColor:[UIColor GUISwipeCheckColor]
					  thirdIconName:nil
						 thirdColor:nil
					 fourthIconName:nil
						fourthColor:nil
		 ];
	} else if ([_dataManager currentState] == DMCurrentStateDone) {
		[cell setFirstStateIconName:nil
						 firstColor:nil
				secondStateIconName:nil
						secondColor:nil
					  thirdIconName:@"box"
						 thirdColor:[UIColor GUISwipeBoxColor]
					 fourthIconName:@"cross"
						fourthColor:[UIColor GUISwipeCrossColor]
		 ];
	}
	
	
	
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    [cell setBackgroundColor:[UIColor lightGrayColor]];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	[cell setDelegate:_dataManager];

	
	
	[_dataManager askForMoreItemsWhileIndexPath:indexPath];
	
	
	
    return cell;
}



#pragma mark - TableView tuning

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[_dataManager makeReadMessageAtIndexPath:indexPath];
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if ([_dataManager messagesCount] == 0)
		return GUITableViewEmptyHeaderHeight;
	
	return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if ([_dataManager messagesCount] == 0) {
		UIImageView *emptySplash = [[UIImageView alloc] initWithFrame:GUIMailListEmptySplashFrame];
		[emptySplash setImage:[UIImage imageNamed:GUIMailListEmptySplashImg]];
		[emptySplash setCenter:GUIMailListEmptySplashCenter];

		UIView *emptySplashView = [[UIView alloc] initWithFrame:GUIMailListEmptySplashViewFrame];
		[emptySplashView addSubview:emptySplash];
		
		return emptySplashView;
	}
	
	return nil;
}



#pragma mark - Actions

- (void)treillageTrashFired
{
	[treillageTrash setSelected:YES];
	[treillageInbox setSelected:NO];
	[treillageDone  setSelected:NO];
	
	[_dataManager setCurrentState:DMCurrentStateTrash];
}


- (void)treillageInboxFired
{
	[treillageTrash setSelected:NO];
	[treillageInbox setSelected:YES];
	[treillageDone  setSelected:NO];
	
	[_dataManager setCurrentState:DMCurrentStateInbox];
}


- (void)treillageDoneFired
{
	[treillageTrash setSelected:NO];
	[treillageInbox setSelected:NO];
	[treillageDone  setSelected:YES];
	
	[_dataManager setCurrentState:DMCurrentStateDone];
}


- (void)handleRefresh
{
	[_dataManager startLoadingData];
}


- (void)forceRefresh
{
	[self.refreshControl beginRefreshing];
	
    if (self.tableView.contentOffset.y == 0) {
        [UIView animateWithDuration:0.50
							  delay:0
							options:UIViewAnimationOptionBeginFromCurrentState
						 animations:^(void){
							 self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
						 }
						 completion:^(BOOL finished){
							 [self handleRefresh];
						 }];
    }
}


#pragma mark - DM delegate

- (void)didDoneManagingData
{
	if ([refreshControl isRefreshing])
		[refreshControl endRefreshing];

	[self.tableView reloadData];

}


@end
