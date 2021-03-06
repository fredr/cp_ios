//
//  UserProfileViewController.m
//  candpiosapp
//
//  Created by Stephen Birarda on 2/1/12.
//  Copyright (c) 2012 Coffee and Power Inc. All rights reserved.
//

#import "UserProfileViewController.h"
#import "FoursquareAPIRequest.h"
#import "AFJSONRequestOperation.h"
#import "GRMustache.h"
#import "VenueInfoViewController.h"
#import "GTMNSString+HTML.h"
#import "UserProfileLinkedInViewController.h"



@interface UserProfileViewController() <UIWebViewDelegate, UIActionSheetDelegate, GRMustacheTemplateDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UILabel *checkedIn;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIView *userCard;
@property (nonatomic, weak) IBOutlet UIImageView *cardImage;
@property (nonatomic, weak) IBOutlet UILabel *cardStatus;
@property (nonatomic, weak) IBOutlet UILabel *cardNickname;
@property (nonatomic, weak) IBOutlet UILabel *cardJobPosition;
@property (nonatomic, weak) IBOutlet UIView *venueView;
@property (nonatomic, weak) IBOutlet UIButton *venueViewButton;
@property (nonatomic, weak) IBOutlet UILabel *venueName;
@property (nonatomic, weak) IBOutlet UILabel *venueAddress;
@property (nonatomic, weak) IBOutlet UIImageView *venueOthersIcon;
@property (nonatomic, weak) IBOutlet UILabel *venueOthers;
@property (nonatomic, weak) IBOutlet UIView *availabilityView;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *hoursAvailable;
@property (nonatomic, weak) IBOutlet UILabel *minutesAvailable;
@property (weak, nonatomic) IBOutlet UIView *resumeView;
@property (weak, nonatomic) IBOutlet UILabel *resumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *resumeRate;
@property (weak, nonatomic) IBOutlet UILabel *resumeEarned;
@property (weak, nonatomic) IBOutlet UILabel *loveReceived;
@property (weak, nonatomic) IBOutlet UIWebView *resumeWebView;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *minusButton;
@property (weak, nonatomic) IBOutlet UIButton *f2fButton;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIButton *reviewButton;
@property (weak, nonatomic) IBOutlet UIImageView *goMenuBackground;
@property (nonatomic, assign) int othersAtPlace;
@property (nonatomic, strong) NSNumber *templateCounter;
@property (nonatomic, assign) NSInteger selectedFavoriteVenueIndex;
@property (weak, nonatomic) IBOutlet UILabel *propNoteLabel;
@property (nonatomic, assign) BOOL mapAndDistanceLoaded;
@property (nonatomic, strong) NSString* preBadgesHTML;
@property (nonatomic, strong) NSString* postBadgesHTML;
@property (nonatomic, strong) NSString* badgesHTML;

-(NSString *)htmlStringWithResumeText;
-(IBAction)plusButtonPressed:(id)sender;
-(IBAction)minusButtonPressed:(id)sender;
-(IBAction)venueViewButtonPressed:(id)sender;
-(IBAction)chatButtonPressed:(id)sender;

@end

@implementation UserProfileViewController

@synthesize scrollView = _scrollView;
@synthesize checkedIn = _checkedIn;
@synthesize mapView = _mapView;
@synthesize user = _user;
@synthesize userCard = _userCard;
@synthesize cardImage = _cardImage;
@synthesize cardStatus = _cardStatus;
@synthesize cardNickname = _cardNickname;
@synthesize distanceLabel = _distanceLabel;
@synthesize venueView = _venueView;
@synthesize venueViewButton = _venueViewButton;
@synthesize venueName = _venueName;
@synthesize venueAddress = venueAddress;
@synthesize venueOthersIcon = _venueOthersIcon;
@synthesize venueOthers = venueOthers;
@synthesize availabilityView = _availabilityView;
@synthesize hoursAvailable = _hoursAvailable;
@synthesize minutesAvailable = _minutesAvailable;
@synthesize resumeView = _resumeView;
@synthesize resumeLabel = _resumeLabel;
@synthesize resumeRate = _resumeRate;
@synthesize resumeEarned = _resumeEarned;
@synthesize loveReceived = _loveReceived;
@synthesize resumeWebView = _resumeWebView;
@synthesize plusButton = _plusButton;
@synthesize minusButton = _minusButton;
@synthesize f2fButton = _f2fButton;
@synthesize chatButton = _chatButton;
@synthesize payButton = _payButton;
@synthesize reviewButton = _reviewButton;
@synthesize goMenuBackground = _goMenuBackground;
@synthesize cardJobPosition = _cardJobPosition;
@synthesize isF2FInvite = _isF2FInvite;
@synthesize othersAtPlace = _othersAtPlace;
@synthesize templateCounter = _templateCounter;
@synthesize selectedFavoriteVenueIndex = _selectedFavoriteVenueIndex;
@synthesize propNoteLabel = _propNoteLabel;
@synthesize mapAndDistanceLoaded = _mapAndDistanceLoaded;
@synthesize preBadgesHTML, postBadgesHTML, badgesHTML;

BOOL firstLoad = YES;
UITapGestureRecognizer* _tapRecon = nil;

static GRMustacheTemplate *preBadgesTemplate;
static GRMustacheTemplate *badgesTemplate;
static GRMustacheTemplate *postBadgesTemplate;

+ (GRMustacheTemplate*) preBadgesTemplate {
    if (!preBadgesTemplate) { 
        NSError *error;
        preBadgesTemplate = [GRMustacheTemplate templateFromResource:@"UserResume-prebadges" bundle:nil error:&error];
    }
    return preBadgesTemplate;
}
+ (GRMustacheTemplate*) postBadgesTemplate {
    if (!postBadgesTemplate) { 
        postBadgesTemplate = [GRMustacheTemplate templateFromResource:@"UserResume-postbadges" bundle:nil error:NULL];
    }
    return postBadgesTemplate;
}
+ (GRMustacheTemplate*) badgesTemplate {
    if (!badgesTemplate) { 
        badgesTemplate = [GRMustacheTemplate templateFromResource:@"UserResume-badges" bundle:nil error:NULL];
    }
    return badgesTemplate;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Profile"
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:nil
                                                                                action:nil];
    }
    return self;
}

- (void)setUser:(User *)newUser 
{
    // assign the user
    _user = newUser;
    
    // reset the resume
    self.preBadgesHTML = nil;
    self.badgesHTML = nil;
    self.postBadgesHTML = nil;
    
    // reset the stats
    self.resumeEarned.text = @"";
    self.loveReceived.text = @"";
    self.resumeWebView.alpha = 0.0;
    if (_user) {
        // set the booleans this VC uses in later control statements
        firstLoad = YES;
        self.mapAndDistanceLoaded = NO;
        
        // set the card image to the user's profile image
        [CPUIHelper profileImageView:self.cardImage
                 withProfileImageUrl:self.user.photoURL];
        
        // hide the go menu if this profile is current user's profile
        if (self.user.userID == [CPUserDefaultsHandler currentUser].userID || self.isF2FInvite) {
            for (NSNumber *viewID in [NSArray arrayWithObjects:[NSNumber numberWithInt:1005], [NSNumber numberWithInt:1006], [NSNumber numberWithInt:1007], [NSNumber numberWithInt:1008], [NSNumber numberWithInt:1009], [NSNumber numberWithInt:1010], [NSNumber numberWithInt:1020], nil]) {
                [self.view viewWithTag:[viewID intValue]].alpha = 0.0;
            }
        } else {
            for (NSNumber *viewID in [NSArray arrayWithObjects:[NSNumber numberWithInt:1005], [NSNumber numberWithInt:1006], [NSNumber numberWithInt:1007], [NSNumber numberWithInt:1008], [NSNumber numberWithInt:1009], [NSNumber numberWithInt:1010], [NSNumber numberWithInt:1020], nil]) {
                [self.view viewWithTag:[viewID intValue]].alpha = 1.0;
            }
            self.minusButton.alpha = 0.0;
            
        }
        
        // update labels
        // set the labels on the user business card
        self.cardNickname.text = self.user.nickname;
        
        [self setUserStatusWithQuotes:self.user.status];
        
        self.cardJobPosition.text = self.user.jobTitle;
        
        // set the navigation controller title to the user's nickname
        self.title = self.user.nickname;  
        
        // don't allow scrolling in the mustache view until it's loaded
        self.resumeWebView.userInteractionEnabled = NO;
        
        // check if this is an F2F invite
        if (self.isF2FInvite) {
            // we're in an F2F invite
            [self placeUserDataOnProfile];
        } else {  
            // lock the scrollView
            self.scrollView.scrollEnabled = NO;
            // put three animated dots after the Loading Resume text
            [CPUIHelper animatedEllipsisAfterLabel:self.resumeLabel start:YES];
            [CPUIHelper animatedEllipsisAfterLabel:self.checkedIn start:YES];
            
            // get a user object with resume data
            [self.user loadUserResumeData:^(NSError *error) {
                if (!error) {
                    NSLog(@"Received resume response.");
                    // unlock the scrollView
                    self.scrollView.scrollEnabled = YES;
                    // resume has loaded, change the label and remove the animated dots
                    [CPUIHelper animatedEllipsisAfterLabel:self.resumeLabel start:NO];
                    [CPUIHelper animatedEllipsisAfterLabel:self.checkedIn start:NO];
                    self.resumeLabel.text = @"Resume";
                    
                    [self placeUserDataOnProfile];
                } else {
                    // error checking for load of user
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Resume Load" 
                                                                    message:@"An error has occurred while loading the resume.  Try again later." delegate:nil 
                                                          cancelButtonTitle:@"OK" 
                                                          otherButtonTitles:nil];
                    [alert show];
                    [CPUIHelper animatedEllipsisAfterLabel:self.resumeLabel start:NO];
                    [CPUIHelper animatedEllipsisAfterLabel:self.checkedIn start:NO];
                    NSLog(@"Error loading resume: %@", error);
                }
            }];
        }
        
        // hide the venue info until we load the resume data
        self.venueView.alpha = 0.0;
        self.availabilityView.alpha = 0.0;
        
    }
}

#pragma mark - View lifecycle

- (void)addGradientWithFrame:(CGRect)frame locations:(NSArray*)locations colors:(NSArray*)colors 
{
    // add gradient overlay
    UIView *overlay = [[UIView alloc] initWithFrame:frame];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = overlay.bounds;
    gradient.colors = colors;
    gradient.locations = locations;
    [overlay.layer insertSublayer:gradient atIndex:0];
    [self.scrollView insertSubview:overlay atIndex:1];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // when pulling the scroll view top down, present the map
    self.mapView.frame = CGRectUnion(self.mapView.frame, 
                                     CGRectOffset(self.mapView.frame, 0, -self.mapView.frame.size.height));
    // add the blue overlay gradient in front of the map
    [self addGradientWithFrame:self.mapView.frame 
                     locations:[NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.25], 
                                [NSNumber numberWithFloat:0.30], 
                                [NSNumber numberWithFloat:0.5], 
                                [NSNumber numberWithFloat:0.90], 
                                [NSNumber numberWithFloat:1.0], 
                                nil] 
                        colors:[NSArray arrayWithObjects:
                                (id)[[UIColor colorWithRed:0.67 green:0.83 blue:0.94 alpha:1.0] CGColor],
                                (id)[[UIColor colorWithRed:0.67 green:0.83 blue:0.94 alpha:0.75] CGColor],
                                (id)[[UIColor colorWithRed:0.40 green:0.62 blue:0.64 alpha:0.4] CGColor],
                                (id)[[UIColor colorWithRed:0.67 green:0.83 blue:0.94 alpha:0.75] CGColor],
                                (id)[[UIColor colorWithRed:0.67 green:0.83 blue:0.94 alpha:1.0] CGColor],
                                nil]
     ];
        
    // set LeagueGothic font where applicable
    [CPUIHelper changeFontForLabel:self.checkedIn toLeagueGothicOfSize:24];
    [CPUIHelper changeFontForLabel:self.resumeLabel toLeagueGothicOfSize:24];
    [CPUIHelper changeFontForLabel:self.cardNickname toLeagueGothicOfSize:28];
    
    // set the paper background color where applicable
    UIColor *paper = [UIColor colorWithPatternImage:[UIImage imageNamed:@"paper-texture.jpg"]];
    self.userCard.backgroundColor = paper;
    self.resumeView.backgroundColor = paper;
    self.resumeWebView.opaque = NO;
    self.resumeWebView.backgroundColor = paper;
    
    // make sure there's a shadow on the userCard and resumeView
    [CPUIHelper addShadowToView:self.userCard color:[UIColor blackColor] offset:CGSizeMake(2, 2) radius:3 opacity:0.38];
    [CPUIHelper addShadowToView:self.resumeView color:[UIColor blackColor] offset:CGSizeMake(2, 2) radius:3 opacity:0.38];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar removeGestureRecognizer:_tapRecon];
    _tapRecon = nil;
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!_tapRecon){
        _tapRecon = [[UITapGestureRecognizer alloc]
                     initWithTarget:self action:@selector(navigationBarTitleTap:)];
        _tapRecon.numberOfTapsRequired = 1;
        _tapRecon.cancelsTouchesInView = NO;
        [self.navigationController.navigationBar addGestureRecognizer:_tapRecon];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setCheckedIn:nil];
    [self setMapView:nil];
    [self setUserCard:nil];
    [self setCardImage:nil];
    [self setCardStatus:nil];
    [self setCardNickname:nil];
    [self setVenueView:nil];
    [self setVenueViewButton:nil];
    [self setVenueName:nil];
    [self setVenueAddress:nil];
    [self setVenueOthersIcon:nil];
    [self setVenueOthers:nil];
    [self setAvailabilityView:nil];
    [self setDistanceLabel:nil];
    [self setHoursAvailable:nil];
    [self setMinutesAvailable:nil];
    [self setResumeLabel:nil];
    [self setResumeView:nil];
    [self setResumeRate:nil];
    [self setResumeEarned:nil];
    [self setLoveReceived:nil];
    [self setScrollView:nil];
    [self setResumeWebView:nil];
    [self setPlusButton:nil];
    [self setMinusButton:nil];
    [self setF2fButton:nil];
    [self setChatButton:nil];
    [self setPayButton:nil];
    [self setReviewButton:nil];
    [self setGoMenuBackground:nil];
    [self setPropNoteLabel:nil];
    
    [self.navigationController.navigationBar removeGestureRecognizer:_tapRecon];
    _tapRecon = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)updateLastUserCheckin
{
    if (firstLoad) {
        // if the user is checked in show how much longer they'll be available for
        if ([self.user.checkoutEpoch timeIntervalSinceNow] > 0) {
            self.checkedIn.text = @"Checked in";
            // get the number of seconds until they'll checkout
            NSTimeInterval secondsToCheckout = [self.user.checkoutEpoch timeIntervalSinceNow];
            // convert to minutes and then hours + minutes to next our
            int minutesToCheckout = floor(secondsToCheckout / 60.0);
            int hoursToCheckout = floor(minutesToCheckout / 60.0);
            int minutesToHour = minutesToCheckout % 60;
            
            // only show hours if there's at least one
            if (hoursToCheckout > 0) {
                self.hoursAvailable.text = [NSString stringWithFormat:@"%d hrs", hoursToCheckout];
            } else {
                self.hoursAvailable.text = @"";
            }            
            self.minutesAvailable.text = [NSString stringWithFormat:@"%d mins", minutesToHour];
            // show the availability view
            self.availabilityView.alpha = 1.0;
            [UIView animateWithDuration:0.4 animations:^{self.availabilityView.alpha = 1.0;}];
        } else {
            // change the label since the user isn't here anymore
            self.checkedIn.text = @"Last checked in";
            
            // otherwise don't show the availability view
            self.availabilityView.alpha = 0.0;
            self.hoursAvailable.text = @"";
            self.minutesAvailable.text = @"";
        }
    }
    
    self.venueName.text = self.user.placeCheckedIn.name;
    self.venueAddress.text = self.user.placeCheckedIn.address;
    
    self.othersAtPlace = self.user.checkedIn ? self.user.placeCheckedIn.checkinCount - 1 : self.user.placeCheckedIn.checkinCount;
    
    if (firstLoad) {
        if (self.othersAtPlace == 0) {
            // hide the little man, nobody else is here
            self.venueOthersIcon.alpha = 0.0;
            self.venueOthers.text = @"";
            
        } else {
            // show the little man
            self.venueOthersIcon.alpha = 1.0;
            // otherwise put 1 other or x others here now
            self.venueOthers.text = [NSString stringWithFormat:@"%d %@ here now", self.othersAtPlace, self.othersAtPlace == 1 ? @"other" : @"others"];
        }
        
        firstLoad = NO;
    }    
    
    // animate the display of the venueView and availabilityView
    // if they aren't already on screen
    [UIView animateWithDuration:0.4 animations:^{self.venueView.alpha = 1.0;}];
}

- (void)updateMapAndDistanceToUser
{
    if (!self.mapAndDistanceLoaded) {
        // make an MKCoordinate region for the zoom level on the map
        MKCoordinateRegion region = MKCoordinateRegionMake(self.user.location, MKCoordinateSpanMake(0.005, 0.005));
        [self.mapView setRegion:region];
        
        // this will always be the point on iPhones up to iPhone4
        // if this needs to be used on iPad we'll need to do this programatically or use an if-else
        CGPoint rightAndUp = CGPointMake(84, 232);
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:rightAndUp toCoordinateFromView:self.mapView];
        [self.mapView setCenterCoordinate:coordinate animated:NO];
        
        CLLocation *myLocation = [CPAppDelegate locationManager].location;
        CLLocation *otherUserLocation = [[CLLocation alloc] initWithLatitude:self.user.location.latitude longitude:self.user.location.longitude];
        NSString *distance = [CPUtils localizedDistanceofLocationA:myLocation awayFromLocationB:otherUserLocation];
        self.distanceLabel.text = distance;
        
        self.mapAndDistanceLoaded = YES;
    }
}

- (void)setUserStatusWithQuotes:(NSString *)status
{
    if ([self.user.status length] > 0 && self.user.checkedIn) {
        self.cardStatus.text = [NSString stringWithFormat:@"\"%@\"", status];
    }
}

- (void)placeUserDataOnProfile
{    
    
    // dismiss the SVProgressHUD if it's up
    [SVProgressHUD dismiss];
    
    [CPUIHelper profileImageView:self.cardImage
             withProfileImageUrl:self.user.photoURL];
    self.cardNickname.text = self.user.nickname;

    self.title = self.user.nickname;  

    self.cardJobPosition.text = self.user.jobTitle;
    
    [self setUserStatusWithQuotes:self.user.status];
        
    // if the user has an hourly rate then put it, otherwise it comes up as N/A
    if (self.user.hourlyRate) {
        self.resumeRate.text = self.user.hourlyRate;
    }

    self.resumeEarned.text = [NSString stringWithFormat:@"%d", self.user.totalHours];
    self.loveReceived.text = [self.user.reviews objectForKey:@"love_received"];
    
    [self loadBadgesAsync];
    // load html into the bottom of the resume view for all the user data
    NSString *htmlString = [self htmlStringWithResumeText];
    [self updateResumeWithHTML:htmlString];
    
    [self updateLastUserCheckin];
    [self updateMapAndDistanceToUser];
}

- (NSString *)htmlStringWithResumeText {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.user, @"user",nil];
    
    if (!self.preBadgesHTML) { 
        GRMustacheTemplate *template = [UserProfileViewController preBadgesTemplate];
        template.delegate = self;
        self.preBadgesHTML = [template renderObject:dictionary];
    }

    if (self.user.badges.count > 0) { 
        GRMustacheTemplate *template = [UserProfileViewController badgesTemplate];
        template.delegate = self;
        self.badgesHTML = [template renderObject:dictionary];        
    } else {
        self.badgesHTML = @"";
    }

    if (!self.postBadgesHTML) { 
        NSMutableArray *reviews = [NSMutableArray arrayWithCapacity:[[self.user.reviews objectForKey:@"rows"] count]];
        for (NSDictionary *review in [self.user.reviews objectForKey:@"rows"]) {
            NSMutableDictionary *mutableReview = [NSMutableDictionary dictionaryWithDictionary:review];
            
            NSInteger rating = [[review objectForKey:@"rating"] integerValue];
            if (rating < 0) {
                [mutableReview setObject:[NSNumber numberWithBool:YES]
                                  forKey:@"isNegative"];
            } else if (rating > 0) {
                [mutableReview setObject:[NSNumber numberWithBool:YES]
                                  forKey:@"isPositive"];
            }
            
            // is this love?
            NSInteger loveNumber = [[review objectForKey:@"is_love"] integerValue];
            if ( loveNumber == 1) {
                [mutableReview setObject:[NSNumber numberWithBool:YES] forKey:@"isLove"];
            }
            
            [mutableReview setObject:[[review objectForKey:@"review"] gtm_stringByUnescapingFromHTML]
                              forKey:@"review"];
            
            [reviews addObject:mutableReview];
        }
        
        GRMustacheTemplate *template = [UserProfileViewController postBadgesTemplate];
        template.delegate = self;
        [dictionary setValue:reviews forKey:@"reviews"];
        [dictionary setValue:[NSNumber numberWithBool:reviews.count > 0] forKey:@"hasAnyReview"];
        self.postBadgesHTML = [template renderObject:dictionary];
    }
    return [NSString stringWithFormat:@"%@%@%@", self.preBadgesHTML, self.badgesHTML,self.postBadgesHTML];
}

- (void) loadBadgesAsync
{
    if (self.user.smartererName.length > 0) {
        // Get user's current badges asynchronously from smarterer if they've linked their account
        NSString *urlString = [NSString stringWithFormat:@"https://smarterer.com/api/badges/%@", self.user.smartererName];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation 
                                             JSONRequestOperationWithRequest:request 
                                             success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) 
                                             {
                                                 // load our badges
                                                 NSArray *returnedBadges = [JSON objectForKey:@"badges"];
                                                 NSMutableArray *badges = [[NSMutableArray alloc] init];
                                                 for (NSDictionary *badge in returnedBadges) {
                                                     NSString *badgeURL = [[badge objectForKey:@"badge"] objectForKey:@"image"];
                                                     [badges addObject:[NSDictionary dictionaryWithObjectsAndKeys:badgeURL,@"badgeURL", nil]];
                                                 }
                                                 self.user.badges = badges;
                                                 // re-render the resume
                                                 [self updateResumeWithHTML:[self htmlStringWithResumeText]];                                                 
                                             } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) 
                                             {
                                                 NSLog(@"%@", error.localizedDescription);
                                             }];
        [operation start];
    }
}
- (void) updateResumeWithHTML:(NSString*)html 
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.resumeWebView loadHTMLString:html baseURL:baseURL];
    NSLog(@"HTML updated.");
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    
    if ([url.scheme isEqualToString:@"favorite-venue-id"]) {
        NSInteger venueID = [url.host integerValue];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"venueID == %d", venueID];
        NSMutableArray *venues = self.user.favoritePlaces;
        [venues filterUsingPredicate:predicate];
        CPVenue *place = [venues objectAtIndex:0];
        
        CPVenue *activeVenue = [[CPAppDelegate settingsMenuController].mapTabController venueFromActiveVenues:venueID];
        if (activeVenue) {
            // we had this venue in the map dictionary of activeVenues so use that
            place = activeVenue;
        }
        
        VenueInfoViewController *venueVC = [[UIStoryboard storyboardWithName:@"VenueStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
        venueVC.venue = place;
        
        [self.navigationController pushViewController:venueVC animated:YES];
        
        return NO;
    }
    if ([url.scheme isEqualToString:@"linkedin-view"]) {
        [self performSegueWithIdentifier:@"ShowLinkedInProfileWebView" sender:self];
        return NO;
    }
    
    if ([url.scheme isEqualToString:@"sponsor-resume"]) {
        
        User *user = [[User alloc] init];
        user.nickname = self.user.sponsorNickname;
        user.userID = self.user.sponsorId;
        
        // instantiate a UserProfileViewController
        UserProfileViewController *vc = [[UIStoryboard storyboardWithName:@"UserProfileStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
        vc.user = user;
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    }


    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    // tell the webview not to scroll to top when status bar is clicked
    aWebView.scrollView.scrollsToTop = NO;
    aWebView.userInteractionEnabled = YES;
    
    // resize the webView frame depending on the size of the content
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    aWebView.frame = frame;
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    aWebView.frame = frame;
    
    CGRect resumeFrame = self.resumeView.frame;
    resumeFrame.size.height = self.resumeWebView.frame.origin.y + fittingSize.height;
    self.resumeView.frame = resumeFrame;

    [CPUIHelper addShadowToView:self.resumeView color:[UIColor blackColor] offset:CGSizeMake(2, 2) radius:3 opacity:0.38];
    
    // if this is an f2f invite we need some extra height in the scrollview content size
    double f2fbar = 0;
    if (self.isF2FInvite) {
        f2fbar = 81;
    }
    
    // set the scrollview content size to accomodate for the resume data
    self.scrollView.contentSize = CGSizeMake(320, self.resumeView.frame.origin.y + self.resumeView.frame.size.height + 50 + f2fbar);
    
    // add the blue overlay where the gradient ends
    UIView *blueOverlayExtend = [[UIView alloc] initWithFrame:CGRectMake(0, 416, 320, self.scrollView.contentSize.height - 416)];
    blueOverlayExtend.backgroundColor = [UIColor colorWithRed:0.67 green:0.83 blue:0.94 alpha:1.0];
    self.view.backgroundColor = blueOverlayExtend.backgroundColor;
    [self.scrollView insertSubview:blueOverlayExtend atIndex:0];
    
    // call the JS function in the mustache file that will lazyload the images
    [aWebView stringByEvaluatingJavaScriptFromString:@"lazyLoad();"];
    // reveal the resume
    self.resumeWebView.alpha = 1.0;
}

-(IBAction)plusButtonPressed:(id)sender {
    self.payButton.hidden = YES;
    
    // animate the spinning of the plus button and replacement by the minus button
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{ 
        self.plusButton.transform = CGAffineTransformMakeRotation(M_PI); 
        self.minusButton.transform = CGAffineTransformMakeRotation(M_PI);
        self.minusButton.alpha = 1.0;
    } completion: NULL];
    // alpha transition on the plus button so there isn't a gap where we see the background
    [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationCurveEaseInOut animations:^{
        self.plusButton.alpha = 0.0;
    } completion:NULL];
    // animation of menu buttons shooting out
    
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        if (self.user.isContact) {
            self.f2fButton.hidden = YES;
            self.goMenuBackground.transform = CGAffineTransformMakeTranslation(0, -110);
        } else {
            self.f2fButton.hidden = NO;
            self.f2fButton.transform = CGAffineTransformMakeTranslation(0, -165);            
            self.goMenuBackground.transform = CGAffineTransformMakeTranslation(0, -165);
        }
        self.chatButton.transform = CGAffineTransformMakeTranslation(0, -110);
        self.reviewButton.transform = CGAffineTransformMakeTranslation(0, -55);
        //self.payButton.transform = CGAffineTransformMakeTranslation(0, -55);
    } completion:^(BOOL finished){
        [self.view viewWithTag:1005].userInteractionEnabled = YES;
    }];
}

-(IBAction)minusButtonPressed:(id)sender {
    // animate the spinning of the minus button and replacement by the plus button
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{ 
        self.minusButton.transform = CGAffineTransformMakeRotation((M_PI*2)-0.0001); 
        self.plusButton.transform = CGAffineTransformMakeRotation((M_PI*2)-0.0001);
        self.plusButton.alpha = 1.0;
    } completion: NULL];
    // alpha transition on the minus button so there isn't a gap where we see the background
    [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationCurveEaseInOut animations:^{
        self.minusButton.alpha = 0.0;
    } completion:NULL];
    // animation of menu buttons being sucked back in
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
        self.f2fButton.transform = CGAffineTransformMakeTranslation(0, 0);
        self.chatButton.transform = CGAffineTransformMakeTranslation(0, 0);
        //self.payButton.transform = CGAffineTransformMakeTranslation(0, 0);
        self.reviewButton.transform = CGAffineTransformMakeTranslation(0, 0);
        self.goMenuBackground.transform = CGAffineTransformMakeTranslation(0, 0);
    } completion:^(BOOL finished){
        [self.view viewWithTag:1005].userInteractionEnabled = NO;
    }];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ProfileToOneOnOneSegue"])
    {
        [[segue destinationViewController] setUser:self.user];
        [self minusButtonPressed:nil];
    }
    else if ([[segue identifier] isEqualToString:@"ProfileToPayUserSegue"])
    {
        [[segue destinationViewController] setUser:self.user];
        [self minusButtonPressed:nil];        
    } else if ([[segue identifier] isEqualToString:@"ShowLinkedInProfileWebView"]) {
        // set the linkedInPublicProfileUrl in the destination VC
        [[segue destinationViewController] setLinkedInProfileUrlAddress:self.user.linkedInPublicProfileUrl];
    } else if ([[segue identifier] isEqualToString:@"SendLoveToUser"]) {
        // hide the go menu
        [self minusButtonPressed:nil];  
        
        [[segue destinationViewController] setUser:self.user];
        [[segue destinationViewController] setDelegate:self];
    }
}

-(IBAction)venueViewButtonPressed:(id)sender {
    VenueInfoViewController *venueVC = [[UIStoryboard storyboardWithName:@"VenueStoryboard_iPhone" bundle:nil] instantiateInitialViewController];
    venueVC.venue = self.user.placeCheckedIn;
    
    [self.navigationController pushViewController:venueVC animated:YES];
}

- (IBAction)chatButtonPressed:(id)sender
{
    if (self.user.contactsOnlyChat && !self.user.isContact && !self.user.hasChatHistory) {
        NSString *errorMessage = [NSString stringWithFormat:@"You can not chat with %@ until the two of you have exchanged contact information", self.user.nickname];
        [SVProgressHUD showErrorWithStatus:errorMessage
                                  duration:kDefaultDismissDelay];
    } else {
        [self performSegueWithIdentifier:@"ProfileToOneOnOneSegue" sender:sender];
    }
    [self minusButtonPressed:nil];
}

- (IBAction)f2fInvite {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:kRequestToAddToMyContactsActionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Send"
                                  otherButtonTitles: nil
                                  ];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([actionSheet title] == kRequestToAddToMyContactsActionSheetTitle) {
        [self minusButtonPressed:nil];
        if (buttonIndex != [actionSheet cancelButtonIndex]) {
            [CPapi sendContactRequestToUserId:self.user.userID];
        }
    }
}

#pragma mark -
#pragma mark GRMustacheTemplateDelegate

- (void)template:(GRMustacheTemplate *)template willRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation {
    // This method is called when the template is about to render a tag.
    
    // The invocation object tells us which object is about to be rendered.
    if ([invocation.returnValue isKindOfClass:[NSArray class]]) {
        // If it is an NSArray, reset our counter.
        self.templateCounter = [NSNumber numberWithUnsignedInteger:0];
    } else if (self.templateCounter && [invocation.key isEqualToString:@"index"]) {
        // If we have a counter, and we're asked for the `index` key, set the
        // invocation's returnValue to the counter: it will be rendered.
        // 
        // And increment the counter, of course.
        invocation.returnValue = self.templateCounter;
        self.templateCounter = [NSNumber numberWithUnsignedInteger:self.templateCounter.unsignedIntegerValue + 1];
    }
}

- (void)template:(GRMustacheTemplate *)template didRenderReturnValueOfInvocation:(GRMustacheInvocation *)invocation {
    // This method is called right after the template has rendered a tag.
    
    // Make sure we release the counter when we leave an NSArray.
    if ([invocation.returnValue isKindOfClass:[NSArray class]]) {
        self.templateCounter = nil;
    }
}

- (void)navigationBarTitleTap:(UIGestureRecognizer*)recognizer {
    [_scrollView setContentOffset:CGPointMake(0,0) animated:YES];
}

@end
