//
//  AppDelegate.m
//  theoryandpractice
//
//  Created by Look Listen on 18.02.17.
//  Copyright © 2017 Igor Czarev. All rights reserved.
//

#import "AppDelegate.h"
#import "TPAPIArticlesClient.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    self.window.tintColor = [UIColor colorWithRed:0.37 green:0.62 blue:0.86 alpha:1];
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[TPAPIArticlesClient sharedClient] updateArticlesWithCompletionHandler:^(BOOL updated, NSUInteger newItem) {
        if (newItem > 0) {
            UILocalNotification *localNotif = [[UILocalNotification alloc] init];
            
            localNotif.alertBody = @"Обновились новости";
            localNotif.alertLaunchImage = @"AppIcon";
            localNotif.alertAction = NSLocalizedString(@"View", nil);
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        }
        if (updated) {
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }];
}

@end
