//
//  DialViewController.h
//  OpentactSDKDemo
//
//  Created by hewx on 15/2/7.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpentactSDK/OpentactSDK.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "MZTimerLabel.h"

typedef enum {
    OUTGOING_TO_FRIEND,
    OUTGOING_TO_TERMINATION,
    INCOMING_FROM_FRIEND
} CALL_TYPE;

typedef enum {
    HANGON,
    HANGUP,
    RINGING
} CALL_STATE;

@interface DialViewController : UIViewController <AVAudioPlayerDelegate>
{
    SystemSoundID shortSound;
    AVAudioPlayer *audioPlayer;
}

@property (strong, nonatomic) NSString* dest;
@property (assign, nonatomic) CALL_TYPE call_type;
@property (weak, nonatomic) IBOutlet UIButton *speaker;

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
- (IBAction)hangupButtonClicked:(id)sender;
- (IBAction)hangonButtonClicked:(id)sender;

@end
