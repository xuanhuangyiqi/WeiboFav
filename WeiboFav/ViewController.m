//
//  ViewController.m
//  WeiboFav
//
//  Created by Xiaoyu Wang on 8/13/13.
//  Copyright (c) 2013 Xiaoyu Wang. All rights reserved.
//

#import "ViewController.h"
#import "SIAlertView.h"

#import "EvernoteSDK.h"
#import "NSData+EvernoteSDK.h"
#import "ENMLUtility.h"
#import "STTweetLabel.h"

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scroll;
@property (strong, nonatomic) IBOutlet UIButton *testButton;

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
    [self.scroll setBackgroundColor:[UIColor lightGrayColor]];


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
    UIFont *font = [UIFont fontWithName:@"Arial" size:12.0f];
    CGSize size = [content sizeWithFont:font constrainedToSize:CGSizeMake(width, 1000.0f) lineBreakMode:UILineBreakModeCharacterWrap];
    return size.height;
}


- (void) drawList
{
    NSInteger top = 0;
    
    UIFont *font = [UIFont fontWithName:@"Arial" size:12.0f];

    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:&error];
    
    UIColor* mainColor = [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:1.0f];
    UIColor* neutralColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    UIColor* mainColorLight = [UIColor colorWithRed:50.0/255 green:102.0/255 blue:147.0/255 alpha:0.7f];

    for (int i = 0; i < _statuses.count; ++i )
    {
        UIView *item = [[UIView alloc] initWithFrame:CGRectMake(0, top, 320, 5)];

        int item_length = 0;
        Status *status = [_statuses objectAtIndex:i];
        NSInteger mainHeihgt = [self countHeight:status.text withWidth:310];
        NSInteger retweetHeight = [self countHeight:status.retweet withWidth:300];
        
        //UITextView *main = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, mainHeihgt)];
        STTweetLabel *main = [[STTweetLabel alloc] initWithFrame:CGRectMake(5, 5, 310, mainHeihgt)];
        main.delegate = self;
        [main setText:status.text];
        [main setFont:font];
        [main setTextColor:neutralColor];
        
        main.numberOfLines = 0;
        [main setBackgroundColor:[UIColor whiteColor]];
        main.tag = i;
        item_length += mainHeihgt + 10;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(LongP:)];

       
        if (retweetHeight > 0)
        {
        //UITextView *retweet = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, 310, retweetHeight)];
            STTweetLabel *retweet = [[STTweetLabel alloc] initWithFrame:CGRectMake(5, 5, 300, retweetHeight)];
            retweet.delegate = self;
            UITextView *retweet_back = [[UITextView alloc] initWithFrame:CGRectMake(5, mainHeihgt+10, 310, retweetHeight+10)];
            [retweet_back setEditable:NO];
        //[retweet setEditable:NO];
            [retweet setFont:font];
        //[retweet setDataDetectorTypes:15];
            [retweet setText:status.retweet];
            [retweet setTextColor:mainColorLight];
            
            [retweet_back setBackgroundColor:[UIColor colorWithRed:1 green:0.6 blue:0.9 alpha:0.3]];
            retweet_back.layer.cornerRadius = 3;
            retweet_back.layer.masksToBounds = YES;

            retweet.tag = i;
            item_length += retweetHeight+15;
            [retweet_back addSubview:retweet];
            [item addSubview:retweet_back];
            [retweet addGestureRecognizer:longPress];

        }

        [item setBackgroundColor:[UIColor whiteColor]];
        item.frame = CGRectMake(0, top, 320, item_length);
        [item addSubview:main];
        item.tag = i;
        top += item_length + 1;
        
        [main addGestureRecognizer:longPress];
        [self.scroll addSubview:item];
        
    }
    [self.scroll setContentSize:CGSizeMake(320, top)];
}

-(void) saveToPocket:(NSString *)u
{
    NSURL *url = [NSURL URLWithString:u];
    NSLog(@"321");
    [[PocketAPI sharedAPI] saveURL:url handler: ^(PocketAPI *API, NSURL *URL,
                                                  NSError *error){
        if(error){
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Pocket" andMessage:@"保存失败"];
            
            [alertView addButtonWithTitle:@"OK"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                      NSLog(@"OK Clicked");
                                  }];
            [alertView show];
        }else{
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Pocket" andMessage:@"保存成功"];
            
            [alertView addButtonWithTitle:@"OK"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                      NSLog(@"OK Clicked");
                                  }];
            [alertView show];
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
                                  [self makeNoteWithTitle:@"title" withBody:[NSString stringWithFormat:@"%s%s", status.text, status.retweet] withResources:nil withParentBotebook:nil];

                              }];

        [alertView show];
    }
}


- (void)makeNoteWithTitle:(NSString*)noteTile withBody:(NSString*) noteBody withResources:(NSMutableArray*)resources withParentBotebook:(EDAMNotebook*)parentNotebook {
    NSString *noteContent = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                             "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
                             "<en-note>"
                             "%@",[NSString stringWithCString:[noteBody UTF8String] encoding:NSUnicodeStringEncoding]];
    
    // Add resource objects to note body
    if(resources.count > 0) {
        noteContent = [noteContent stringByAppendingString:
                       @"<br />"];
    }
    // Include ENMLUtility.h .
    for (EDAMResource* resource in resources) {
        noteContent = [noteContent stringByAppendingFormat:@"Attachment : <br /> %@",
                       [ENMLUtility mediaTagWithDataHash:resource.data.bodyHash
                                                    mime:resource.mime]];
    }
    
    noteContent = [noteContent stringByAppendingString:@"</en-note>"];
    
    // Parent notebook is optional; if omitted, default notebook is used
    NSString* parentNotebookGUID;
    if(parentNotebook) {
        parentNotebookGUID = parentNotebook.guid;
    }
    
    // Create note object
    EDAMNote *ourNote = [[EDAMNote alloc] initWithGuid:nil title:noteTile content:noteContent contentHash:nil contentLength:noteContent.length created:0 updated:0 deleted:0 active:YES updateSequenceNum:0 notebookGuid:parentNotebookGUID tagGuids:nil resources:resources attributes:nil tagNames:nil];
    
    // Attempt to create note in Evernote account
    [[EvernoteNoteStore noteStore] createNote:ourNote success:^(EDAMNote *note) {
        // Log the created note object
        NSLog(@"Note created : %@",note);
    } failure:^(NSError *error) {
        // Something was wrong with the note data
        // See EDAMErrorCode enumeration for error code explanation
        // http://dev.evernote.com/documentation/reference/Errors.html#Enum_EDAMErrorCode
        NSLog(@"Error : %@",error);
    }];
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

- (void)websiteClicked:(NSString *)link {
    NSLog(@"web");
    [self saveToPocket:link];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
