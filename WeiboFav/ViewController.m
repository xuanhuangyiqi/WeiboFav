//
//  ViewController.m
//  WeiboFav
//
//  Created by Xiaoyu Wang on 8/13/13.
//  Copyright (c) 2013 Xiaoyu Wang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scroll;
@end

@implementation ViewController

@synthesize scroll;

WeiboRequestOperation *_query;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [self.view addSubview:self.scroll];

	// Do any additional setup after loading the view, typically from a nib.
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

        
        UITextView *retweet = [[UITextView alloc] initWithFrame:CGRectMake(5, mainHeihgt, 310, retweetHeight)];
        [retweet setEditable:NO];
        [retweet setFont:font];
        [retweet setAlpha:0.5];
        [retweet setDataDetectorTypes:15];
        [retweet setText:status.retweet];
        [retweet setBackgroundColor:[UIColor grayColor]];
        retweet.layer.cornerRadius = 6;
        retweet.layer.masksToBounds = YES;
        [retweet setScrollEnabled:NO];

        
        UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, top, 320, mainHeihgt+retweetHeight)];
        [item addSubview:main];
        [item addSubview:retweet];
        top += mainHeihgt+retweetHeight;

        
        [self.scroll addSubview:item];
        
    }
    [self.scroll setContentSize:CGSizeMake(320, top)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
