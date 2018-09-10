//
//  PPFriendsObject.h
//  HelloWorld
//
//  Created by Gary J. Baldwin on 3/9/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PPUserObject.h"

@interface PPFriendsObject : PPUserObject
@property NSMutableDictionary *myFriends;

- (void)inflateFriendsList:(NSMutableArray*)a;
- (NSInteger)getFriendsCount;
- (UIImage*)getFriendsProfilePic:(NSString*)friendId;
- (UIImage*)getFriendsCoverPic:(NSString*)friendId;
- (NSDictionary*)getFriendAtIndex:(NSInteger)index;
@end
