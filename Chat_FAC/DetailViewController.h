//
//  DetailViewController.h
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 26/11/14.
//  Copyright (c) 2014 Jose Valentin Restrepo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

