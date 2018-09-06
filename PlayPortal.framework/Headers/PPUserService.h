//
//  PPUserService.h
//  playportal-sdk
//
//  Created by Gary J. Baldwin on 3/4/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PPUserObject.h"
#import "PPFriendsObject.h"

@interface PPUserService : NSObject

@property (nonatomic, copy) void (^addUserListener)(PPUserObject* user, NSError *error);
- (void)login;
- (void)loginAnonymously:(int)age;
- (void)logout;
- (void)getProfile: (void(^)(NSError *error))handler;
- (UIImage*)getProfilePic:(NSString*)userId;
- (UIImage*)getCoverPic:(NSString*)userId;
- (NSString*)getMyId;
- (NSString*)getMyUsername;
- (void)getFriendsProfiles: (void(^)(NSError *error))handler;

+ (NSString *)stringFromNSDate:(NSDate*)date;
- (void)searchForUsers:(NSString*)matchingString handler:(void(^)(NSArray* matchingUsers, NSError* error))handler;
@end
