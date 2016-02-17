//
//  other.h
//  Chat_FAC
//
//  Created by Jose Valentin Restrepo on 26/01/15.
//  Copyright (c) 2015 Jose Valentin Restrepo. All rights reserved.
//

#ifndef Chat_FAC_other_h
#define Chat_FAC_other_h

// Constants
#define APP_VERSION                             [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
#define APP_NAME                                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]
#define APP_DELEGATE                            [[UIApplication sharedApplication] delegate]
#define USER_DEFAULTS                           [NSUserDefaults standardUserDefaults]
#define APPLICATION                             [UIApplication sharedApplication]
#define BUNDLE                                  [NSBundle mainBundle]
#define MAIN_SCREEN                             [UIScreen mainScreen]
#define DOCUMENTS_DIR                           [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]
#define IS_PAD                                  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

// Props
#define ScreenWidth                             [MAIN_SCREEN bounds].size.width
#define ScreenHeight                            [MAIN_SCREEN bounds].size.height

#endif
