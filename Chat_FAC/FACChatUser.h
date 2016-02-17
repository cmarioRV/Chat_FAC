//
//  FACChatUser.h
//  Chat_FAC
//
//  Created by Inter-Telco MacAir on 28/01/16.
//  Copyright (c) 2016 Jose Valentin Restrepo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FACChatUser : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* callsign;
@property (nonatomic, copy) NSString* grade;
@property (nonatomic, copy) NSString* state;
@property (nonatomic) BOOL isVisible;

+(id)userWithName:(NSString*)name andCallsign:(NSString*)callsign andGrade:(NSString*)grade andState:(NSString*)state andIsVisible:(BOOL)isVisible;

@end
