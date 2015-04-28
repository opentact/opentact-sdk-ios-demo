//
//  ContactsTableViewController.m
//  OpentactSDKDemo
//
//  Created by hewx on 15/2/10.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <QuartzCore/QuartzCore.h>
#import "ContactsTableViewController.h"
#import "DialViewController.h"

@interface ContactsTableViewController ()

@end

@implementation ContactsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            [self filterContentForSearchText:@""];
        }
    });
    CFRelease(addressBook);
    
    self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)filterContentForSearchText:(NSString *)searchText
{
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized)
    {
        return;
    }
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if ([searchText length] == 0) {
        // all
        self.listContacts = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    } else {
        // condition
        CFStringRef cfsearchText = (CFStringRef)CFBridgingRetain(searchText);
        self.listContacts = CFBridgingRelease(ABAddressBookCopyPeopleWithName(addressBook, cfsearchText));
        CFRelease(cfsearchText);
    }
    [self.tableView reloadData];
    
    CFRelease(addressBook);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.listContacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIndentifier = @"ContactsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    
    ABRecordRef thisPerson = CFBridgingRetain([self.listContacts objectAtIndex:[indexPath row]]);
    NSString *firstName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonFirstNameProperty));
    firstName = firstName != nil ? firstName : @"";
    NSString *lastName = CFBridgingRelease(ABRecordCopyValue(thisPerson, kABPersonLastNameProperty));
    lastName = lastName != nil ? lastName : @"";
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    CFRelease(thisPerson);
    
    return cell;
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    ABRecordRef thisPerson = CFBridgingRetain([self.listContacts objectAtIndex:[indexPath row]]);
    
    DialViewController *controller = [segue destinationViewController];
    
    //ABRecordID personID = ABRecordGetRecordID(thisPerson);
    ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(thisPerson, kABPersonPhoneProperty);
    
    if (ABPersonHasImageData(thisPerson)) {
        NSData *photoData = CFBridgingRelease(ABPersonCopyImageData(thisPerson));
        if (photoData) {
            [controller.avatarImage setImage:[UIImage imageWithData:photoData]];
        }
    }
    
    NSString* phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, 0));
    
    controller.dest = phoneNumber;
    controller.call_type = OUTGOING_TO_TERMINATION;
}

@end
