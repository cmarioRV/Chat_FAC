//
//  FACUserViewController.m
//  Chat_FAC
//
//  Created by Inter-Telco MacAir on 28/01/16.
//  Copyright (c) 2016 Jose Valentin Restrepo. All rights reserved.
//

#import "FACUserViewController.h"
#import "AppDelegate.h"

@interface FACUserViewController ()

@end

@implementation FACUserViewController

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
    }
    //    [[self appDelegate] setUser:user];
    //[[self appDelegate] setPass:password];
    if ([[self appDelegate] connect])
    {
        NSLog(@"Connected");
        //XMPPJID *userJID=[userInfo objectForKey:@"jid"];
        XMPPJID *userJID = [[[self appDelegate] xmppStream] myJID];
        XMPPUserCoreDataStorageObject *userRooster = [[[self appDelegate] xmppRosterStorage]
                                                      userForJID:userJID
                                                      xmppStream:[[self appDelegate] xmppStream]
                                                      managedObjectContext:[[self appDelegate] managedObjectContext_roster]];

    }
    else{
        NSLog(@"Not connected");
    }
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
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
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

/*
 - (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
 return 44.0f;
 }
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*
- (IBAction)register:(id)sender {
    NSString *username = @"edwin@cetad.fortiddns.com"; // OR [NSString stringWithFormat:@"%@@%@",username,XMPP_BASE_URL]]
    NSString *password = @"1";
    
    AppDelegate *del = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    del.xmppStream.myJID = [XMPPJID jidWithString:username];
    
    NSLog(@"Does supports registration");
    NSLog(@"Attempting registration for username %@",del.xmppStream.myJID.bare);
    
    if (del.xmppStream.supportsInBandRegistration) {
        NSError *error = nil;
        if (![del.xmppStream registerWithPassword:password error:&error])
        {
            NSLog(@"Oops, I forgot something: %@", error);
        }else{
            NSLog(@"No Error");
        }
    }
}*/

// You will get delegate called after registrations in either success or failure case. These delegates are in XMPPStream class
// - (void)xmppStreamDidRegister:(XMPPStream *)sender
//- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
@end
