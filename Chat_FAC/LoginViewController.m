//
//  LoginViewController.m
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 4/01/15.
//  Copyright (c) 2015 Jose Valentin Restrepo. All rights reserved.
//

#import "LoginViewController.h"
#import "MasterViewController.h"
#include <sys/socket.h> 
#include <sys/sysctl.h>
#include <net/if.h> 
#include <net/if_dl.h> 
#import "MessageUI/MessageUI.h"



#import "AppDelegate.h"

@interface LoginViewController () {
    NSString *usuario;
    NSString *contrasena;
}


@end

@implementation LoginViewController


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}




- (void)viewDidLoad {
    [super viewDidLoad];
        //CoreTelephony *tel=[[CoreTelephony alloc]]
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"TabBar"]==YES) {
        MasterViewController *vc=[segue destinationViewController];
            //NSString *clave=[[self PasswordTextField] text];
            //NSString *macid=[self getMacAddress];
            //NSLog(@"MAC -> %@",macid);
            //clave=[clave stringByAppendingString:[[self ReadIdentifier] UUIDString]];
        //vc.password=contrasena;
        //vc.user=usuario;
            //        vc.user=[[[self LoginTextField] text] stringByAppendingString:@"@pruebas.op.cetad.net"];
        [[self LoginTextField] setText:@""];
        [[self PasswordTextField] setText:@""];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ErrorConnect" object:nil];
    }
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


-(void) clearRoster {
    NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject" inManagedObjectContext:moc]];
    [allCars setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * cars = [moc executeFetchRequest:allCars error:&error];
        //error handling goes here
    for (NSManagedObject * car in cars) {
        [moc deleteObject:car];
    }
    NSError *saveError = nil;
    [moc save:&saveError];
    
}


- (IBAction)EntrarButton:(id)sender {
    if ([self.LoginTextField.text length]!=0 && [self.PasswordTextField.text length]!=0) {
        //almacenar Login en Usuario
        
        if ([self.LoginTextField isFirstResponder])
            [self.LoginTextField resignFirstResponder ];
        if ([self.PasswordTextField isFirstResponder])
            [self.PasswordTextField resignFirstResponder ];
        
        //realizar Login
        if ([self.LoginTextField.text length]!=0 && [self.PasswordTextField.text length]!=0) {
            NSString *clave=[[self PasswordTextField] text];
            NSString *macid=[self getMacAddress];
            NSLog(@"MAC -> %@",macid);
                //clave=[clave stringByAppendingString:[[self ReadIdentifier] UUIDString]];
            contrasena=clave;
                //vc.password=clave ;
            usuario=[[[self LoginTextField] text] stringByAppendingString:@"@cetadoficina.fortiddns.com"];
                //vc.user=[[[self LoginTextField] text] stringByAppendingString:@"@cetad1.fortiddns.com"];
            [[self appDelegate] setUser:usuario];
            [[self appDelegate] setPass:contrasena];
            
                //borra lista usuarios
            
             if ([[self appDelegate] connect]) {
                //[self performSegueWithIdentifier: @"Login" sender: self];
                [[self State] setText:@"Buscando"];
                [[self activity] startAnimating];
                [[self activity] setHidden:NO];
            }
        }
    }
}


- (IBAction)registrar:(id)sender {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (picker!=nil) {
    
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Información usuario"];
    
        // Set up the recipients.
    NSArray *toRecipients = [NSArray arrayWithObjects:@"samuelone@gmail.com",
                             nil];
    
    [picker setToRecipients:toRecipients];
    NSString *macid=[self getMacAddress];
    NSString *emailBody = @"macid->";
    emailBody=[emailBody stringByAppendingString:macid];
    emailBody=[emailBody stringByAppendingString:@"UUID->"];
    emailBody=[emailBody stringByAppendingString:[[self ReadIdentifier] UUIDString]];
    NSLog(@"MAC-> %@",macid);
    [picker setMessageBody:emailBody isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)closeKb:(id)sender {
    if ([self.LoginTextField isFirstResponder])
        [self.LoginTextField resignFirstResponder ];
    if ([self.PasswordTextField isFirstResponder])
        [self.PasswordTextField resignFirstResponder ];
}


    // The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}




-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
}


-(NSUUID *) ReadIdentifier {
    NSUUID *id =[[UIDevice currentDevice] identifierForVendor];
    NSLog(@"ID: %@", id);
    return id;
}


- (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
        // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
        // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
            // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
                // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                    // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
        // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        if (msgBuffer) {
            free(msgBuffer);
        }
        return errorFlag;
    }
    
        // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
        // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
        // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
        // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
        // Release the buffer memory
    free(msgBuffer);
    return macAddressString;
}


#pragma mark -  Navigation

-(void) viewDidAppear:(BOOL)animated {
        //    [self.appDelegate.xmppRoster.xmppRosterStorage clearAllUsersAndResourcesForXMPPStream:nil];
    [[self appDelegate] disconnect];
    [[[self appDelegate] xmppvCardTempModule] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorConnect:) name:@"ErrorConnect" object:nil];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
    }
    [[self activity] setHidden:YES];
}

-(void)errorConnect:(NSNotification *)notification {
    NSString * not=[[notification userInfo] valueForKey:@"status"];
    if ([not isEqualToString:@"Conectando"]) {
        [[self State] setText:@"Conectando"];
    }
    else if ([not isEqualToString:@"Error"]) {
        [[self activity] stopAnimating];
        [[self activity] setHidden:YES];
        [[self State] setText:@"Error Login"];
        UIAlertView *aleta=[[UIAlertView alloc] initWithTitle:@"Error" message:@"No es posible conectar" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [aleta show];
    }
    else if ([not isEqualToString:@"Ok"]) {
        [self performSegueWithIdentifier: @"TabBar" sender: self];
        [[self State] setText:@""];
    } else {
        
    }
    
}

#pragma mark Textdelegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
