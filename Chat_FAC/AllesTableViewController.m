//
//  AllesTableViewController.m
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 8/04/15.
//  Copyright (c) 2015 Jose Valentin Restrepo. All rights reserved.
//

#import "AllesTableViewController.h"
#import "AllesTableViewCell.h"
#import "AppDelegate.h"


#import "XMPPFramework.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

#import <CFNetwork/CFNetwork.h>


    // Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif



@interface AllesTableViewController ()

@end

@implementation AllesTableViewController
@synthesize arrayUsers,filtro;

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.title = @"Lista";
    [self updateArray];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[[self navigationController] interactivePopGestureRecognizer] setDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

#pragma mark - Acciones

- (void) listo {
    return;
}

-(void) updateArray {
    NSArray *sections=[[self fetchedResultsController] sections];
    int c= (int)[sections count];
    self.arrayUsers=[[NSMutableArray alloc] init];
    for (int i=0; i<c; i++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:i];
        NSUInteger sectionNum = sectionInfo.numberOfObjects;
        for (int j=0; j<sectionNum; j++) {
            NSMutableDictionary *useres = [[NSMutableDictionary alloc] init];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:j inSection:i];
            XMPPUserCoreDataStorageObject *userRooster = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            [useres setObject:userRooster.jid forKey:@"jid"];
            [useres setObject:userRooster.jidStr forKey:@"jidstr"];
            [useres setObject:userRooster.displayName forKey:@"nombre"];
            [self.arrayUsers addObject:useres];
        }
        
            //order array
        
    }
    
    NSSortDescriptor *Sorter = [[NSSortDescriptor alloc] initWithKey:@"jidstr" ascending:YES];
    [self.arrayUsers sortUsingDescriptors:[NSArray arrayWithObject:Sorter]];

    return;
}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController == nil)
    {
        NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                                  inManagedObjectContext:moc];
        
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
        NSSortDescriptor *sd3 = [[NSSortDescriptor alloc] initWithKey:@"unreadMessages" ascending:NO];
        
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, sd3, nil];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entity];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [fetchRequest setFetchBatchSize:50];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                       managedObjectContext:moc
                                                                         sectionNameKeyPath:@"sectionNum"
                                                                                  cacheName:nil];
        [fetchedResultsController setDelegate:self];
        
        
        NSError *error = nil;
        if (![fetchedResultsController performFetch:&error])
        {
            DDLogError(@"Error performing fetch: %@", error);
        } else {
            DDLogError(@"Fetch OK");
        }
        
    }
    
    return fetchedResultsController;
}

#pragma mark - Busquedas

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searchForText:searchString];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSString *searchString = controller.searchBar.text;
    [self searchForText:searchString];
    return YES;
}

- (void)searchForText:(NSString *)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"nombre contains[c] %@", searchText];
    filtro = [arrayUsers filteredArrayUsingPredicate:resultPredicate];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.tableView) {
        return [arrayUsers count];
    } else {
        return [filtro count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AllesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactInfoSel" forIndexPath:indexPath];
    if (cell==nil) {
        cell = [[AllesTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:@"ContactInfoSel"];
    }
    if (tableView == self.tableView)
    {
        NSDictionary *userInfo =[arrayUsers objectAtIndex:indexPath.row];
        XMPPJID *userJID=[userInfo objectForKey:@"jid"];
        
        
        XMPPUserCoreDataStorageObject *userRooster = [[[self appDelegate] xmppRosterStorage]
                                                      userForJID:userJID
                                                      xmppStream:[[self appDelegate] xmppStream]
                                                      managedObjectContext:[[self appDelegate] managedObjectContext_roster]];
        
        cell.Contacto.text = userRooster.displayName;
        [self configurePhotoForCell:cell user:userRooster];
        return cell;
    } else {
        NSDictionary *userInfo =[filtro objectAtIndex:indexPath.row];
        XMPPJID *userJID=[userInfo objectForKey:@"jid"];
        
        
        XMPPUserCoreDataStorageObject *userRooster = [[[self appDelegate] xmppRosterStorage]
                                                      userForJID:userJID
                                                      xmppStream:[[self appDelegate] xmppStream]
                                                      managedObjectContext:[[self appDelegate] managedObjectContext_roster]];
        
        cell.Contacto.text = userRooster.displayName;
        NSInteger section = userRooster.section;
        if (section==0) {
            cell.Contacto.textColor=[UIColor blueColor];
        } else {
            cell.Contacto.textColor=[UIColor blackColor];
        }
        [self configurePhotoForCell:cell user:userRooster];
        return cell;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
        // Return NO if you do not want the specified item to be editable.
    return NO;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict;
    if (tableView==self.tableView) {
        dict=[arrayUsers objectAtIndex:indexPath.row];
    } else {
        dict=[filtro objectAtIndex:indexPath.row];
    }
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"seguer" object:self userInfo:dict];
 
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(void) configurePhotoForCell:(AllesTableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)usuario {
    UIImage *foto;
    if (usuario.photo!=nil) {
        foto=usuario.photo;
        
    }else {
        NSData *fotodata=[[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:usuario.jid];
        if (fotodata!=nil) {
            foto=[UIImage imageWithData:fotodata];
        } else {
            foto=[UIImage imageNamed:@"no-image.png"];
        }
    }
    cell.photo.image=foto;
    cell.photo.layer.cornerRadius=5.0;
    cell.photo.layer.masksToBounds=YES;
    cell.photo.layer.borderWidth=1.0;
    cell.photo.layer.borderColor=[UIColor lightGrayColor].CGColor;
    
}


@end
