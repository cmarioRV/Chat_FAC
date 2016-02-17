//
//  ChatViewController.h
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 9/01/15.
//  Copyright (c) 2015 Jose Valentin Restrepo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatViewController : UITableViewController <UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>  {
    NSString *jidTarget;
}
@property (nonatomic) NSString *jidTarget;
@property (nonatomic,strong) UIView *sendView;
@property (nonatomic,strong) UITextField *sendText;
@property (nonatomic,strong) UIButton *sendButton;
@property (nonatomic,strong) UIImageView *closekbd;

- (IBAction)SendMsg:(id)sender;

@end
