//
//  FriendChatViewController.m
//  OpentactSDKDemo
//
//  Created by hewx on 15/2/6.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <OpentactSDK/OpentactSDK.h>
#import "FriendChatViewController.h"
#import "MessageDB.h"
#import "DialViewController.h"

@interface FriendChatViewController () <AMBubbleTableDataSource, AMBubbleTableDelegate>

@property (nonatomic, strong) NSMutableArray* data;

@end

@implementation FriendChatViewController


- (void)viewDidLoad
{
    // Bubble Table setup
    
    [self setDataSource:self]; // Weird, uh?
    [self setDelegate:self];
    
    [self setTitle:@"Chat"];
    
    MessageDB *db = [MessageDB sharedManager];
    NSMutableArray *arr = [db findFromSid:self.fsid toSid:self.ssid];
    
    self.data = [[NSMutableArray alloc] initWithCapacity:20];
    
    for (NSDictionary *item in arr) {
        [self.data addObject:@{
           @"text": item[@"message"],
           @"date": item[@"date"],
           @"usename": item[@"fsid"],
           @"type": [item[@"fsid"] isEqualToString:self.ssid] ? @(AMBubbleCellSent) : @(AMBubbleCellReceived),
           @"color": [item[@"fsid"] isEqualToString:self.ssid] ? [UIColor purpleColor] : [UIColor blackColor]
       }];
    }
    
    // Set a style
    [self setTableStyle:AMBubbleTableStyleFlat];
    
    [self setBubbleTableOptions:@{AMOptionsBubbleDetectionType: @(UIDataDetectorTypeAll),
                                  AMOptionsBubblePressEnabled: @NO,
                                  AMOptionsBubbleSwipeEnabled: @NO,
                                  AMOptionsButtonTextColor: [UIColor colorWithRed:1.0f green:1.0f blue:184.0f/256 alpha:1.0f]}];
    
    // Call super after setting up the options
    [super viewDidLoad];
    
    [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    
    //    [self fakeMessages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newIncomingMessage:)
                                                 name:@"NewIncomingMessage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newIncomingCall:) name:@"IncomingCallNotification" object:nil];
}

- (void) newIncomingCall: (NSNotification *)notification {
    NSDictionary *theData = [notification userInfo];
    NSString *sid = theData[@"sid"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DialViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"DialView"];
    controller.dest = sid;
    controller.call_type = INCOMING_FROM_FRIEND;
    
    //self.window.rootViewController = controller;
    [self presentViewController:controller animated:YES completion:nil];
    
}

- (void) newIncomingMessage: (NSNotification *)notification {
    NSDictionary *theData = [notification userInfo];
    if ([theData[@"fsid"] isEqualToString:self.fsid] == YES) {
        
        [self.data addObject:@{ @"text": theData[@"message"],
                                @"date": [NSDate dateWithTimeIntervalSince1970:[theData[@"timestamp"] doubleValue]],
                                @"type": @(AMBubbleCellReceived),
                                @"color": [UIColor blackColor],
                                @"username": theData[@"fsid"],
                                }];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.data.count - 1) inSection:0];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
        // Either do this:
        [self scrollToBottomAnimated:YES];
        // or this:
        // [super reloadTableScrollingToBottom:YES];
    }
}

- (void)fakeMessages
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self didSendText:@"Fake message here!"];
        [self fakeMessages];
    });
}

- (void)swipedCellAtIndexPath:(NSIndexPath *)indexPath withFrame:(CGRect)frame andDirection:(UISwipeGestureRecognizerDirection)direction
{
    NSLog(@"swiped");
}

#pragma mark - AMBubbleTableDataSource

- (NSInteger)numberOfRows
{
    return self.data.count;
}

- (AMBubbleCellType)cellTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.data[indexPath.row][@"type"] intValue];
}

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.data[indexPath.row][@"text"];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NSDate date];
}

- (UIImage*)avatarForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [UIImage imageNamed:@"avatar"];
}

#pragma mark - AMBubbleTableDelegate

- (void)didSendText:(NSString*)text
{
    NSLog(@"User wrote: %@", text);
    NSDictionary *dict = @{ @"text": text,
                            @"date": [NSDate date],
                            @"type": @(AMBubbleCellSent)
                            };
    
    double timestamp = (double)[dict[@"date"] timeIntervalSince1970];
    
    [self.data addObject:dict];
    
    MessageDB *db = [MessageDB sharedManager];
    [db createMessage:text from:self.ssid to:self.fsid at:timestamp];
    
    NSDictionary *sendDict = @{
                               
                               @"message": text,
                               @"timestamp": [[NSNumber alloc] initWithDouble:timestamp],
                               @"type": @"text/plain",
                               @"fsid": self.ssid,
                               @"tsid": self.fsid
    };
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:sendDict options:0 error:&error];
    NSString *message = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    
    [[OpentactSDK sharedOpentactSDK]sendMessage:message toSid:self.fsid];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(self.data.count - 1) inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    // Either do this:
    [self scrollToBottomAnimated:YES];
    // or this:
    // [super reloadTableScrollingToBottom:YES];
}

- (NSString*)usernameForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.data[indexPath.row][@"username"];
}

- (UIColor*)usernameColorForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.data[indexPath.row][@"color"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)voice
{
    [self performSegueWithIdentifier:@"FriendToCall" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DialViewController *controller = [segue destinationViewController];
    controller.dest = self.fsid;
    controller.call_type = OUTGOING_TO_FRIEND;
}


@end
