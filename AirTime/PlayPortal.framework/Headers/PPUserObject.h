//
//  PPUserObject.h
//  HelloWorld
//
//  Created by Gary J. Baldwin on 3/7/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PPUserObject : NSObject

@property NSString* userId;
@property NSString* handle;
@property NSString* firstName;
@property NSString* lastName;
@property NSString* country;
@property NSString* accountType;
@property NSString* userType;
@property NSDictionary* parentFlags;
@property NSString* profilePicId;
@property UIImage* profilePic;
@property NSString* coverPhotoId;
@property UIImage* coverPhoto;
@property NSString* myDataStorage;
@property NSString* myAppGlobalDataStorage; // shared among all app users
@property NSString* myAge;
@property Boolean isAnonymousUser;

- (void)inflateWith:(NSDictionary*)d;
- (NSString*)getMyDataStorageName;

@end
