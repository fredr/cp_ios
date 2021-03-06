//
//  LinkedAccountsTableViewController.m
//  candpiosapp
//
//  Created by Alexi (Love Machine) on 2012/03/20.
//  Copyright (c) 2012 Coffee and Power Inc. All rights reserved.
//

#import "LinkedAccountsTableViewController.h"
#import "PushModalViewControllerFromLeftSegue.h"

@interface LinkedAccountsTableViewController ()
@property (assign)BOOL postToLinkedIn;
@property (weak, nonatomic) IBOutlet UISwitch *postToLinkedInSwitch;

-(IBAction)gearPressed:(id)sender;
@end

@implementation LinkedAccountsTableViewController
@synthesize postToLinkedInSwitch = _postToLinkedInSwitch;
@synthesize postToLinkedIn = _postToLinkedIn;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SVProgressHUD show];
    
    [CPapi getLinkedInPostStatus:^(NSDictionary *json, NSError *error) {
        BOOL respError = [[json objectForKey:@"error"] boolValue];
        if (!error && !respError) {
            [self setPostToLinkedIn:[[[json objectForKey:@"payload"] objectForKey:@"post_to_linkedin"] boolValue]];
            [[self postToLinkedInSwitch] setOn:[self postToLinkedIn]];
            [SVProgressHUD dismiss];
        } else {
            [self dismissPushModalViewControllerFromLeftSegue];
            NSString *message = [json objectForKey:@"payload"];
            if (!message) {
                message = @"Oops. Something went wrong.";    
            }
            [SVProgressHUD dismissWithError:message 
                                 afterDelay:kDefaultDismissDelay];
        }
    }];

    self.tableView.separatorColor = [UIColor colorWithRed:(68/255.0) green:(68/255.0) blue:(68/255.0) alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidUnload
{
    [self setPostToLinkedInSwitch:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)gearPressed:(id)sender
{
    if ([self postToLinkedIn] != [[self postToLinkedInSwitch] isOn]) {
        [CPapi saveLinkedInPostStatus:[[self postToLinkedInSwitch] isOn]];
    }
    [self dismissPushModalViewControllerFromLeftSegue];
}

@end
