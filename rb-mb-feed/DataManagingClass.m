//
//  DataManagingClass.m
//  rb-mb-feed
//
//  Created by Marat Saytakov on 14.09.13.
//  Copyright (c) 2013 Marat Saytakov. All rights reserved.
//

#import "DataManagingClass.h"
#import "FirstViewController.h"

@implementation DataManagingClass

@synthesize delegate, currentBox, currentState, currentPage, pages, inbox, trash, done;



#pragma mark - Data

- (void)setCurrentState:(NSInteger)newCurrentState
{
	currentState = newCurrentState;
	
	if (currentState == DMCurrentStateTrash) {
		currentBox = trash;
	} else if (currentState == DMCurrentStateInbox) {
		currentBox = inbox;
	} else if (currentState == DMCurrentStateDone) {
		currentBox = done;
	}
	
	[delegate didDoneManagingData];
}


- (NSInteger)messagesCount
{
	return [currentBox count];
}


- (NSDictionary *)messageForIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *message = [[NSMutableDictionary alloc] init];
	
	NSInteger row = [indexPath row];
	
	[message setValue:[[currentBox objectAtIndex:row] objectForKey:@"id"] forKey:@"id"];
		
	[message setValue:[self parseAddressesFrom:[[currentBox objectAtIndex:row] objectForKey:@"from"]
											to:[[currentBox objectAtIndex:row] objectForKey:@"to"]] forKey:@"fromto"];
	
	[message setValue:[[currentBox objectAtIndex:row] objectForKey:@"subject"] forKey:@"subject"];
	
	[message setValue:[[currentBox objectAtIndex:row] objectForKey:@"body"] forKey:@"body"];
	
	[message setValue:[self friendlyDateTimeViaRFC3339DateTimeString:[[currentBox objectAtIndex:row] objectForKey:@"received_at"]] forKey:@"time"];
	
	[message setValue:[NSNumber numberWithInteger:[[[currentBox objectAtIndex:row] objectForKey:@"starred"] integerValue]] forKey:@"starred"];
	[message setValue:[NSNumber numberWithInteger:[[[currentBox objectAtIndex:row] objectForKey:@"unread"] integerValue]] forKey:@"unread"];
	[message setValue:[NSNumber numberWithInteger:[[[currentBox objectAtIndex:row] objectForKey:@"messages"] integerValue]] forKey:@"count"];
	
	return message;
}


- (void)makeReadMessageAtIndexPath:(NSIndexPath *)indexPath
{
	[[currentBox objectAtIndex:[indexPath row]] setValue:[NSNumber numberWithInt:0] forKey:@"unread"];
}


- (void)startLoadingData
{
	[self reloadDataFromNetwork:0];
}


- (void)askForMoreItemsWhileIndexPath:(NSIndexPath *)indexPath
{
	if (currentState == DMCurrentStateInbox
		&& [currentBox count] < [[pages objectForKey:@"total"] intValue]
		&& [[pages objectForKey:@"current_page"] intValue] != ceil([[pages objectForKey:@"total"] intValue] / [[pages objectForKey:@"per_page"] intValue])
		&& [indexPath row] == [inbox count]-1
		) {
			[self reloadDataFromNetwork:[[pages objectForKey:@"current_page"] intValue]+1];
	}
}



#pragma mark - Networking


- (void)reloadDataFromNetwork:(int)forPage
{
	NSURL *dataURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://rocket-ios.herokuapp.com/emails.json?page=%d", forPage]];
    NSURLRequest *dataRequest = [NSURLRequest requestWithURL:dataURL
												 cachePolicy:NSURLRequestReloadIgnoringCacheData
											 timeoutInterval:15];
	
	
	
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
		
		if (!error) {

			NSError *JSONErr = nil;
			
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:&JSONErr];
			
			if (!JSONErr) {
				
				pages = [result objectForKey:@"pagination"];
				
				if (!inbox)
					inbox = [[NSMutableArray alloc] init];
				
				if (!trash)
					trash = [[NSMutableArray alloc] init];
				
				if (!done)
					done = [[NSMutableArray alloc] init];
				
				if (!currentBox) {
					currentBox = inbox;
					currentState = DMCurrentStateInbox;
				}
								
				if (forPage == 0) {
					[inbox removeAllObjects];
					[trash removeAllObjects];
					[done removeAllObjects];
				}
				
				
				for (NSDictionary *d in [result objectForKey:@"emails"]) {
					[inbox addObject:[d mutableCopy]];
				}
				
				for (int i = 0; i < [inbox count]; i++) {
					if (![[inbox objectAtIndex:i] objectForKey:@"unread"])
						[[inbox objectAtIndex:i] setValue:[NSNumber numberWithInt:1] forKey:@"unread"];
				}
				
			} else {
				NSLog(@"JSON parsing error - %@", JSONErr);
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				
				[delegate didDoneManagingData];
			});
			
		} else {
			NSLog(@"Network error - %@", error);
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[delegate didDoneManagingData];

			[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
			
		});
		
	});
	
}



#pragma mark - Parsing

- (NSString *)parseAddressesFrom:(NSString *)fromField to:(NSString *)toField
{
	NSError *error = nil;
	
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"(\\w[-._\\w]*\\w@\\w[-._\\w]*\\w\\.\\w{2,5}){1,1}|([\\w .]+)[^ <]"
								  options:0
								  error:&error];
	
	NSRange range = [regex rangeOfFirstMatchInString:fromField
											 options:0
											   range:NSMakeRange(0, [fromField length])];
	
	NSString *shortFrom = [fromField substringWithRange:range];
	
	NSMutableString *fromToLabelContent = [NSMutableString stringWithString:shortFrom];
	
	NSArray *commaSeparated = [toField componentsSeparatedByString:@", "];
	
	if ([commaSeparated count] <= 1) {
		[fromToLabelContent appendString:@" to Me"];
	} else {
		[fromToLabelContent appendFormat:@" to %d others", [commaSeparated count]];
	}
	
	return fromToLabelContent;
}


- (NSString *)friendlyDateTimeViaRFC3339DateTimeString:(NSString *)rfc3339DateTimeString {
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
		
		if ([date timeIntervalSinceNow] < -86400.0) {
			[userVisibleDateFormatter setDateFormat:@"dd MMM"];
		} else {
			[userVisibleDateFormatter setDateFormat:@"HH':'mm"];
		}
		
        userVisibleDateTimeString = [userVisibleDateFormatter stringFromDate:date];
    }
    return userVisibleDateTimeString;
}



#pragma mark - MCSwipeTableViewCellDelegate

- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didTriggerState:(MCSwipeTableViewCellState)state withMode:(MCSwipeTableViewCellMode)mode
{
//	NSLog(@"IndexPath : %@ - MCSwipeTableViewCellState : %d - MCSwipeTableViewCellMode : %d", [[delegate tableView] indexPathForCell:cell], state, mode);
	
	NSInteger row = [[[delegate tableView] indexPathForCell:cell] row];
	
    if (mode == MCSwipeTableViewCellModeExit) {
		if (currentState == DMCurrentStateInbox) {
			if (state == 1) {
				[[delegate tableView] beginUpdates];
				[done addObject:[inbox objectAtIndex:row]];
				[inbox removeObjectAtIndex:row];
				[[delegate tableView] deleteRowsAtIndexPaths:@[[[delegate tableView] indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[[delegate tableView] endUpdates];
			}
			if (state == 3) {
				[[delegate tableView] beginUpdates];
				[trash addObject:[inbox objectAtIndex:row]];
				[inbox removeObjectAtIndex:row];
				[[delegate tableView] deleteRowsAtIndexPaths:@[[[delegate tableView] indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[[delegate tableView] endUpdates];
			}
		} else if (currentState == DMCurrentStateTrash) {
			if (state == 1) {
				[[delegate tableView] beginUpdates];
				[inbox insertObject:[trash objectAtIndex:row] atIndex:0];
				[trash removeObjectAtIndex:row];
				[[delegate tableView] deleteRowsAtIndexPaths:@[[[delegate tableView] indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[[delegate tableView] endUpdates];
			}
			if (state == 2) {
				[[delegate tableView] beginUpdates];
				[done addObject:[trash objectAtIndex:row]];
				[trash removeObjectAtIndex:row];
				[[delegate tableView] deleteRowsAtIndexPaths:@[[[delegate tableView] indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[[delegate tableView] endUpdates];
			}
		} else if (currentState == DMCurrentStateDone) {
			if (state == 3) {
				[[delegate tableView] beginUpdates];
				[inbox insertObject:[done objectAtIndex:row] atIndex:0];
				[done removeObjectAtIndex:row];
				[[delegate tableView] deleteRowsAtIndexPaths:@[[[delegate tableView] indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[[delegate tableView] endUpdates];
			}
			if (state == 4) {
				[[delegate tableView] beginUpdates];
				[trash addObject:[done objectAtIndex:row]];
				[done removeObjectAtIndex:row];
				[[delegate tableView] deleteRowsAtIndexPaths:@[[[delegate tableView] indexPathForCell:cell]] withRowAnimation:UITableViewRowAnimationFade];
				[[delegate tableView] endUpdates];
			}
		}
    }
}



@end
