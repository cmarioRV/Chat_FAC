//
//  ChatViewController.m
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 9/01/15.
//  Copyright (c) 2015 Jose Valentin Restrepo. All rights reserved.
//
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <CoreData/CoreData.h>
#import "ChatViewController.h"
#import "InTableViewCell.h"
#import "EmptyTableViewCell.h"
#import "AppDelegate.h"
#import "Chat.h"

@interface ChatViewController () {
    NSMutableArray *chats;
    float prevLines;
    CGRect recttext;
    CGRect rectview;
    CGRect rectNav;
}

@property (nonatomic) NSMutableArray *chats;
    //@property (strong) InTableViewCell  *incellproto;
@property (nonatomic,strong) UITextView *msgText;

@end

@implementation ChatViewController

@synthesize chats;
@synthesize jidTarget;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //load prototype table cell nib static
    //self.incellproto = [self.tableView dequeueReusableCellWithIdentifier:@"InChat"];
    self.sendView = [[UIView alloc] initWithFrame:CGRectMake(0,ScreenHeight-56,ScreenWidth,56)];
    self.sendView.backgroundColor=[UIColor colorWithRed:0.08 green:0.57 blue:0.78 alpha:1.0];
    [self.sendView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closekb:)]];
    self.msgText = [[UITextView alloc] initWithFrame:CGRectMake(47,10,185,36)];
    recttext=self.msgText.frame;
    rectview=self.sendView.frame;
    rectNav=self.navigationController.visibleViewController.view.frame;
    self.msgText.backgroundColor = [UIColor whiteColor];
    self.msgText.autocorrectionType=UITextAutocorrectionTypeNo;
    self.msgText.textColor=[UIColor blackColor];
    self.msgText.font=[UIFont boldSystemFontOfSize:14];
    self.msgText.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin;
    self.msgText.layer.cornerRadius = 5.0f;
    self.msgText.returnKeyType=UIReturnKeyDefault;
    self.msgText.keyboardDismissMode=UIScrollViewKeyboardDismissModeNone;
    self.msgText.keyboardType=UIKeyboardTypeASCIICapable;
    self.msgText.showsHorizontalScrollIndicator=NO;
    self.msgText.showsVerticalScrollIndicator=NO;
    self.msgText.delegate=self;
    [self.sendView addSubview:self.msgText];
    self.msgText.contentInset = UIEdgeInsetsMake(0,0,0,0);
    prevLines=0.9375f;
    self.sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.sendButton setTitle:@"Enviar" forState:UIControlStateNormal];
    [self.sendButton setTitle:@"Enviando" forState:UIControlStateSelected];
    [self.sendButton addTarget:self action:@selector(SendMsg:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setContentEdgeInsets:UIEdgeInsetsMake(2, 6, 2, 6)];
    [self.sendButton sizeToFit];
    [self.sendButton.titleLabel setTextColor:[UIColor whiteColor]];
    self.sendButton .center = CGPointMake(ScreenWidth-20-(self.sendButton.frame.size.width/2), 28);
    [self.sendView addSubview:self.sendButton];
    self.closekbd = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 15.0, 30.0, 30.0)];
    [self.closekbd setImage:[UIImage imageNamed:@"arrow.png"]];
    [self.sendView addSubview:self.closekbd];
    [self.navigationController.view addSubview:self.sendView];
    NSString *stri =self.jidTarget;
    stri=[stri substringToIndex:[stri rangeOfString:@"@"].location];
    [self setTitle:stri];
    
    [self loadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMessageRec:)
                                                 name:@"MensajeNuevo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(estadoActualizado:)
                                                 name:@"EstadoNuevo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closekb2:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        [self.navigationController.interactivePopGestureRecognizer setEnabled:NO];
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToBottomAnimated:YES];
    [[[self navigationController] interactivePopGestureRecognizer] setDelegate:self];
}

-(BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return NO;
}


-(void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.sendView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MensajeNuevo" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EstadoNuevo" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MensajeNuevo" object:self userInfo:nil];
    self.sendView=nil;
}

-(void) newMessageRec:(NSNotification *) notificacion {
    [self loadData];
    
}

-(void) estadoActualizado:(NSNotification *)notificacion {
    [self loadData];
}

-(void) loadData {
    if (self.chats) {
        self.chats=nil;
    }
    self.chats=[[NSMutableArray alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Chat" inManagedObjectContext:[self appDelegate].managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isGroupChat==%@) AND (jidString==%@)",[NSNumber numberWithBool:NO],[self jidTarget]];
    [request setPredicate:predicate];
    [request setEntity:entity];
    [request returnsDistinctResults];
    [request setFetchBatchSize:50];
    NSError *error=nil;
    NSArray *fetched = [[[self appDelegate] managedObjectContext] executeFetchRequest:request error:&error];
    for (NSManagedObject *obj in fetched) {
        [self.chats addObject:obj];
        Chat *thisChat = (Chat *)obj;
            //NSLog(@"result %@, chat=%@",thisChat.isNew,thisChat.messageBody);
        if ([thisChat.isNew isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            thisChat.isNew = [NSNumber numberWithBool:NO];
            thisChat.messageDate =[NSDate date];
        }
    }
    error = nil;
    if (![[self appDelegate].managedObjectContext save:&error])
    {
        NSLog(@"error saving");
    }

    [self.tableView reloadData];
    [self scrollToBottomAnimated:YES];
}

#pragma mark screenupdates
//when you start entering text, the table view should be shortened

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger bottomRow = [self.chats count];
    if (bottomRow >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath
                               atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark Textdelegate



//-(BOOL) textFieldShouldReturn:(UITextField *)textField {
//    [textField resignFirstResponder];
//    [UIView setAnimationDuration:0.3];
//    self.sendView.frame = CGRectMake(0,ScreenHeight-56,ScreenWidth,56);
//    [UIView commitAnimations];
//    return YES;
//}


-(void) closekb:(UITapGestureRecognizer *)recognizer {
    if ([self.msgText isFirstResponder])
        [self.msgText resignFirstResponder ];
    [UIView beginAnimations:@"moveView" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [self.navigationController.visibleViewController.view setFrame:CGRectMake(rectNav.origin.x, rectNav.origin.y, rectNav.size.width, rectNav.size.height)];
    [self.sendView setFrame:CGRectMake(rectview.origin.x, ScreenHeight-56, ScreenWidth, 56)];
    [UIView commitAnimations];
    [self.msgText setFrame:CGRectMake(recttext.origin.x, recttext.origin.y, 185, 36.0)];
        //Send your chat state
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:self.jidTarget];
    NSXMLElement *status = [NSXMLElement elementWithName:@"active" xmlns:@"http://jabber.org/protocol/chatstates"];
    [message addChild:status];
    [[self appDelegate].xmppStream sendElement:message];
    
}

-(void) closekb2:(NSNotification *)not {
    [UIView beginAnimations:@"moveView" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [self.navigationController.visibleViewController.view setFrame:CGRectMake(rectNav.origin.x, rectNav.origin.y, rectNav.size.width, rectNav.size.height)];
    [self.sendView setFrame:CGRectMake(rectview.origin.x, ScreenHeight-56, ScreenWidth, 56)];
    [UIView commitAnimations];
    [self.msgText setFrame:CGRectMake(recttext.origin.x, recttext.origin.y, 185, 36.0)];
        //Send your chat state
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:self.jidTarget];
    NSXMLElement *status = [NSXMLElement elementWithName:@"active" xmlns:@"http://jabber.org/protocol/chatstates"];
    [message addChild:status];
    [[self appDelegate].xmppStream sendElement:message];
    
}


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    NSString *label = [textView text];
    CGSize stringSize = [label sizeWithFont:[UIFont boldSystemFontOfSize:15]
                          constrainedToSize:CGSizeMake(180, 9999)
                              lineBreakMode:NSLineBreakByWordWrapping];
    float offset=0;
    if (stringSize.height>36.0) {
        offset=stringSize.height-36.0;
        if (offset>100.0) {
            offset=100;
        }
    }
    [textView setFrame:CGRectMake(recttext.origin.x, recttext.origin.y, 185, 36.0+offset)];
    
    [UIView beginAnimations:@"moveView" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [self.navigationController.visibleViewController.view setFrame:CGRectMake(rectNav.origin.x, rectNav.origin.y, rectNav.size.width, rectNav.size.height-270)];
    [self.sendView setFrame:CGRectMake(rectview.origin.x, ScreenHeight-270-offset, ScreenWidth, 56+offset)];
     [UIView commitAnimations];
    //[self shortenTableView];
    [self.msgText becomeFirstResponder];
    
    
    //Send your chat state
    NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
    [message addAttributeWithName:@"type" stringValue:@"chat"];
    [message addAttributeWithName:@"to" stringValue:self.jidTarget];
    NSXMLElement *status = [NSXMLElement elementWithName:@"composing" xmlns:@"http://jabber.org/protocol/chatstates"];
    [message addChild:status];
    [[self appDelegate].xmppStream sendElement:message];
    
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self scrollToBottomAnimated:YES];
}

-(void) textViewDidChange:(UITextView *)textView {
    NSString *label = [textView text];
    CGSize stringSize = [label sizeWithFont:[UIFont boldSystemFontOfSize:15]
                          constrainedToSize:CGSizeMake(180, 9999)
                              lineBreakMode:NSLineBreakByWordWrapping];
    float offset=0;
    if (stringSize.height>36.0) {
        offset=stringSize.height-36.0;
        if (offset>100.0) {
            offset=100;
        }
    }
    [textView setFrame:CGRectMake(recttext.origin.x, recttext.origin.y, 185, 36.0+offset)];
    [self.sendView setFrame:CGRectMake(rectview.origin.x, ScreenHeight-270-offset, ScreenWidth, 56+offset)];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[self chats] count]+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row<([[self chats] count])) {
        return [self basicCellAtIndexPath:indexPath];
    } else {
        EmptyTableViewCell *celltype= [tableView dequeueReusableCellWithIdentifier:@"emptycell" forIndexPath:indexPath];
        if (celltype==nil) {
            celltype = [[EmptyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptycell"];
            [self scrollToBottomAnimated:YES];
        }
        return celltype;
    }
    
        //    return cell;
}

- (InTableViewCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath {
    InTableViewCell *cell;
    Chat *obj = [[self chats] objectAtIndex:indexPath.row];
    if ([[obj direction] isEqualToString:@"IN"]==YES) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"InChat" forIndexPath:indexPath];
            // [cell setBackgroundView:[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"chatin.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(120.0, 0.0, 120.0, 0.0) resizingMode:UIImageResizingModeStretch]]];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"outChat" forIndexPath:indexPath];
            //[cell setBackgroundView:[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"chatout.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(120.0, 0.0, 120.0, 0.0) resizingMode:UIImageResizingModeStretch]]];
    }
    
    [self configureBasicCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureBasicCell:(InTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Chat *obj = [[self chats] objectAtIndex:indexPath.row];
    [[cell RcvMsg] setText:[obj messageBody]];
    [[cell fecha] setText:[NSDateFormatter localizedStringFromDate:[obj messageDate]
                                                         dateStyle:NSDateFormatterShortStyle
                                                         timeStyle:NSDateFormatterShortStyle]];
    UIImage *image = [[cell image] image];
    if (image)
    {
        UIImage *capImage = [image resizableImageWithCapInsets:
                             UIEdgeInsetsMake(0, 0, 25, 0)];
        
        [[cell image] setImage:capImage];
    }

}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row<([[self chats] count])) {
        Chat *obj = [[self chats] objectAtIndex:indexPath.row];
        NSString *label =[obj messageBody];
        
        CGSize stringSize = [label sizeWithFont:[UIFont boldSystemFontOfSize:18]
                              constrainedToSize:CGSizeMake(320, 9999)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        
        if (stringSize.height+30<60.0) {
            return 60.0;
        } else {
            return stringSize.height+30;
        }
    }
    return 60.0;
    
}


    


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

    
    
- (IBAction)SendMsg:(id)sender {
    NSString *messageStr = self.msgText.text;
    if([messageStr length] > 0)
    {
        //send chat message
        
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:self.jidTarget];
        [message addChild:body];
        NSXMLElement *status = [NSXMLElement elementWithName:@"active" xmlns:@"http://jabber.org/protocol/chatstates"];
        [message addChild:status];
        
        [[self appDelegate].xmppStream sendElement:message];
        // We need to put our own message also in CoreData of course and reload the data
        Chat *chat = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Chat"
                      inManagedObjectContext:[self appDelegate].managedObjectContext];
        chat.messageBody = messageStr;
        chat.messageDate = [NSDate date];
        chat.isMedia=[NSNumber numberWithBool:NO];
        chat.isNew=[NSNumber numberWithBool:NO];
        chat.messageStatus=@"send";
        chat.direction = @"OUT";
        chat.groupNumber=@"";
        chat.isGroupChat=[NSNumber numberWithBool:NO];
        chat.jidString =  self.jidTarget;
        
        NSError *error = nil;
        if (![[self appDelegate].managedObjectContext save:&error])
        {
            NSLog(@"error saving");
        }
        
        self.msgText.text=@"";
        
        //Reload our data
        [self loadData];
        
//        [UIView beginAnimations:@"moveView" context:nil];
//        [UIView setAnimationDuration:0.3];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
//        [self.navigationController.visibleViewController.view setFrame:CGRectMake(rectNav.origin.x, rectNav.origin.y, rectNav.size.width, rectNav.size.height)];
//        [self.sendView setFrame:CGRectMake(rectview.origin.x, ScreenHeight-56, ScreenWidth, 56)];
//        [UIView commitAnimations];
        
        NSXMLElement *xmlmessage = [NSXMLElement elementWithName:@"message"];
        [xmlmessage addAttributeWithName:@"type" stringValue:@"chat"];
        [xmlmessage addAttributeWithName:@"to" stringValue:self.jidTarget];
        NSXMLElement *xmlstatus = [NSXMLElement elementWithName:@"active" xmlns:@"http://jabber.org/protocol/chatstates"];
        [xmlmessage addChild:xmlstatus];
        [[self appDelegate].xmppStream sendElement:xmlmessage];
    }
    UIButton *buton = (UIButton *)sender;
    [buton.titleLabel setTextColor:[UIColor colorWithRed:0.08 green:0.57 blue:0.78 alpha:1.0]];

}




@end
