//
//  CPThinTabBar.h
//  candpiosapp
//
//  Created by Stephen Birarda on 6/14/12.
//  Copyright (c) 2012 Coffee and Power Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPTabBarController.h"

#define BUTTON_WIDTH 55
#define LEFT_AREA_WIDTH 100

typedef enum {
    CPThinTabBarActionButtonStatePlus,
    CPThinTabBarActionButtonStateMinus,
    CPThinTabBarActionButtonStateUpdate,
    CPThinTabBarActionButtonStateQuestion
} CPThinTabBarActionButtonState;

@interface CPThinTabBar : UITabBar

@property (nonatomic, assign) UITabBarController *tabBarController;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, assign) CPThinTabBarActionButtonState actionButtonState;

- (void)moveGreenLineToSelectedIndex:(NSUInteger)selectedIndex;
- (void)toggleRightSide:(BOOL)shown;
- (void)refreshLastTab:(BOOL)loggedIn;

+ (UIImage *)backgroundImage;

@end
