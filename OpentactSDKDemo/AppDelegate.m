//
//  AppDelegate.m
//  OpentactSDKDemo
//
//  Created by hewx on 15/2/6.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <OpentactSDK/OpentactSDK.h>
#import "AppDelegate.h"
#import "MessageDB.h"
#import "DialViewController.h"

@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //self.ssid = @"552cc1b6e138232149678edf";
    self.ssid = @"553d9f281073e94661fce8b1";
    
    OpentactSDK *sdk = [OpentactSDK sharedOpentactSDK];
    [sdk setSid:@"553d9e6d1073e9455be0b30e"
                 andSsid:self.ssid
            andAuthToken:@"cb1f04160faa4ccbb8b368aebbd2a873"];
    
    [sdk startupVoiceOnRegister:^(BOOL isOK) {
        if (isOK == YES) {
            NSLog(@"Registered!");
        }
    } onIncomingCall:^(NSString *sid) {
        NSLog(@"%@ is calling you", sid);
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DialViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"DialView"];
        controller.dest = sid;
        controller.call_type = INCOMING_FROM_FRIEND;
         
        //self.window.rootViewController = controller;
        [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IncomingCallNotification" object:nil userInfo:@{@"sid": sid}];
        
        UILocalNotification *alert = [[UILocalNotification alloc] init];
        if (alert) {
            alert.repeatInterval = 0;
            alert.alertBody = [NSString stringWithFormat:@"Incoming call received from %@", sid];
            alert.alertAction = @"Active app";
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:alert];
        }
        
        
    } onHangup:^{
        NSLog(@"The call is hungup");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallStateNotification" object:nil userInfo:@{@"state": @(HANGUP)}];
    } onHangon:^{
        NSLog(@"The call is hungon");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CallStateNotification" object:nil userInfo:@{@"state": @(HANGON)}];
    } onRing: ^{
        NSLog(@"The call is ringing");
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"CallStateNotification" object:nil userInfo:@{@"state": @(RINGING)}];
    }];

    
    
    [sdk startupIMOnIncommingMessage:^(NSString *message) {
        MessageDB *db = [MessageDB sharedManager];
        
        NSLog(@"received message: %@", message);
        NSError *error;
        
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        
        //double timestamp = (double)[[NSDate date] timeIntervalSince1970];
        
        if (resDict) {
            
            NSLog(@"%@", resDict);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [db createMessage:resDict[@"message"] from:resDict[@"fsid"] to:resDict[@"tsid"] at:[resDict[@"timestamp"] doubleValue]];
            }];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewIncomingMessage" object:nil userInfo:resDict];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newOutgoingMessage:) name:@"NewOutgoingMessage" object:nil];
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert| UIUserNotificationTypeBadge| UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    
    
    return YES;
}

- (void) newOutgoingMessage: (NSNotification *)notification {
    NSDictionary *theData = [notification userInfo];
    
    double timestamp = (double)[[NSDate date] timeIntervalSince1970];
    
    NSDictionary *sendDict = @{ @"message": theData[@"message"],
                                @"timestamp": [[NSNumber alloc] initWithDouble:timestamp],
                                @"type": @"text/plain",
                                @"fsid": self.ssid};
    
    
    MessageDB *db = [MessageDB sharedManager];
    
    [db createMessage:theData[@"message"] from:self.ssid to:theData[@"tsid"] at:timestamp];
    
    
    OpentactSDK *sdk = [OpentactSDK sharedOpentactSDK];
    
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:sendDict options:0 error:&error];
    NSString *message = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [sdk sendMessage:message toSid:theData[@"tsid"]];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [application setKeepAliveTimeout:600 handler:^{
        [self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
    }];
}

- (void)keepAlive
{
    /* Register this thread if not yet*/
    [[OpentactSDK sharedOpentactSDK] keepAlive];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
