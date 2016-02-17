//
//  MasterViewController.h
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 26/11/14.
//  Copyright (c) 2014 Jose Valentin Restrepo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate,UIGestureRecognizerDelegate> {
    //NSString *password;
    //NSString *user;
    NSFetchedResultsController *fetchedResultsController;
        // NSFetchedResultsController *list;
}

//@property (nonatomic) NSString *password;
//@property (nonatomic) NSString *user;
@property (nonatomic) NSMutableArray *sectionArray;
@property (nonatomic) NSMutableArray *rosterInSection;


@end

