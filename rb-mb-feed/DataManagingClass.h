//
//  DataManagingClass.h
//  rb-mb-feed
//
//  Created by Marat Saytakov on 14.09.13.
//  Copyright (c) 2013 Marat Saytakov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSwipeTableViewCell.h"

typedef NS_ENUM(NSUInteger, DMCurrentState){
    DMCurrentStateTrash = 0,
    DMCurrentStateInbox,
    DMCurrentStateDone
};

@protocol DataManagerDelegate <NSObject>

@end


@interface DataManagingClass : NSObject <MCSwipeTableViewCellDelegate>

@property id delegate;

@property (nonatomic) NSInteger currentState; // 0 = trash, 1 = inbox, 2 = done
@property (nonatomic) NSInteger currentPage;

@property (nonatomic, strong) NSMutableArray *currentBox;
@property (nonatomic, strong) NSMutableArray *inbox;
@property (nonatomic, strong) NSMutableArray *trash;
@property (nonatomic, strong) NSMutableArray *done;

@property (nonatomic) NSDictionary *pages;

- (void)startLoadingData;
- (void)askForMoreItemsWhileIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)messagesCount;
- (NSDictionary *)messageForIndexPath:(NSIndexPath *)indexPath;
- (void)makeReadMessageAtIndexPath:(NSIndexPath *)indexPath;


@end
