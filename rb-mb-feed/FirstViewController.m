//
//  FirstViewController.m
//  rb-mb-feed
//
//  Created by Marat Saytakov on 02.09.13.
//  Copyright (c) 2013 Marat Saytakov. All rights reserved.
//

#import "FirstViewController.h"
#import "MCSwipeTableViewCell.h"

@interface FirstViewController () <MCSwipeTableViewCellDelegate, UISearchBarDelegate>

@end

@implementation FirstViewController

@synthesize tableView, tre01, tre02, tre03,
			refreshControl, searchBar,
			pages, emails, emails_x, emails_v, unreadEmails;



#pragma mark - Action!

- (void)tre01Fired // x
{
	[tre01 setSelected:YES];
	[tre02 setSelected:NO];
	[tre03 setSelected:NO];

	[tableView reloadData];
}


- (void)tre02Fired
{
	[tre01 setSelected:NO];
	[tre02 setSelected:YES];
	[tre03 setSelected:NO];
	
	[tableView reloadData];
}


- (void)tre03Fired // v
{
	[tre01 setSelected:NO];
	[tre02 setSelected:NO];
	[tre03 setSelected:YES];
	
	[tableView reloadData];
}


- (void)handleRefresh
{
	[self reloadDataFromNetwork:0];
}



#pragma mark - Network


- (void)reloadDataFromNetwork:(int)forPage
{
	NSURL *dataURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://rocket-ios.herokuapp.com/emails.json?page=%d",
										   forPage]];
    NSURLRequest *dataRequest = [NSURLRequest requestWithURL:dataURL
												 cachePolicy:NSURLRequestReloadIgnoringCacheData
											 timeoutInterval:15];


//	http://rocket-ios.herokuapp.com/emails.json
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		});
		
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *receivedData = [NSURLConnection sendSynchronousRequest:dataRequest
													 returningResponse:&response
																 error:&error];

		if (error) {
			if ([refreshControl isRefreshing]) {
				[refreshControl endRefreshing];
			}
			
			NSLog(@"Network error - %@", error);
			
		} else {
			

			NSError *JSONErr = nil;
			
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:&JSONErr];
			
			if (JSONErr) {
				NSLog(@"JSONErr - %@", JSONErr);
			} else {
				
				pages = [result objectForKey:@"pagination"];
				
				if (!emails) {
					emails = [[NSMutableArray alloc] init];
				}

				if (!emails_x) {
					emails_x = [[NSMutableArray alloc] init];
				}
				
				if (!emails_v) {
					emails_v = [[NSMutableArray alloc] init];
				}
				
				if (!unreadEmails) {
					unreadEmails = [[NSMutableDictionary alloc] init];
				}
				
//				Верхняя обновлялка всегда просит страницу=0, поэтому сбрасываем все массивы.
//				(Нижняя обновлялка просит все остальные страницы.)
				if (forPage == 0) {
					[emails removeAllObjects];
					[emails_x removeAllObjects];
					[emails_v removeAllObjects];
					[unreadEmails removeAllObjects];
				}
				
				
				for (NSDictionary *d in [result objectForKey:@"emails"]) {
					[emails addObject:d];
				}
	
				
				for (NSDictionary *d in emails) {
					if (![[unreadEmails objectForKey:[d valueForKey:@"id"]] isEqualToString:@"read"]) {
						[unreadEmails setValue:@"unread" forKey:[d valueForKey:@"id"]];
					}
				}

//				NSLog(@"pages - %@", pages);
//				NSLog(@"emails - %@", emails);
//				NSLog(@"unreadEmails - %@", unreadEmails);
				
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[[self tableView] reloadData];
				if ([refreshControl isRefreshing]) {
					[refreshControl endRefreshing];
				}
			});
			
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		});

	});
	
	

}


#pragma mark - Formatting...

- (NSString *)userVisibleDateTimeStringForRFC3339DateTimeString:(NSString *)rfc3339DateTimeString {
    /*
	 Returns a user-visible date time string that corresponds to the specified
	 RFC 3339 date time string. Note that this does not handle all possible
	 RFC 3339 date time strings, just one of the most common styles.
     */
	
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
	
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
    // Convert the RFC 3339 date time string to an NSDate.
    NSDate *date = [rfc3339DateFormatter dateFromString:rfc3339DateTimeString];
	
    NSString *userVisibleDateTimeString;
    if (date != nil) {
        // Convert the date object to a user-visible date string.
        NSDateFormatter *userVisibleDateFormatter = [[NSDateFormatter alloc] init];
        assert(userVisibleDateFormatter != nil);
		
//        [userVisibleDateFormatter setDateStyle:NSDateFormatterShortStyle];
//        [userVisibleDateFormatter setTimeStyle:NSDateFormatterNoStyle];
		
		if ([date timeIntervalSinceNow] < -86400.0) {
			[userVisibleDateFormatter setDateFormat:@"dd MMM"];
		} else {
			[userVisibleDateFormatter setDateFormat:@"HH':'mm"];
		}
		
        userVisibleDateTimeString = [userVisibleDateFormatter stringFromDate:date];
    }
    return userVisibleDateTimeString;
}




#pragma mark - TableView tuning

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if ([tre02 isSelected]) {
		[unreadEmails setValue:@"read" forKey:[[emails objectAtIndex:[indexPath row]] objectForKey:@"id"]];
	} else if ([tre01 isSelected]) {
		[unreadEmails setValue:@"read" forKey:[[emails_x objectAtIndex:[indexPath row]] objectForKey:@"id"]];
	} else if ([tre03 isSelected]) {
		[unreadEmails setValue:@"read" forKey:[[emails_v objectAtIndex:[indexPath row]] objectForKey:@"id"]];
	}
	
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 85.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	NSArray *localEmails = nil;
	
	if ([tre02 isSelected]) {
		localEmails = emails;
	} else if ([tre01 isSelected]) {
		localEmails = emails_x;
	} else if ([tre03 isSelected]) {
		localEmails = emails_v;
	}
	
	if ([localEmails count] == 0) {
		return self.tableView.bounds.size.height;
	}
	
	return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSArray *localEmails = nil;
	
	if ([tre02 isSelected]) {
		localEmails = emails;
	} else if ([tre01 isSelected]) {
		localEmails = emails_x;
	} else if ([tre03 isSelected]) {
		localEmails = emails_v;
	}
	
	if ([localEmails count] == 0) {
		UIView *noDataSplashView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
																		   self.tableView.bounds.size.width,
																		   self.tableView.bounds.size.height)];
		UIImageView *noDataSplash = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
		[noDataSplash setImage:[UIImage imageNamed:@"splash"]];
		
		[noDataSplashView addSubview:noDataSplash];
		[noDataSplash setCenter:CGPointMake( noDataSplashView.bounds.size.width/2 , noDataSplashView.bounds.size.height/2 - 100 )];
				
		return noDataSplashView;
	}
	
	return nil;
}



#pragma mark - MCSwipeTableViewCellDelegate

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode {
    NSLog(@"IndexPath : %@ - MCSwipeTableViewCellState : %d - MCSwipeTableViewCellMode : %d", [self.tableView indexPathForCell:cell], state, mode);
	
    if (mode == MCSwipeTableViewCellModeExit) {
//        _nbItems--;
		
		
		if ([tre02 isSelected]) {
			if (state == 3) {
				[self.tableView beginUpdates];
				[emails_x addObject:[emails objectAtIndex:[[self.tableView indexPathForCell:cell] row]]];
				[emails removeObjectAtIndex:[[self.tableView indexPathForCell:cell] row]];
				[self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView endUpdates];
			}
			if (state == 1) {
				[self.tableView beginUpdates];
				[emails_v addObject:[emails objectAtIndex:[[self.tableView indexPathForCell:cell] row]]];
				[emails removeObjectAtIndex:[[self.tableView indexPathForCell:cell] row]];
				[self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView endUpdates];
			}
		} else if ([tre01 isSelected]) {
			if (state == 1) {
				[self.tableView beginUpdates];
				[emails insertObject:[emails_x objectAtIndex:[[self.tableView indexPathForCell:cell] row]] atIndex:0];
				[emails_x removeObjectAtIndex:[[self.tableView indexPathForCell:cell] row]];
				[self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView endUpdates];
			}
			if (state == 2) {
				[self.tableView beginUpdates];
				[emails_v addObject:[emails_x objectAtIndex:[[self.tableView indexPathForCell:cell] row]]];
				[emails_x removeObjectAtIndex:[[self.tableView indexPathForCell:cell] row]];
				[self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView endUpdates];
			}
		} else if ([tre03 isSelected]) {
			if (state == 3) {
				[self.tableView beginUpdates];
				[emails insertObject:[emails_v objectAtIndex:[[self.tableView indexPathForCell:cell] row]] atIndex:0];
				[emails_v removeObjectAtIndex:[[self.tableView indexPathForCell:cell] row]];
				[self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView endUpdates];
			}
			if (state == 4) {
				[self.tableView beginUpdates];
				[emails_x addObject:[emails_v objectAtIndex:[[self.tableView indexPathForCell:cell] row]]];
				[emails_v removeObjectAtIndex:[[self.tableView indexPathForCell:cell] row]];
				[self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[self.tableView endUpdates];
			}
		}
		
    }
}







#pragma mark - Table View requirements

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if ([tre02 isSelected]) {
		return [emails count];
	} else if ([tre01 isSelected]) {
		return [emails_x count];
	} else if ([tre03 isSelected]) {
		return [emails_v count];
	}
	
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
//	static NSString *CellIdentifier = @"Cell";
#define CellIdentifier nil

	
	UILabel *fromLabel, *subjectLabel, *messageBodyLabel, *timeLabel, *counter;
	UIImageView *star, *discl, *unread;
	
			
//	UIFont *chevinLight = [UIFont fontWithName:@"ChevinCyrillic-Light" size:15.0];
//	UIFont *chevinLightItalic = [UIFont fontWithName:@"ChevinCyrillic-LightItalic" size:15.0];
	UIFont *chevinBold = [UIFont fontWithName:@"ChevinCyrillic-Bold" size:15.0];
	UIFont *chevinBoldSmallest = [UIFont fontWithName:@"ChevinCyrillic-Bold" size:12.0];
//	UIFont *chevinBoldItalic = [UIFont fontWithName:@"ChevinCyrillic-BoldItalic" size:15.0];
	UIFont *chevinMedium = [UIFont fontWithName:@"ChevinPro-Medium" size:15.0];
	UIFont *chevinMediumSmaller = [UIFont fontWithName:@"ChevinPro-Medium" size:14.0];
//	UIFont *chevinMediumSmallest = [UIFont fontWithName:@"ChevinPro-Medium" size:12.0];
	
	
	NSArray *localEmails = nil;
	
	if ([tre02 isSelected]) {
		localEmails = emails;
	} else if ([tre01 isSelected]) {
		localEmails = emails_x;
	} else if ([tre03 isSelected]) {
		localEmails = emails_v;
	}
	
	
	
	MCSwipeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
		
		
	fromLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 8.0, 200.0, 18.0)];
	fromLabel.font = chevinMedium;
	fromLabel.textColor = [UIColor darkGrayColor];
	fromLabel.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:fromLabel];
	
	
	timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(240.0, 8.0, 70.0, 18.0)];
	timeLabel.font = chevinMediumSmaller;
	timeLabel.textColor = [UIColor lightGrayColor];
	timeLabel.textAlignment = NSTextAlignmentRight;
	timeLabel.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:timeLabel];
	
	
	subjectLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 26.0, 220.0, 18.0)];
	subjectLabel.font = chevinBold;
	subjectLabel.textColor = [UIColor blackColor];
	subjectLabel.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:subjectLabel];
	
	
	messageBodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 46.0, 220.0, 36.0)];
	messageBodyLabel.font = chevinMedium;
	messageBodyLabel.textColor = [UIColor lightGrayColor];
	messageBodyLabel.numberOfLines = 2;
	messageBodyLabel.backgroundColor = [UIColor clearColor];
	[cell.contentView addSubview:messageBodyLabel];
	
	
	if ([[unreadEmails objectForKey:[[localEmails objectAtIndex:[indexPath row]] objectForKey:@"id"]] isEqualToString:@"unread"]) {
		unread = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
		[unread setImage:[UIImage imageNamed:@"unread"]];
		[unread setCenter:CGPointMake(15.0, 16.0)];
		[cell.contentView addSubview:unread];
	}
	
	
	if ([[[localEmails objectAtIndex:[indexPath row]] objectForKey:@"starred"] isEqual:@1]) {
		star = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
		[star setImage:[UIImage imageNamed:@"star-gold"]];
		[star setCenter:CGPointMake(15.0, 34.0)];
		[cell.contentView addSubview:star];
	} else {
//		[star setImage:[UIImage imageNamed:@"star-white"]];
	}


	if (![[[localEmails objectAtIndex:[indexPath row]] objectForKey:@"messages"] isEqual:@1]) {
		counter = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 16)];
		counter.font = chevinBoldSmallest;
		counter.textAlignment = NSTextAlignmentCenter;
		counter.textColor = [UIColor whiteColor];
		counter.numberOfLines = 1;
		counter.minimumScaleFactor = 0.5;
		counter.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		counter.adjustsFontSizeToFitWidth = YES;
		counter.backgroundColor = [UIColor clearColor];
		
		UIImageView *counterView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 16)];
		counterView.center = CGPointMake(290, 42);
		counterView.image = [UIImage imageNamed:@"count"];
		
		[counterView addSubview:counter];
		[cell.contentView addSubview:counterView];
	}
	
	
	discl = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 13, 13)];
	[discl setCenter:CGPointMake(305, 42)];
	[discl setImage:[UIImage imageNamed:@"disclosureInd"]];
	[cell.contentView addSubview:discl];
		
	
	
	NSString *fullFrom = [[localEmails objectAtIndex:[indexPath row]] objectForKey:@"from"];
	NSError  *error  = NULL;
	
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"(\\w[-._\\w]*\\w@\\w[-._\\w]*\\w\\.\\w{2,5}){1,1}|([\\w ]+)"
								  options:0
								  error:&error];
	
	NSRange range = [regex rangeOfFirstMatchInString:fullFrom
											   options:0
												 range:NSMakeRange(0, [fullFrom length])];
	
	NSString *shortFrom = [fullFrom substringWithRange:range];
		
	fromLabel.text = shortFrom;
	
	
	
	timeLabel.text = [self userVisibleDateTimeStringForRFC3339DateTimeString:[[localEmails objectAtIndex:[indexPath row]] objectForKey:@"received_at"]];
	subjectLabel.text = [NSString stringWithFormat:@"%@", [[localEmails objectAtIndex:[indexPath row]] objectForKey:@"subject"]];
	counter.text = [NSString stringWithFormat:@"%@", [[localEmails objectAtIndex:[indexPath row]] objectForKey:@"messages"]];
	messageBodyLabel.text = [NSString stringWithFormat:@"%@", [[localEmails objectAtIndex:[indexPath row]] objectForKey:@"body"]];
			
	
	[cell setDelegate:self];
	
	
	
	if ([tre02 isSelected]) {
		[cell setFirstStateIconName:@"check.png"
						 firstColor:[UIColor colorWithRed:98.0 / 255.0 green:217.0 / 255.0 blue:97.0 / 255.0 alpha:1.0]
				secondStateIconName:nil
						secondColor:nil
					  thirdIconName:@"cross.png"
						 thirdColor:[UIColor colorWithRed:227.0 / 255.0 green:38.0 / 255.0 blue:54.0 / 255.0 alpha:1.0]
					 fourthIconName:nil
						fourthColor:nil
		 ];
	} else if ([tre01 isSelected]) {
		[cell setFirstStateIconName:@"box.png"
						 firstColor:[UIColor colorWithRed:81.0 / 255.0 green:185.0 / 255.0 blue:219.0 / 255.0 alpha:1.0]
				secondStateIconName:@"check.png"
						secondColor:[UIColor colorWithRed:98.0 / 255.0 green:217.0 / 255.0 blue:97.0 / 255.0 alpha:1.0]
					  thirdIconName:nil
						 thirdColor:nil
					 fourthIconName:nil
						fourthColor:nil
		 ];
	} else if ([tre03 isSelected]) {
		[cell setFirstStateIconName:nil
						 firstColor:nil
				secondStateIconName:nil
						secondColor:nil
					  thirdIconName:@"box.png"
						 thirdColor:[UIColor colorWithRed:81.0 / 255.0 green:185.0 / 255.0 blue:219.0 / 255.0 alpha:1.0]
					 fourthIconName:@"cross.png"
						fourthColor:[UIColor colorWithRed:227.0 / 255.0 green:38.0 / 255.0 blue:54.0 / 255.0 alpha:1.0]
		 ];
	}
	
	
	[cell setMode:MCSwipeTableViewCellModeExit];

    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    [cell setBackgroundColor:[UIColor lightGrayColor]];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];


	
	
	
	if ([tre02 isSelected]
		&& [localEmails count] < [[pages objectForKey:@"total"] intValue]
		&& [[pages objectForKey:@"current_page"] intValue] != ceil([[pages objectForKey:@"total"] intValue] / [[pages objectForKey:@"per_page"] intValue])
		) {
		if ([indexPath row] == [localEmails count]-1) {
			[self reloadDataFromNetwork:[[pages objectForKey:@"current_page"] intValue]+1];
		}
	}
	
	
//	NSLog(@"from - %@", [NSString stringWithFormat:@"%@", [[localEmails objectAtIndex:[indexPath row]] objectForKey:@"from"]]);
	
	
	
	
	
	
	
	
	
    return cell;
}









#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//	self = [super initWithStyle]
    if (self) {
        // Custom initialization
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
		self.view = tableView;
		tableView.dataSource = self;
		tableView.delegate = self;
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
	
//	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
//	UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadDataFromNetwork)];
//	self.navigationItem.rightBarButtonItem = reloadButton;
	
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navBar.png"] forBarMetrics:UIBarMetricsDefault];
	
	
	UIView *treillageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 162, 32)];
	
	tre01 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 54, 32)];
	tre02 = [[UIButton alloc] initWithFrame:CGRectMake(54, 0, 54, 32)];
	tre03 = [[UIButton alloc] initWithFrame:CGRectMake(108, 0, 54, 32)];
	
	[tre01 addTarget:self action:@selector(tre01Fired) forControlEvents:UIControlEventTouchUpInside];
	[tre02 addTarget:self action:@selector(tre02Fired) forControlEvents:UIControlEventTouchUpInside];
	[tre03 addTarget:self action:@selector(tre03Fired) forControlEvents:UIControlEventTouchUpInside];
	
	[tre01 setBackgroundImage:[UIImage imageNamed:@"tre-x-norm.png"] forState:UIControlStateNormal];
	[tre01 setBackgroundImage:[UIImage imageNamed:@"tre-x-sel.png"] forState:UIControlStateSelected];
	[tre01 setBackgroundImage:[UIImage imageNamed:@"tre-x-hi.png"] forState:UIControlStateHighlighted];
	[tre01 setBackgroundImage:[UIImage imageNamed:@"tre-x-hi.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
	[tre01 setAdjustsImageWhenHighlighted:NO];
	
	[tre02 setBackgroundImage:[UIImage imageNamed:@"tre-mb-norm.png"] forState:UIControlStateNormal];
	[tre02 setBackgroundImage:[UIImage imageNamed:@"tre-mb-sel.png"] forState:UIControlStateSelected];
	[tre02 setBackgroundImage:[UIImage imageNamed:@"tre-mb-hi.png"] forState:UIControlStateHighlighted];
	[tre02 setBackgroundImage:[UIImage imageNamed:@"tre-mb-hi.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
	[tre02 setAdjustsImageWhenHighlighted:NO];
	[tre02 setSelected:YES];
	
	[tre03 setBackgroundImage:[UIImage imageNamed:@"tre-v-norm.png"] forState:UIControlStateNormal];
	[tre03 setBackgroundImage:[UIImage imageNamed:@"tre-v-sel.png"] forState:UIControlStateSelected];
	[tre03 setBackgroundImage:[UIImage imageNamed:@"tre-v-hi.png"] forState:UIControlStateHighlighted];
	[tre03 setBackgroundImage:[UIImage imageNamed:@"tre-v-hi.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
	[tre03 setAdjustsImageWhenHighlighted:NO];
	
	[treillageView addSubview:tre01];
	[treillageView addSubview:tre02];
	[treillageView addSubview:tre03];
	
	[[self navigationItem] setTitleView:treillageView];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	UIImageView *mailListView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, self.tableView.frame.size.height)];
	[mailListView setImage:[UIImage imageNamed:@"mailList.png"]];
	[[self tableView] setBackgroundView:mailListView];
		
	
	
//	searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//	searchBar.tintColor = [UIColor lightGrayColor];
//	searchBar.delegate = self;
//	self.tableView.tableHeaderView = searchBar;

	
	
	refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self
					   action:@selector(handleRefresh)
			 forControlEvents:UIControlEventValueChanged];
	[self.tableView addSubview:refreshControl];
	
	
	[self.tableView setRowHeight:85.0];
	
	
	
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
