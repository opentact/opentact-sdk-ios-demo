//
//  FriendsTableViewController.m
//  OpentactSDKDemo
//
//  Created by hewx on 15/2/6.
//  Copyright (c) 2015年 org.opentact. All rights reserved.
//

#import <OpentactSDK/OpentactRest.h>
#import <OpentactSDK/OpentactSDK.h>
#import "FriendsTableViewController.h"
#import "FriendTableViewCell.h"
#import "FriendChatViewController.h"
#import "AppDelegate.h"

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    [self loadData];
    
}

- (void)loadData
{
    OpentactSDK *sdk = [OpentactSDK sharedOpentactSDK];
    OpentactRest *rest = [OpentactRest sharedOpentactRest];
    
    
    [rest getFriendsBySid:sdk.ssid withSuccess:^(id response) {
        
        NSDictionary *res = (NSDictionary *)response;
        self.friends = [res objectForKey:@"friends"];
        
        [self.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.friends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *friend = [self.friends objectAtIndex:[indexPath row]];
    cell.avatar.image = [UIImage imageNamed:@"avatar"];
    cell.name.text = [friend objectForKey:@"sid"];
    if ([[friend objectForKey:@"sip_status"] isEqualToString:@"online"])
    {
        cell.sipStatus.image = [UIImage imageNamed:@"sipstatus"];
    }
    else
    {
        cell.sipStatus.image = [self convertImageToGrayScale:[UIImage imageNamed:@"sipstatus"]];
    }
    
    if ([[friend objectForKey:@"im_status"] isEqualToString:@"online"])
    {
        cell.imStatus.image = [UIImage imageNamed:@"imstatus"];
    }
    else
    {
        cell.imStatus.image = [self convertImageToGrayScale:[UIImage imageNamed:@"imstatus"]];
    }
    
    
    
    return cell;
}

- (UIImage *)convertImageToGrayScale:(UIImage *)image
{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    // Draw image into current context, with specified rectangle
    // using previously defined context (with grayscale colorspace)
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    /* changes start here */
    // Create bitmap image info from pixel data in current context
    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    
    // release the colorspace and graphics context
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    // make a new alpha-only graphics context
    context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, nil, kCGImageAlphaOnly);
    
    // draw image into context with no colorspace
    CGContextDrawImage(context, imageRect, [image CGImage]);
    
    // create alpha bitmap mask from current context
    CGImageRef mask = CGBitmapContextCreateImage(context);
    
    // release graphics context
    CGContextRelease(context);
    
    // make UIImage from grayscale image with alpha mask
    UIImage *grayScaleImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImage, mask) scale:image.scale orientation:image.imageOrientation];
    
    // release the CG images
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    
    // return the new grayscale image
    return grayScaleImage;
    
    /* changes end here */
}

#pragma mark - Launch Chat Controller




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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    FriendChatViewController* controller = [segue destinationViewController];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    NSIndexPath *path=  [self.tableView indexPathForSelectedRow];
    
    NSDictionary *friend = [self.friends objectAtIndex:path.row];
    
    controller.fsid = friend[@"sid"];
    controller.ssid = appDelegate.ssid;
}



@end
