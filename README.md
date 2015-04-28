# A demo for Opentact IOS SDK

## Getting Started

1. Make sure you have installed xcode in your pc.
2. Download the code.
3. Open CLI. run `open OpentactSDKDemo.xcodeproj`.

## Configuration

**OpentactSDKDemo/AppDelegate.m**

    self.ssid = @"553d9f281073e94661fce8b1";  // your Sub Account SID

    OpentactSDK *sdk = [OpentactSDK sharedOpentactSDK];
    [sdk setSid:@"553d9e6d1073e9455be0b30e"   // your SID
                 andSsid:self.ssid
            andAuthToken:@"cb1f04160faa4ccbb8b368aebbd2a873"]  // your AuthToken



