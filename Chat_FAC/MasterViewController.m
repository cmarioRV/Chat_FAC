//
//  MasterViewController.m
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 26/11/14.
//  Copyright (c) 2014 Jose Valentin Restrepo. All rights reserved.
//

#import "MasterViewController.h"


#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ChatViewController.h"
#import "ContactTableViewCell.h"

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


@interface MasterViewController () {
    NSString *jidnewchat;
}

@property NSMutableArray *objects;
@property NSString *fechastr;
@end


@implementation MasterViewController
//@synthesize user,password;
@synthesize sectionArray,rosterInSection;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}




- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   // self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark View lifecycle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) willMoveToParentViewController:(UIViewController *)parent {
    [sectionArray removeAllObjects];
    [[[[self appDelegate] xmppRoster] xmppRosterStorage ] clearAllUsersAndResourcesForXMPPStream:nil];
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
        /*
        NSString *stri =[[[[self appDelegate] xmppStream] myJID] bare];
        stri=[stri substringToIndex:[stri rangeOfString:@"@"].location];
         */
        self.title =@"Chats";
        self.navigationItem.leftBarButtonItem.title = @"Logout";
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor redColor];
        UIBarButtonItem *button=[[UIBarButtonItem alloc] initWithTitle:@"Lista"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(listausuarios)];
        self.navigationItem.rightBarButtonItem=button;
        [self deleteOldRecords];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newMessageRec:)
                                                     name:@"MensajeNuevo"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(newMessageRec:)
                                                     name:@"EstadoNuevo"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(elsegue:)
                                                     name:@"seguer"
                                                   object:nil];
    } else
    {
        self.title = @"No Conexión";
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
                                                      message:@"No fue posible conectarse"
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
    }
}

-(BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}

-(void) newMessageRec:(NSNotification *) not {
        //[self updateUnreadMessages];
    [self updateArray];
    [[self tableView] reloadData];
}

-(void) elsegue:(NSNotification *)noti {
    NSDictionary *dict=(NSDictionary *)[noti userInfo];
    jidnewchat = [dict objectForKey:@"jidstr"];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
 }


-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[[self navigationController] interactivePopGestureRecognizer] setDelegate:self];
    if ([jidnewchat length]>0) {
        [self  performSegueWithIdentifier:@"newchat" sender:self];
    }
    [self updateArray];
    [[self tableView] reloadData];
}

-(void) updateArray {
    if ([self sectionArray]==nil) {
        sectionArray=[[NSMutableArray alloc] init];
        
    }
    NSMutableArray *arrayUsers=[[NSMutableArray alloc] init];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [sectionArray removeAllObjects];
    NSArray *sections=[[self fetchedResultsController] sections];
    int c= (int)[sections count];
    for (int i=0; i<c; i++) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:i];
            //        int section = [sectionInfo.name intValue];
        NSUInteger sectionNum = sectionInfo.numberOfObjects;
            //        NSMutableArray *arrayUsers=[[NSMutableArray alloc] init];
            //        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
      
        for (int j=0; j<sectionNum; j++) {
            NSMutableDictionary *useres = [[NSMutableDictionary alloc] init];
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:j inSection:i];
            XMPPUserCoreDataStorageObject *userRooster = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            NSDictionary *resp = [self contarAllMensajes:userRooster.jidStr];
            NSInteger numero=[[resp objectForKey:@"cantidad"] integerValue];
            if (numero>0) {
                [useres setObject:userRooster.jid forKey:@"jid"];
                [useres setObject:userRooster.jidStr forKey:@"jidstr"];
                [useres setObject:userRooster.displayName forKey:@"displayname"];
                [useres setObject:sectionInfo.name forKey:@"estado"];
                int cant=[self contarMensajes:userRooster.jidStr];
                [useres setObject:[NSNumber numberWithInt:cant] forKey:@"unread"];
                if (cant==0) {
                    self.fechastr=@"-";
                }
                [useres setObject:[resp objectForKey:@"fecha"] forKey:@"recent"];
                [useres setObject:[self fechastr] forKey:@"date"];
                [arrayUsers addObject:useres];
            }
        }
    }
        NSSortDescriptor *Sorter = [[NSSortDescriptor alloc] initWithKey:@"recent" ascending:NO];
        [arrayUsers sortUsingDescriptors:[NSArray arrayWithObject:Sorter]];
        
        [dict setObject:arrayUsers forKey:@"users"];
        NSString *str=@"Chat Activos";
//        switch (section)
//        {
//            case 0  : str=@"Conectado";
//                break;
//            case 1  : str=@"Ausente";
//                break;
//            default : str=@"Desconectado";
//                break;
//        }
        [dict setObject:str forKey:@"name"];
        [sectionArray addObject:dict];
            //    }
    return;
}



-(void) deleteOldRecords {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:[self appDelegate].managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSDayCalendarUnit) fromDate:[NSDate date]];
    [components setDay:-1];
    NSDate *limit = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:[NSDate date] options:0];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageDate<=%@) AND (isNew==%@)",limit,[NSNumber numberWithBool:NO]];
    [request setPredicate:predicate];
    [request setEntity:entity];
    [request returnsDistinctResults];
        // [request setFetchBatchSize:50];
    NSError *error=nil;
    NSArray *fetched = [[[self appDelegate] managedObjectContext] executeFetchRequest:request error:&error];
    for (NSManagedObject *obj in fetched) {
        [[[self appDelegate] managedObjectContext] deleteObject:obj];
    }
    error = nil;
    if (![[self appDelegate].managedObjectContext save:&error])
    {
        NSLog(@"error saving");
    }
}


- (void)listausuarios {
    [self performSegueWithIdentifier:@"full_list" sender:self];
    return;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ChatSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
//        XMPPUserCoreDataStorageObject *userRooster = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        NSDictionary *userInfo =[[[sectionArray objectAtIndex:indexPath.section]
                                  objectForKey:@"users"]
                                 objectAtIndex:indexPath.row];

        
        [[segue destinationViewController] setJidTarget:[userInfo objectForKey:@"jidstr"]];
    }
    if ([[segue identifier] isEqualToString:@"newchat"]) {
        [[segue destinationViewController] setJidTarget:jidnewchat];
        jidnewchat=@"";
    }
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
-(void) setRoster:(NSString *)userjid withPrecence:(NSString *)prec {
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(jidStr==%@)",userjid];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:50];
    [fetchRequest returnsDistinctResults];
    [fetchRequest setPredicate:predicate];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSError *error=nil;
    NSArray *useres = [moc executeFetchRequest:fetchRequest error:&error];
    if (useres.count>0) {
        NSManagedObject *obj=[useres objectAtIndex:0];
        XMPPUserCoreDataStorageObject *userroster= (XMPPUserCoreDataStorageObject *)obj;
        NSNumber *numero=userroster.sectionNum;
        int num=[numero intValue];
    }
    return;
}*/


/*
-(void) updateUnreadMessages {
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
                                              inManagedObjectContext:moc];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:50];
    [fetchRequest returnsDistinctResults];
    NSArray *sortDescriptors = [NSArray arrayWithObjects: nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    list =[[NSFetchedResultsController alloc] initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:moc sectionNameKeyPath:@"sectionNum" cacheName:nil];
    NSError *error=nil;
    NSArray *useres = [moc executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *obj in useres) {
        XMPPUserCoreDataStorageObject *coreUser=(XMPPUserCoreDataStorageObject *)obj;
        NSString *jido=coreUser.jidStr;
        int cant=[self contarMensajes:jido];
        coreUser.unreadMessages=[NSNumber numberWithInt:cant];
    }
    error = nil;
    if (![moc save:&error])
    {
        NSLog(@"error saving unread");
    }
    
}
 */

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



- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
        //    fetchedResultsController=nil;
    [self updateArray];
    [[self tableView] reloadData];
}


-(int ) contarMensajes:(NSString *)elJID {
    int cant=0;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:[self appDelegate].managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(direction==%@) AND (isNew==%@) AND (jidString==%@)",@"IN",[NSNumber numberWithBool:YES],elJID];
    [request setPredicate:predicate];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObjects:sd, nil]];
    [request returnsDistinctResults];
    [request setFetchBatchSize:50];
    NSError *error=nil;
    NSArray *fetched = [[[self appDelegate] managedObjectContext] executeFetchRequest:request error:&error];
    for (NSManagedObject *obj in fetched) {
        Chat *thisChat = (Chat *)obj;
        if ([thisChat.isNew isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            self.fechastr= [NSDateFormatter localizedStringFromDate:[thisChat messageDate]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
        }
    }
    cant = (int)[fetched count];
    return cant;
}


-(NSDictionary * ) contarAllMensajes:(NSString *)elJID {
    NSString *fecha=@"-";
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:[self appDelegate].managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(jidString==%@)",elJID];
    [request setPredicate:predicate];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"messageDate" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sd, nil]];
    [request returnsDistinctResults];
    [request setFetchBatchSize:50];
    NSError *error=nil;
    NSArray *fetched = [[[self appDelegate] managedObjectContext] executeFetchRequest:request error:&error];
    for (NSManagedObject *obj in fetched) {
        Chat *thisChat = (Chat *)obj;
        fecha= [NSDateFormatter localizedStringFromDate:[thisChat messageDate]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    }
    NSNumber *cant = [NSNumber numberWithInteger:[fetched count]];
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
    [dict setObject:cant forKey:@"cantidad"];
    [dict setObject:fecha forKey:@"fecha"];
    return dict;
}




#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self sectionArray] count];
        //return [[[self fetchedResultsController] sections] count];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
    
//    NSArray *sections = [[self fetchedResultsController] sections];
//    
//    if (sectionIndex < [sections count])
//    {
//        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
//        
//        int section = [sectionInfo.name intValue];
//        switch (section)
//        {
//            case 0  : return @"Conectado";
//            case 1  : return @"Ausente";
//            default : return @"Desconectado";
//        }
//    }
//    return @"";
    
    if (sectionIndex<[sectionArray count]) {
        return [[sectionArray objectAtIndex:sectionIndex] objectForKey:@"name"];
    }
    return @"-";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
//    NSArray *sections = [[self fetchedResultsController] sections];
//    if ([[[self appDelegate] xmppStream] isConnected]) {
//        if (sectionIndex < [sections count])
//        {
//            id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
//            return sectionInfo.numberOfObjects;
//        }
//    }
    if ([[[self appDelegate] xmppStream] isConnected]) {
        if (sectionIndex < [sectionArray count]) {
            NSDictionary *dict = [sectionArray objectAtIndex:sectionIndex];
            return [[dict objectForKey:@"users"] count];
        }
    }
    
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ContactInfo";
    
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    

    NSDictionary *userInfo =[[[sectionArray objectAtIndex:indexPath.section]
                          objectForKey:@"users"]
                         objectAtIndex:indexPath.row];
    
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
    cell.Mensajes.text = [NSString stringWithFormat:@"Mensajes: %i",[[userInfo objectForKey:@"unread"] intValue]];
    
    cell.fecha.text = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"date"]];
    [self configurePhotoForCell:cell user:userRooster];
    
    return cell;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

-(void) configurePhotoForCell:(ContactTableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)usuario {
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
