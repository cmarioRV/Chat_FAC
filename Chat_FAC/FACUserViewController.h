//
//  FACUserViewController.h
//  Chat_FAC
//
//  Created by Inter-Telco MacAir on 28/01/16.
//  Copyright (c) 2016 Jose Valentin Restrepo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FACUserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
