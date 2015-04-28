//
//  DialViewController.m
//  OpentactSDKDemo
//
//  Created by hewx on 15/2/6.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import "DialPadViewController.h"
#import "DialViewController.h"
#import <AudioToolbox/AudioToolbox.h>


#define kShadowOffsetY (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 4.0f : 2.0f)
#define kShadowBlur (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 10.0f : 5.0f)
#define kStrokeSize (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 6.0f : 3.0f)

@interface DialPadViewController ()

@end

@implementation DialPadViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DialViewController *controller = [segue destinationViewController];
    controller.dest = self.numberLabel.text;
    controller.call_type = OUTGOING_TO_TERMINATION;
}

- (IBAction)numberBtnClicked:(id)sender {
    self.numberLabel.text = [NSString stringWithFormat: @"%@%@", self.numberLabel.text, ((UIButton *)sender).titleLabel.text];
    [self playSoundForKey: ((UIButton *)sender).titleLabel.text];
}

- (void)playSoundForKey: (NSString *)pkey
{
    if ([pkey isEqualToString:@"⋆"]) {
        pkey = @"s";
    } else if([pkey isEqualToString:@"⌗"]) {
        pkey = @"#";
    }
    
    NSString *filename = [NSString stringWithFormat:@"dtmf-%@", pkey];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    
    NSString *path = [mainBundle pathForResource:filename ofType:@"aif"];
    if (!path)
        return;
    
    NSURL *aFileURL = [NSURL fileURLWithPath:path];
    if (aFileURL != nil)
    {
        SystemSoundID aSoundID;
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)aFileURL,
                                                          &aSoundID);
        if (error != kAudioServicesNoError)
            return;
        
        AudioServicesPlaySystemSound(aSoundID);
    }
    
    
}

- (IBAction)delBtnClicked:(id)sender {
    NSUInteger length = [self.numberLabel.text length];
    if (length > 0) {
        self.numberLabel.text = [self.numberLabel.text substringToIndex:length - 1];
    }
}


@end
