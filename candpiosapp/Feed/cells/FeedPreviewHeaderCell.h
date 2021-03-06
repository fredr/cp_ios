//
//  FeedPreviewHeaderCell.h
//  candpiosapp
//
//  Created by Stephen Birarda on 7/17/12.
//  Copyright (c) 2012 Coffee and Power Inc. All rights reserved.
//


@class FeedPreviewHeaderCell;

@protocol FeedPreviewHeaderCellDelegate <NSObject>

- (void)removeButtonPressed:(FeedPreviewHeaderCell *)cell;

@end


@interface FeedPreviewHeaderCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *venueNameLabel;
@property (nonatomic, assign) IBOutlet UILabel *relativeTimeLabel;
@property (nonatomic, weak) IBOutlet UIButton *removeButton;
@property (nonatomic, weak) id<FeedPreviewHeaderCellDelegate> delegate;

@end
