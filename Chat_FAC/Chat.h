//
//  Entity.h
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 9/01/15.
//  Copyright (c) 2015 Jose Valentin Restrepo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Chat : NSManagedObject

@property (nonatomic, retain) NSString * direction;
@property (nonatomic, retain) NSString * fileNameAsSent;
@property (nonatomic, retain) NSString * groupNumber;
@property (nonatomic, retain) NSNumber * isGroupChat;
@property (nonatomic, retain) NSNumber * isMedia;
@property (nonatomic, retain) NSNumber * isNew;
@property (nonatomic, retain) NSString * jidString;
@property (nonatomic, retain) NSString * localFileName;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) NSString * messageBody;
@property (nonatomic, retain) NSDate * messageDate;
@property (nonatomic, retain) NSString * messageStatus;
@property (nonatomic, retain) NSString * mimeType;
@property (nonatomic, retain) NSString * roomJID;
@property (nonatomic, retain) NSString * roomName;

@end
