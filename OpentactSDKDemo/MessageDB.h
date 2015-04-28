//
//  MessageDB.h
//  OpentactSDKDemo
//
//  Created by hewx on 15/2/9.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#define DBFILE_NAME @"Messages.sqlite3"

@interface MessageDB : NSObject
{
    sqlite3 *db;
}

+ (MessageDB *)sharedManager;

- (void)createdEditableCopyOfDatabaseIfNeeded;

- (BOOL)createMessage:(NSString *)message
                 from:(NSString *)fsid
                   to:(NSString *)tsid
                   at:(double)timestamp;


- (NSMutableArray *)findFromSid:(NSString *)fsid
                          toSid:(NSString *)tsid;

@end
