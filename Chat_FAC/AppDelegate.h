//
//  AppDelegate.h
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 26/11/14.
//  Copyright (c) 2014 Jose Valentin Restrepo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPPFramework.h"
#import "LoginViewController.h"




@interface AppDelegate : UIResponder <UIApplicationDelegate,XMPPRosterDelegate>
{
    BOOL AllowSelfSignedCertificate;
    //bool isXMPPConnected;
    BOOL AllowSSLHostNameMismatch;
    
    BOOL customCertEvaluation;
    BOOL isXmppConnected;
    
    
    XMPPStream *xmppStream;
    XMPPReconnect *xmppReconnect;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPCapabilities *xmppCapabilities;
    XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;
    
    LoginViewController *LoginController;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;

//XMPP
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

//@property (nonatomic, strong) IBOutlet UIWindow *window;

//@property (nonatomic, strong) IBOutlet SettingsViewController *settingsViewController;
//@property (nonatomic, strong) IBOutlet UIBarButtonItem *loginButton;

- (NSManagedObjectContext *)managedObjectContext_roster;
- (NSManagedObjectContext *)managedObjectContext_capabilities;

//coredata
@property (readonly,nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (readonly,nonatomic,strong) NSManagedObjectModel *managedObjectModel;
@property (readonly,nonatomic,strong) NSPersistentStoreCoordinator *persistenStoreCoordinator;

-(void) saveContext;

- (BOOL)connect;
- (void)disconnect;

-(void) setUser:(NSString *)theuser;
-(void) setPass:(NSString *)thepass;

-(void) endRooster;
-(void) restartRooster;


@end

