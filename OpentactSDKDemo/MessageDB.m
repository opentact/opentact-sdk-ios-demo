//
//  MessageDB.m
//  OpentactSDKDemo
//
//  Created by hewx on 15/2/9.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import "MessageDB.h"

@implementation MessageDB


static MessageDB *sharedManager = nil;

+ (MessageDB *)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc]init];
        [sharedManager createdEditableCopyOfDatabaseIfNeeded];
    });
    
    return sharedManager;
}

- (NSString *)applicationDocumentsDirectoryFile
{
    NSURL *documentsURL = [[NSFileManager defaultManager]URLForDirectory:NSDocumentationDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    //NSLog(@"%@", paths);
    //NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *documentDirectory = [documentsURL absoluteString];
    NSString *path = [documentDirectory stringByAppendingPathComponent:DBFILE_NAME];
    return path;
}

- (void)createdEditableCopyOfDatabaseIfNeeded
{
    NSString *writableDBPath = [self applicationDocumentsDirectoryFile];
    
    NSLog(@"DB path:%@", writableDBPath);
    
    if (sqlite3_open([writableDBPath UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(NO, @"error in opening db");
    } else {
        char *err;
        NSString *createSQL = @"CREATE TABLE IF NOT EXISTS messages(id INTEGER PRIMARY KEY AUTOINCREMENT, tsid VARCHAR(24), fsid VARCHAR(24), message TEXT, created_at TIMESTAMP)";
        if (sqlite3_exec(db, [createSQL UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            sqlite3_close(db);
            NSAssert(NO, @"error creating table, %s", err);
        }
        
        NSString *createIndex1 = @"CREATE INDEX IF NOT EXISTS messages_idx_tf ON messages(tsid, fsid)";
        
        if (sqlite3_exec(db, [createIndex1 UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            sqlite3_close(db);
            NSAssert(NO, @"error creating index, %s", err);
        }
        
        NSString *createIndex2 = @"CREATE INDEX IF NOT EXISTS messages_idx_ft ON messages(fsid, tsid)";
        
        if (sqlite3_exec(db, [createIndex2 UTF8String], NULL, NULL, &err) != SQLITE_OK)
        {
            sqlite3_close(db);
            NSAssert(NO, @"error creating index, %s", err);
        }
        
        sqlite3_close(db);
    }
}

- (BOOL)createMessage:(NSString *)message
                 from:(NSString *)fsid
                   to:(NSString *)tsid
                   at:(double)timestamp
{
    NSString *path = [self applicationDocumentsDirectoryFile];
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK)
    {
        sqlite3_close(db);
        NSAssert(NO, @"error in opening db");
    }
    else
    {
        NSString *sqlStr = @"INSERT INTO messages(tsid, fsid, message, created_at) VALUES (?, ?, ?, ?)";
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [sqlStr UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(statement, 1, [tsid UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 2, [fsid UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 3, [message UTF8String], -1, NULL);
            sqlite3_bind_double(statement, 4, timestamp);
            
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSAssert(NO, @"error inserting data.");
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    return YES;
}


- (NSMutableArray *)findFromSid:(NSString *)fsid
                          toSid:(NSString *)tsid
{
    NSString *path = [self applicationDocumentsDirectoryFile];
    NSMutableArray *listData = [[NSMutableArray alloc] init];
    
    if (sqlite3_open([path UTF8String], &db) != SQLITE_OK)
    {
        sqlite3_close(db);
        NSAssert(NO, @"error in opening db");
    }
    else
    {
        NSString *qsql = @"SELECT message, created_at, fsid, tsid FROM messages WHERE (fsid = ? and tsid = ?) or (fsid = ? and tsid = ?) ORDER BY id ASC";
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [qsql UTF8String], -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(statement, 1, [fsid UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 2, [tsid UTF8String], -1, NULL);
            
            
            sqlite3_bind_text(statement, 3, [tsid UTF8String], -1, NULL);
            sqlite3_bind_text(statement, 4, [fsid UTF8String], -1, NULL);
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                char *cmessage = (char *)sqlite3_column_text(statement, 0);
                NSString *message = [[NSString alloc] initWithUTF8String:cmessage];
                
                double timestamp = (double)sqlite3_column_double(statement, 1);
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
                
                
                char *cfsid = (char *)sqlite3_column_text(statement, 2);
                NSString *fsid = [[NSString alloc] initWithUTF8String:cfsid];
                
                
                char *ctsid = (char *)sqlite3_column_text(statement, 3);
                NSString *tsid = [[NSString alloc] initWithUTF8String:ctsid];
                
                [listData addObject:@{
                    @"message": message,
                    @"date": date,
                    @"fsid": fsid,
                    @"tsid": tsid
                }];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(db);
    }
    
    return listData;
}

@end
