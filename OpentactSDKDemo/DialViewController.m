//
//  DialViewController.m
//  OpentactSDKDemo
//
//  Created by hewx on 15/2/7.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//
#import "DialViewController.h"

@interface DialViewController ()

@property (strong, nonatomic)MZTimerLabel *timer;

@end

@implementation DialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSLog(@"Call Type:%d", self.call_type);
    
    
    switch (self.call_type) {
        case OUTGOING_TO_FRIEND:
            [[OpentactSDK sharedOpentactSDK] makeCallToSid:self.dest];
            self.timerLabel.text = [NSString stringWithFormat:@"Dialing %@", self.dest];
            break;
        case OUTGOING_TO_TERMINATION:
            [[OpentactSDK sharedOpentactSDK] makeCallToTermination:self.dest];
            self.timerLabel.text = [NSString stringWithFormat:@"Dialing %@", self.dest];
            break;
        case INCOMING_FROM_FRIEND:
            self.timerLabel.text = self.dest;
            [self playSound];
            break;
        default:
            break;
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callState:) name:@"CallStateNotification" object:nil];
    
}

- (void)playSound
{
    NSString *soundPath = [[NSBundle mainBundle]pathForResource:@"ringtone" ofType:@"mp3"];
    if (soundPath) {
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
        [audioPlayer setDelegate:self];
        [audioPlayer play];
    }
}


- (void)callState: (NSNotification *)notification {
    NSDictionary *theData = [notification userInfo];
    
    if ([audioPlayer isPlaying]) {
        [audioPlayer stop];
    }
    
    switch ([theData[@"state"] integerValue]) {
        case HANGON:
            self.timer = [[MZTimerLabel alloc]initWithLabel:self.timerLabel];
            [self.timer start];
            break;
        case HANGUP:
            [self.timer pause];
            [[OpentactSDK sharedOpentactSDK] endCall];
            [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(goPreviousController) userInfo:nil repeats:NO];
            break;
        default:
            break;
    }
}

- (void)goPreviousController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)hangupButtonClicked:(id)sender {
    //[self dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CallStateNotification" object:nil userInfo:@{@"state": @(HANGUP)}];
}

- (IBAction)hangonButtonClicked:(id)sender {
    
    [[OpentactSDK sharedOpentactSDK] answerCall];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"CallStateNotification" object:nil userInfo:@{@"state": @(HANGUP)}];
}

@end
