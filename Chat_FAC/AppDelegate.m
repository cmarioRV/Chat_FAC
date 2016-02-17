//
//  AppDelegate.m
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 26/11/14.
//  Copyright (c) 2014 Jose Valentin Restrepo. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MasterViewController.h"


#import "GCDAsyncSocket.h"
#import "XMPP.h"
#import "XMPPLogging.h"
#import "XMPPReconnect.h"
#import "XMPPCapabilitiesCoreDataStorage.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPvCardAvatarModule.h"
#import "XMPPvCardCoreDataStorage.h"

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "NSXMLElement+XEP_0203.h"

#import <CFNetwork/CFNetwork.h>


// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

#if TARGET_OS_IPHONE
#import "DDXML.h"
#endif

@interface AppDelegate () {
    NSString *password;
    NSString *user;
}



@property (nonatomic, strong ) XMPPStream *xmppStream;
@property (nonatomic, strong ) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong ) XMPPRoster *xmppRoster;
@property (nonatomic, strong ) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong ) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong ) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong ) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong ) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

@end




@implementation AppDelegate

@synthesize xmppStream;
@synthesize xmppReconnect;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize xmppCapabilities;
@synthesize xmppCapabilitiesStorage;

@synthesize managedObjectContext =__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistenStoreCoordinator=__persistenStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Configure logging framework
    NSLog(@"%@", [[[UIDevice currentDevice] identifierForVendor] UUIDString]);
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
    
    // Setup the XMPP stream
    
    [self setupStream];
    
    // Setup Coredata
    
    __managedObjectContext=self.managedObjectContext;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
    }
    
    return YES;
}




-(void) setPass:(NSString *)thepass {
    password=[thepass copy];
}

-(void) setUser:(NSString *)theuser {
    user=[theuser copy];
}

- (void)applicationWillResignActive:(UIApplication *)application {
        //    [self disconnect];
        //   [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        //   [[self navigationController] popToRootViewControllerAnimated:YES];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self disconnect];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[self navigationController] popToRootViewControllerAnimated:YES];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [self disconnect];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[self navigationController] popToRootViewControllerAnimated:YES];
    
    NSMutableArray *ct=[NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *control in ct) {
        [self.navigationController popToViewController:control animated:NO];
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
        //    [self disconnect];
        //    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        //[[self navigationController] popToRootViewControllerAnimated:YES];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self disconnect];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[self navigationController] popToRootViewControllerAnimated:YES];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setupStream
{
    NSAssert(xmppStream == nil, @"Method setupStream invoked multiple times");
    
    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
    xmppStream = [[XMPPStream alloc] init];
    
#if !TARGET_IPHONE_SIMULATOR
    {
        // Want xmpp to run in the background?
        //
        // P.S. - The simulator doesn't support backgrounding yet.
        //        When you try to set the associated property on the simulator, it simply fails.
        //        And when you background an app on the simulator,
        //        it just queues network traffic til the app is foregrounded again.
        //        We are patiently waiting for a fix from Apple.
        //        If you do enableBackgroundingOnSocket on the simulator,
        //        you will simply see an error message from the xmpp stack when it fails to set the property.
        
        xmppStream.enableBackgroundingOnSocket = YES;
    }
#endif
    
    // Setup reconnect
    //
    // The XMPPReconnect module monitors for "accidental disconnections" and
    // automatically reconnects the stream for you.
    // There's a bunch more information in the XMPPReconnect header file.
    
    xmppReconnect = [[XMPPReconnect alloc] init];
    
    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.
    
        //xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
    
    xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:xmppRosterStorage];
    
    xmppRoster.autoFetchRoster = YES;
    xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    [xmppRoster setAutoClearAllUsersAndResources:YES];
    
    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    
    xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:xmppvCardStorage];
    
    xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    
    // Setup capabilities
    //
    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
    // Basically, when other clients broadcast their presence on the network
    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
    // But as you can imagine, this list starts to get pretty big.
    // This is where the hashing stuff comes into play.
    // Most people running the same version of the same client are going to have the same list of capabilities.
    // So the protocol defines a standardized way to hash the list of capabilities.
    // Clients then broadcast the tiny hash instead of the big list.
    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
    // and also persistently storing the hashes so lookups aren't needed in the future.
    //
    // Similarly to the roster, the storage of the module is abstracted.
    // You are strongly encouraged to persist caps information across sessions.
    //
    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
    // It can also be shared amongst multiple streams to further reduce hash lookups.
    
    xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:xmppCapabilitiesStorage];
    
    xmppCapabilities.autoFetchHashedCapabilities = YES;
    xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
    // Activate xmpp modules
    
    [xmppReconnect         activate:xmppStream];
    [xmppRoster            activate:xmppStream];
    [xmppvCardTempModule   activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppCapabilities      activate:xmppStream];
    
    // Add ourself as a delegate to anything we may be interested in
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // Optional:
    //
    // Replace me with the proper domain and port.
    // The example below is setup for a typical google talk account.
    //
    // If you don't supply a hostName, then it will be automatically resolved using the JID (below).
    // For example, if you supply a JID like 'user@quack.com/rsrc'
    // then the xmpp framework will follow the xmpp specification, and do a SRV lookup for quack.com.
    // 
    // If you don't specify a hostPort, then the default (5222) will be used.
    
    //	[xmppStream setHostName:@"talk.google.com"];
    //	[xmppStream setHostPort:5222];	
    
    
    // You may need to alter these settings depending on the server you're connecting to
    customCertEvaluation = YES;
    AllowSelfSignedCertificate=YES;
    AllowSSLHostNameMismatch=NO;
    
    
    
}


-(void) endRooster {
    [xmppRoster deactivate];
        //xmppRosterStorage = nil;
}

-(void) restartRooster {
    
    [xmppRoster activate:xmppStream];

}


// It's easy to create XML elments to send and to read received XML elements.
// You have the entire NSXMLElement and NSXMLNode API's.
//
// In addition to this, the NSXMLElement+XMPP category provides some very handy methods for working with XMPP.
//
// On the iPhone, Apple chose not to include the full NSXML suite.
// No problem - we use the KissXML library as a drop in replacement.
//
// For more information on working with XML elements, see the Wiki article:
// https://github.com/robbiehanson/XMPPFramework/wiki/WorkingWithElements

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
    
    NSString *domain = [xmppStream.myJID domain];
    
    //Google set their presence priority to 24, so we do the same to be compatible.
    
    if([domain isEqualToString:@"gmail.com"]
       || [domain isEqualToString:@"gtalk.com"]
       || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }
    
    [[self xmppStream] sendElement:presence];
}

- (void)goOffline
{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    
    [[self xmppStream] sendElement:presence];
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Connect/disconnect
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)connect
{
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    //NSString *myJID = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyJID];
    
    NSString *myJID;
    NSString *myPassword;
    
    myJID=user;
    myPassword=password;


//    NSString *myPassword = [[NSUserDefaults standardUserDefaults] stringForKey:kXMPPmyPassword];
    
    //
    // If you don't want to use the Settings view to set the JID,
    // uncomment the section below to hard code a JID and password.
    //
    // myJID = @"user@gmail.com/xmppframework";
    // myPassword = @"";
    
    if (myJID == nil || myPassword == nil) {
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:myJID]];
    password = myPassword;
        //        if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    
    NSError *error = nil;
    NSTimeInterval time=30.0;
    if (![xmppStream connectWithTimeout:time error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        DDLogError(@"Error connecting: %@", error);
        
        return NO;
    }
    
    return YES;
}

- (void)disconnect
{
    [self goOffline];
    [xmppStream disconnect];
    [xmppStream setMyJID:[XMPPJID jidWithString:@""]];
    password=@"";
 
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Core Data
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-(void) saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext!=nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"error en la base de datos");
            abort();
        }
    }
}

-(NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(NSManagedObjectContext *) managedObjectContext {
    if (__managedObjectContext!=nil) {
        return __managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistenStoreCoordinator];
    if (coordinator !=nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
        [__managedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_mocDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return __managedObjectContext;
}

- (void) _mocDidSaveNotification:(NSNotification *)notification {
    NSManagedObjectContext *savedContext=[notification object];
    if (__managedObjectContext == savedContext) {
        return;
    }
    if (__managedObjectContext.persistentStoreCoordinator != savedContext.persistentStoreCoordinator) {
        return;
    }
    dispatch_queue_t main = dispatch_get_main_queue();
    dispatch_sync(main, ^
                  {
                      [__managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
                  });
}

- (NSManagedObjectModel *) managedObjectModel {
    if (__managedObjectModel!=nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL=[[NSBundle mainBundle] URLForResource:@"ChatModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

-(NSPersistentStoreCoordinator *) persistenStoreCoordinator {
    if (__persistenStoreCoordinator !=nil) {
        return __persistenStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Chat.sqllite"];
    NSError *error=nil;
    __persistenStoreCoordinator =[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistenStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"error no resuelto");
        abort();
    }
    return __persistenStoreCoordinator;
}



- (NSManagedObjectContext *)managedObjectContext_roster
{
    return [xmppRosterStorage mainThreadManagedObjectContext];
}

- (NSManagedObjectContext *)managedObjectContext_capabilities
{
    return [xmppCapabilitiesStorage mainThreadManagedObjectContext];
}


/*
 Almacenar mensaje en la base de datos de mensajes recibidos y notificar a las demas ventanas de la ocurrencia del evento.
 */

-(void) updateCoreDataWithIncomingMessage:(XMPPMessage *) message {
    XMPPUserCoreDataStorageObject *userRooster = [xmppRosterStorage userForJID:[message from]
                                                                    xmppStream:xmppStream
                                                          managedObjectContext:[self managedObjectContext_roster]];
    Chat *chat= [NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:self.managedObjectContext];
    chat.messageBody =[[message elementForName:@"body"] stringValue];
    if ([message wasDelayed]==YES) {
        chat.messageDate = [message delayedDeliveryDate];
    } else {
        chat.messageDate =[NSDate date];
    }
    chat.messageStatus = @"recibido";
    chat.direction=@"IN";
    chat.groupNumber=@"";
    chat.isNew=[NSNumber numberWithBool:YES];
    chat.isMedia=[NSNumber numberWithBool:NO];
    chat.isGroupChat=[NSNumber numberWithBool:NO];
    chat.jidString=userRooster.jidStr;
    NSError *error=nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error guardando");
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MensajeNuevo" object:self userInfo:nil];
    
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPStream Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/* evento se ha conectado al servidor*/

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}


/*Evento se activo la seguridad*/

- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    if (expectedCertName)
    {
        [settings setObject:expectedCertName forKey:(NSString *)kCFStreamSSLPeerName];
    }
    
    if (customCertEvaluation)
    {
        [settings setObject:@(YES) forKey:GCDAsyncSocketManuallyEvaluateTrust];
    }
}

/**
 * Allows a delegate to hook into the TLS handshake and manually validate the peer it's connecting to.
 *
 * This is only called if the stream is secured with settings that include:
 * - GCDAsyncSocketManuallyEvaluateTrust == YES
 * That is, if a delegate implements xmppStream:willSecureWithSettings:, and plugs in that key/value pair.
 *
 * Thus this delegate method is forwarding the TLS evaluation callback from the underlying GCDAsyncSocket.
 *
 * Typically the delegate will use SecTrustEvaluate (and related functions) to properly validate the peer.
 *
 * Note from Apple's documentation:
 *   Because [SecTrustEvaluate] might look on the network for certificates in the certificate chain,
 *   [it] might block while attempting network access. You should never call it from your main thread;
 *   call it only from within a function running on a dispatch queue or on a separate thread.
 *
 * This is why this method uses a completionHandler block rather than a normal return value.
 * The idea is that you should be performing SecTrustEvaluate on a background thread.
 * The completionHandler block is thread-safe, and may be invoked from a background queue/thread.
 * It is safe to invoke the completionHandler block even if the socket has been closed.
 *
 * Keep in mind that you can do all kinds of cool stuff here.
 * For example:
 *
 * If your development server is using a self-signed certificate,
 * then you could embed info about the self-signed cert within your app, and use this callback to ensure that
 * you're actually connecting to the expected dev server.
 *
 * Also, you could present certificates that don't pass SecTrustEvaluate to the client.
 * That is, if SecTrustEvaluate comes back with problems, you could invoke the completionHandler with NO,
 * and then ask the client if the cert can be trusted. This is similar to how most browsers act.
 *
 * Generally, only one delegate should implement this method.
 * However, if multiple delegates implement this method, then the first to invoke the completionHandler "wins".
 * And subsequent invocations of the completionHandler are ignored.
 **/


/*codigo donde se valida un certificado signado*/

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
            NSLog(@"YES");
        }
        else {
            completionHandler(YES);  ////OJO CON EL CERTIFICADO
            NSLog(@"NO");
        }
    });
}

- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    isXmppConnected = YES;
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:@"Conectando" forKey:@"status"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorConnect" object:self userInfo:m];

    
    NSError *error = nil;
    
    if (![[self xmppStream] authenticateWithPassword:password error:&error])
    {
        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"Conectado" object:self userInfo:nil];
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:@"Ok" forKey:@"status"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorConnect" object:self userInfo:m];
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"No se conectó");
    [self disconnect];

    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:@"Error" forKey:@"status"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorConnect" object:self userInfo:m];
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    NSLog(@"Message IQ");
    
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // A simple example of inbound message handling.
    
    if ([message isChatMessageWithBody])
    {
        [self updateCoreDataWithIncomingMessage:message];
        
        XMPPUserCoreDataStorageObject *userRooster = [xmppRosterStorage userForJID:[message from]
                                                                 xmppStream:xmppStream
                                                       managedObjectContext:[self managedObjectContext_roster]];
        NSString *body = [[message elementForName:@"body"] stringValue];
        NSString *displayName = [userRooster displayName];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        {
//            NSString *currentController = self.navigationController.topViewController.title;
//            if ([currentController isEqualToString:[[[self xmppStream] myJID] bare]]) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
//                                                                    message:body
//                                                                   delegate:nil
//                                                          cancelButtonTitle:@"Ok"
//                                                          otherButtonTitles:nil];
//                [alertView show];
//            }
        }
        else
        {
            // We are not active, so use a local notification instead
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertAction = @"Ok";
            localNotification.alertBody = [NSString stringWithFormat:@"From: %@\n\n%@",displayName,body];
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
    } else {
        NSArray *elements = [message elementsForXmlns:@"http://jabber.org/protocol/chatstates"];
        if ([elements count]>0) {
            for (NSXMLElement *element in elements) {
                NSString *statusString = @" ";
                NSString *cleanStatus=[[element name] stringByReplacingOccurrencesOfString:@"cha:" withString:@""];
                if ([cleanStatus isEqualToString:@"composing"]) {
                    statusString =@"Escribiendo";
                }
                else if ([cleanStatus isEqualToString:@"active"]) {
                    statusString =@"Conectado";
                }
                else if ([cleanStatus isEqualToString:@"paused"]) {
                    statusString =@"Pausa";
                }
                else if ([cleanStatus isEqualToString:@"inactive"]) {
                    statusString =@"Inactivo";
                }
                else if ([cleanStatus isEqualToString:@"gone"]) {
                    statusString =@"Fuera";
                }
                NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
                [m setObject:statusString forKey:@"status"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"EstadoNuevo" object:self userInfo:m];
            }
        }
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@ - %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
        //NSLog(@"Presencia: %@",[presence fromStr]);
        //NSLog(@"EStado %@",[presence type]);
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:[presence type] forKey:@"status"];
    [m setObject:[presence fromStr] forKey:@"who"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Presencia" object:self userInfo:m];
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    if (!isXmppConnected)
    {
        DDLogError(@"Unable to connect to server. Check xmppStream.hostName");
        NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
        [m setObject:@"Error" forKey:@"status"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorConnect" object:self userInfo:m];

    }
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender{
    
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error{
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark XMPPRosterDelegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)xmppRoster:(XMPPRoster *)sender didReceiveBuddyRequest:(XMPPPresence *)presence
{
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    XMPPUserCoreDataStorageObject *userRooster = [xmppRosterStorage userForJID:[presence from]
                                                             xmppStream:xmppStream
                                                   managedObjectContext:[self managedObjectContext_roster]];
    
    NSString *displayName = [userRooster displayName];
    NSString *jidStrBare = [presence fromStr];
    NSString *body = nil;
    
    if (![displayName isEqualToString:jidStrBare])
    {
        body = [NSString stringWithFormat:@"Buddy request from %@ <%@>", displayName, jidStrBare];
    }
    else
    {
        body = [NSString stringWithFormat:@"Buddy request from %@", displayName];
    }
    
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:body
                                                           delegate:nil 
                                                  cancelButtonTitle:@"Not implemented"
                                                  otherButtonTitles:nil];
        [alertView show];
    } 
    else 
    {
        // We are not active, so use a local notification instead
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertAction = @"Not implemented";
        localNotification.alertBody = body;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
}



@end
