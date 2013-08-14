//
//  AppDelegate.m
//  WeiboFav
//
//  Created by Xiaoyu Wang on 8/13/13.
//  Copyright (c) 2013 Xiaoyu Wang. All rights reserved.
//

#import "AppDelegate.h"
#import "EvernoteSDK.h"
#import "EvernoteSession.h"
#import "ENConstants.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    Weibo *weibo = [[Weibo alloc] initWithAppKey:@"1827963634" withAppSecret:@"b028d7946f5aa9c59fcea185448a44d7"];
    [Weibo setWeibo:weibo];

    [[PocketAPI sharedAPI] setConsumerKey:@"17444-a08469f8ff068e0ca64b345e"];
    
    
    NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringSandbox;
    NSString *CONSUMER_KEY = @"htedsv-8455";
    NSString *CONSUMER_SECRET = @"53647497274f83ee";
    
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST
                              consumerKey:CONSUMER_KEY
                           consumerSecret:CONSUMER_SECRET];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[EvernoteSession sharedSession] handleDidBecomeActive];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *) sourceApplication annotation:(id)annotation{
    
    if([[PocketAPI sharedAPI] handleOpenURL:url]){
        return YES;
    }else{
        BOOL canHandle = NO;
        if ([[NSString stringWithFormat:@"en-%@", [[EvernoteSession sharedSession] consumerKey]] isEqualToString:[url scheme]] == YES) {
            canHandle = [[EvernoteSession sharedSession] canHandleOpenURL:url];
        }
        return canHandle;
        
        // if you handle your own custom url-schemes, do it here
        return NO;
    }
    
}

@end
