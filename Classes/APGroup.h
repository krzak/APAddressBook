//
//  APGroup.h
//  AddressBook
//
//  Created by Marcin Krzyzanowski on 06/03/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "APTypes.h"
#import "APRecord.h"

@interface APGroup : APRecord

@property (nonatomic, readonly) NSString *name;

- (id)initWithRecordRef:(ABRecordRef)recordRef;
- (NSArray *) members:(ABRecordRef)groupRef;
- (NSArray *) members:(ABRecordRef)groupRef contactFieldMask:(APContactField)contactFieldMask contactFilterBlock:(APContactFilterBlock)filterBlock;

@end
