//
//  AllesTableViewController.h
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 8/04/15.
//  Copyright (c) 2015 Jose Valentin Restrepo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllesTableViewController : UITableViewController <NSFetchedResultsControllerDelegate,UIGestureRecognizerDelegate,UISearchDisplayDelegate, UISearchBarDelegate> {
    NSFetchedResultsController *fetchedResultsController;
}

@property (strong, nonatomic) NSArray *filtro;
@property (nonatomic) NSMutableArray *arrayUsers;


@end
