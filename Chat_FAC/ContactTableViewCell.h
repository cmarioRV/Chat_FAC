//
//  ContactTableViewCell.h
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 15/02/15.
//  Copyright (c) 2015 Jose Valentin Restrepo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *Contacto;
@property (weak, nonatomic) IBOutlet UILabel *Mensajes;
@property (weak, nonatomic) IBOutlet UILabel *fecha;
@property (weak, nonatomic) IBOutlet UIImageView *photo;

@end
