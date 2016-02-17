//
//  LoginViewController.h
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 4/01/15.
//  Copyright (c) 2015 Jose Valentin Restrepo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageUI/MessageUI.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UILabel *State;
@property (weak, nonatomic) IBOutlet UITextField *LoginTextField;
@property (weak, nonatomic) IBOutlet UITextField *PasswordTextField;
- (IBAction)EntrarButton:(id)sender;
- (IBAction)registrar:(id)sender;
- (IBAction)closeKb:(id)sender;

@end
