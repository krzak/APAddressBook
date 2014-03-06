//
//  APAddressBook.h
//  APAddressBook
//
//  Created by Alexey Belkevich on 1/10/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APTypes.h"

@class APContact;

@interface APAddressBook : NSObject

@property (nonatomic, copy) APContactFilterBlock filterBlock;
@property (nonatomic, strong) NSArray *sortDescriptors;

+ (APAddressBookAccess)access;

- (void)loadContacts:(void (^)(NSArray *contacts, NSError *error))callbackBlock;
- (void)loadContacts:(APContactField)fieldMask completion:(void (^)(NSArray *contacts, NSError *error))callbackBlock;
- (void)loadContacts:(dispatch_queue_t)completionQueue fieldMask:(APContactField)fieldMask completion:(void (^)(NSArray *contacts, NSError *error))callbackBlock;

- (void)loadGroups:(void (^)(NSArray *groups, NSError *error))callbackBlock;
- (void)loadGroups:(dispatch_queue_t)completionQueue completion:(void (^)(NSArray *groups, NSError *error))callbackBlockl;

@end
