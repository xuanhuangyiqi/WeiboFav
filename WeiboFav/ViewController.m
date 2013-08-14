//
//  ViewController.m
//  WeiboFav
//
//  Created by Xiaoyu Wang on 8/13/13.
//  Copyright (c) 2013 Xiaoyu Wang. All rights reserved.
//

#import "ViewController.h"
#import "SIAlertView.h"

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scroll;
@property (strong, nonatomic) IBOutlet UIButton *testButton;
- (IBAction)testEvernoteAuth:(id)sender;

@end

@implementation ViewController

@synthesize scroll;


WeiboRequestOperation *_query;
NSInteger pressed;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [self.view addSubview:self.scroll];


    [[SIAlertView appearance] setMessageFont:[UIFont systemFontOfSize:13]];
    [[SIAlertView appearance] setTitleColor:[UIColor blackColor]];
    [[SIAlertView appearance] setMessageColor:[UIColor blackColor]];
    [[SIAlertView appearance] setCornerRadius:12];
    [[SIAlertView appearance] setShadowRadius:20];
    [[SIAlertView appearance] setViewBackgroundColor:[UIColor whiteColor]];
    
}

- (IBAction)testEvernoteAuth:(id)sender
{
    EvernoteSession *session = [EvernoteSession sharedSession];
    NSLog(@"Session host: %@", [session host]);
    NSLog(@"Session key: %@", [session consumerKey]);
    NSLog(@"Session secret: %@", [session consumerSecret]);
    
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated){
            if (error) {
                NSLog(@"Error authenticating with Evernote Cloud API: %@", error);
            }
            if (!session.isAuthenticated) {
                NSLog(@"Session not authenticated");
            }
        } else {
            // We're authenticated!
            EvernoteUserStore *userStore = [EvernoteUserStore userStore];
            [userStore getUserWithSuccess:^(EDAMUser *user) {
                // success
                NSLog(@"Authenticated as %@", [user username]);
            } failure:^(NSError *error) {
                // failure
                NSLog(@"Error getting user: %@", error);
            } ];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (![Weibo.weibo isAuthenticated]) {
        [Weibo.weibo authorizeWithCompleted:^(WeiboAccount *account, NSError *error) {
            if (!error) {
                NSLog(@"Sign in successful: %@", account.user.screenName);
            }
            else {
                NSLog(@"Failed to sign in: %@", error);
            }
        }];
    }
    [self loadStatuses];
    
    [self testEvernoteAuth:nil];
    
    
    if (![[PocketAPI sharedAPI] isLoggedIn])
        [[PocketAPI sharedAPI] loginWithHandler: ^(PocketAPI *API, NSError *error){
            if (error != nil)
            {}
            else
            {}
        }];
    
}

- (void)loadStatuses
{
    self.statuses = nil;
    if (_query) {
        [_query cancel];
    }
    _query = [Weibo.weibo queryFavorites:50 completed:^(NSMutableArray *statuses, NSError *error) {
        if (error) {
            self.statuses = nil;
            NSLog(@"error:%@", error);
        }
        else {
            self.statuses = statuses;
        }
        _query = nil;
        [self drawList];
    }];

}

- (NSInteger) countHeight:(NSString *)content withWidth:(NSInteger) width
{
    if ([content length] == 0) return 0;
    UIFont *font = [UIFont fontWithName:@"Arial" size:14.0f];
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(width, 1000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
    return size.height*1.5+20;
}


- (void) drawList
{
    NSInteger top = 0;
    
    UIFont *font = [UIFont fontWithName:@"Arial" size:14.0f];

    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:&error];
    
    for (int i = 0; i < _statuses.count; ++i )
    {
        Status *status = [_statuses objectAtIndex:i];
        NSInteger mainHeihgt = [self countHeight:status.text withWidth:320];
        NSInteger retweetHeight = [self countHeight:status.retweet withWidth:310];
        
        UITextView *main = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, mainHeihgt)];
        [main setEditable:NO];
        [main setText:status.text];
        [main setFont:font];
        [main setDataDetectorTypes:15];
        [main setScrollEnabled:NO];
        main.tag = i;


        
        UITextView *retweet = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, 310, retweetHeight)];
        UITextView *retweet_back = [[UITextView alloc] initWithFrame:CGRectMake(0, mainHeihgt, 320, retweetHeight+10)];
        [retweet_back setBackgroundColor:[UIColor whiteColor]];
        [retweet setEditable:NO];
        [retweet setFont:font];
        //[retweet setDataDetectorTypes:15];
        [retweet setText:status.retweet];
        [retweet setBackgroundColor:[UIColor grayColor]];
        retweet.layer.cornerRadius = 6;
        retweet.layer.masksToBounds = YES;
        [retweet setScrollEnabled:NO];
        retweet.tag = i;

        
        UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, top, 320, mainHeihgt+retweetHeight+11)];
        [item addSubview:main];
        item.tag = i;
        [retweet_back addSubview:retweet];
        [item addSubview:retweet_back];
        [item setBackgroundColor:[UIColor grayColor]];
        top += mainHeihgt+retweetHeight+11;
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongP:)];
        [retweet addGestureRecognizer:longPress];
        [main addGestureRecognizer:longPress];

        
        [self.scroll addSubview:item];
        
    }
    [self.scroll setContentSize:CGSizeMake(320, top)];
}

-(void) saveToPocket:(NSString *)u
{
    NSURL *url = [NSURL URLWithString:u];
    [[PocketAPI sharedAPI] saveURL:url handler: ^(PocketAPI *API, NSURL *URL,
                                                  NSError *error){
        if(error){
            NSLog(@"%@", error);
            // there was an issue connecting to Pocket
            // present some UI to notify if necessary
        }else{
            // the URL was saved successfully
        }
    }];
}

-(void) LongP:(UIGestureRecognizer *) aGer 
{
    if (aGer.state == UIGestureRecognizerStateBegan)
    {
        Status *status = [_statuses objectAtIndex:aGer.view.tag];
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:status.user.name andMessage:[status.text stringByAppendingString:status.retweet]];
        
        [alertView addButtonWithTitle:@"取消收藏"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  NSLog(@"Button1 Clicked");
                              }];
        [alertView addButtonWithTitle:@"Evernote"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  NSLog(@"Button1 Clicked");
                              }];

        [alertView show];
    }
}

-(void)setup{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pocketLoginStarted:)
                                                 name:PocketAPILoginStartedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pocketLoginFinished:)
                                                 name:PocketAPILoginFinishedNotification
                                               object:nil];
}

-(void)pocketLoginStarted:(NSNotification *)notification{
    // present login loading UI here
}

-(void)pocketLoginFinished:(NSNotification *)notification{
    // hide login loading UI here
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
