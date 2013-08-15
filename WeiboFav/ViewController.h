//
//  ViewController.h
//  WeiboFav
//
//  Created by Xiaoyu Wang on 8/13/13.
//  Copyright (c) 2013 Xiaoyu Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>
#import "Weibo.h"
#import "PocketAPI.h"
#import "EvernoteSDK.h"
@interface ViewController : UIViewController

-(void) loadStatuses;
-(void) drawList;
- (IBAction)testEvernoteAuth:(id)sender;
- (IBAction)createPhotoNote:(id)sender;
- (void)makeNoteWithTitle:(NSString*)noteTile withBody:(NSString*) noteBody withResources:(NSMutableArray*)resources withParentBotebook:(EDAMNotebook*)parentNotebook;

@property (nonatomic, strong) NSMutableArray *statuses;

@end
