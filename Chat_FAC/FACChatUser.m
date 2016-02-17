//
//  FACChatUser.m
//  Chat_FAC
//
//  Created by Inter-Telco MacAir on 28/01/16.
//  Copyright (c) 2016 Jose Valentin Restrepo. All rights reserved.
//

#import "FACChatUser.h"

@implementation FACChatUser

@synthesize name = _name;
@synthesize callsign = _callsign;
@synthesize grade = _grade;
@synthesize state = _state;
@synthesize isVisible = _isVisible;

+(id)userWithName:(NSString*)name andCallsign:(NSString*)callsign andGrade:(NSString*)grade andState:(NSString*)state andIsVisible:(BOOL)isVisible
{
    return [[FACChatUser alloc] initWithName:name andCallsign:callsign andGrade:grade andState:state andIsVisible:state];
}

-(id)initWithName:(NSString*)name andCallsign:(NSString*)callsign andGrade:(NSString*)grade andState:(NSString*)state andIsVisible:(BOOL)isVisible {
    self = [super init];
    if(self){
        self.name      = name;
        self.callsign  = callsign;
        self.grade     = grade;
        self.state     = state;
        self.isVisible = isVisible;
    }
    return self;
}

@end
