//
//  InTableViewCell.h
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 25/01/15.
//  Copyright (c) 2015 Jose Valentin Restrepo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *RcvMsg;
@property (weak, nonatomic) IBOutlet UILabel *fecha;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@end
