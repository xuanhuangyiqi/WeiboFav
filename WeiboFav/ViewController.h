//
//  ViewController.h
//  WeiboFav
//
//  Created by Xiaoyu Wang on 8/13/13.
//  Copyright (c) 2013 Xiaoyu Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Weibo.h"
#import "PocketAPI.h"
#import "EvernoteSDK.h"
@interface ViewController : UIViewController

-(void) loadStatuses;
-(void) drawList;

@property (nonatomic, strong) NSMutableArray *statuses;

@end
