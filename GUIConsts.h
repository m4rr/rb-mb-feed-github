//
//  GUIConsts.h
//  rb-mb-feed
//
//  Created by Marat Saytakov on 14.09.13.
//  Copyright (c) 2013 Marat Saytakov. All rights reserved.
//

#ifndef rb_mb_feed_GUIConsts_h
#define rb_mb_feed_GUIConsts_h


#pragma mark - Frames

#define GUITableViewFrame					CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)

#define GUIMailListViewFrame				CGRectMake(0.0, 0.0, 320.0, self.tableView.frame.size.height)
#define GUIMailListEmptySplashViewFrame		CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)
#define GUIMailListEmptySplashFrame			CGRectMake(0.0, 0.0, 150.0, 150.0)

#define GUITreillageFrame					CGRectMake(0.0, 0.0, 162.0, 32.0)

#define GUITreillageTrashFrame				CGRectMake(  0.0, 0.0, 54.0, 32.0)
#define GUITreillageInboxFrame				CGRectMake( 54.0, 0.0, 54.0, 32.0)
#define GUITreillageDoneFrame				CGRectMake(108.0, 0.0, 54.0, 32.0)

#define GUICellFromLabelFrame				CGRectMake( 30.0,  8.0, 220.0, 18.0)
#define GUICellTimeLabelFrame				CGRectMake(250.0,  8.0,  63.0, 18.0)
#define GUICellSubjectLabelFrame			CGRectMake( 30.0, 26.0, 230.0, 18.0)
#define GUICellMessageBodyLabelFrame		CGRectMake( 30.0, 46.0, 230.0, 36.0)
#define GUICellUnreadIndicatorFrame			CGRectMake(0.0, 0.0, 10.0, 10.0)
#define GUICellStarIndicatorFrame			CGRectMake(0.0, 0.0, 16.0, 16.0)
#define GUICellCounterViewFrame				CGRectMake(0.0, 0.0, 15.0, 16.0)
#define GUICellCounterFrame					CGRectMake(0.0, 0.0, 15.0, 16.0)
#define GUICellDisclosureIndicatorFrame		CGRectMake(0.0, 0.0, 13.0, 13.0)



#pragma mark - Points

#define GUIMailListEmptySplashCenter		CGPointMake(self.tableView.bounds.size.width/2, self.tableView.bounds.size.height/2 - 100.0)

#define GUICellUnreadIndicatorCenter		CGPointMake( 15.0, 16.0)
#define GUICellStarIndicatorCenter			CGPointMake( 15.0, 34.0)
#define GUICellCounterViewCenter			CGPointMake(290.0, 42.0)
#define GUICellDisclosureIndicatorCenter	CGPointMake(305.0, 42.0)



#pragma mark - Heights

#define GUITableViewRowHeight				85.0
#define GUITableViewEmptyHeaderHeight		self.tableView.bounds.size.height



#pragma mark - Backgrounds and images

#define GUIMailListViewBg					@"mailList"
#define GUIMailListEmptySplashImg			@"splash1"

#define GUINavigationBarBg					@"navBar"

#define GUITreillageTrashBgNormal			@"tre-x-norm"
#define GUITreillageTrashBgSelected			@"tre-x-sel"
#define GUITreillageTrashBgHighlighted		@"tre-x-hi"

#define GUITreillageInboxBgNormal			@"tre-mb-norm"
#define GUITreillageInboxBgSelected			@"tre-mb-sel"
#define GUITreillageInboxBgHighlighted		@"tre-mb-hi"

#define GUITreillageDoneBgNormal			@"tre-v-norm"
#define GUITreillageDoneBgSelected			@"tre-v-sel"
#define GUITreillageDoneBgHighlighted		@"tre-v-hi"

#define GUICellUnreadIndicatorImg			@"unread"
#define GUICellStarIndicatorImg				@"star-gold"
#define GUICellCounterViewImg				@"count"
#define GUICellDisclosureIndicatorImg		@"disclosureInd"



#pragma mark - Colors

#define GUISwipeBoxColor	colorWithRed: 81.0 / 255.0 green:185.0 / 255.0 blue:219.0 / 255.0 alpha:1.0
#define GUISwipeCheckColor	colorWithRed: 98.0 / 255.0 green:217.0 / 255.0 blue: 97.0 / 255.0 alpha:1.0
#define GUISwipeCrossColor	colorWithRed:227.0 / 255.0 green: 38.0 / 255.0 blue: 54.0 / 255.0 alpha:1.0



#endif
