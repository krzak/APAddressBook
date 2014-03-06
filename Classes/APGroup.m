//
//  APGroup.m
//  AddressBook
//
//  Created by Marcin Krzyzanowski on 06/03/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APGroup.h"
#import "APContact.h"
#import <pthread.h>

@interface APGroup ()
@property (nonatomic, assign, readwrite) ABRecordID recordID;
@end

@implementation APGroup {
    pthread_mutex_t _mutex;
}

- (id)initWithRecordRef:(ABRecordRef)recordRef
{
    if (self = [super initWithRecordRef:recordRef]) {
        _name = [self stringProperty:kABGroupNameProperty fromRecord:recordRef];
        _mutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
    }
    return self;
}

- (NSArray *) members:(ABRecordRef)groupRef
{
    return [self members:groupRef contactFieldMask:APContactFieldDefault contactFilterBlock:nil];
}

- (NSArray *) members:(ABRecordRef)groupRef contactFieldMask:(APContactField)contactFieldMask contactFilterBlock:(APContactFilterBlock)filterBlock;
{
    pthread_mutex_lock(&_mutex);
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    
    CFArrayRef membersArrayRef = ABGroupCopyArrayOfAllMembers(groupRef);
    if (!membersArrayRef)
        return nil;
    
    for (NSUInteger i = 0; i < CFArrayGetCount(membersArrayRef); i++)
    {
        ABRecordRef recordRef = CFArrayGetValueAtIndex(membersArrayRef, i);
        APContact *contact = [[APContact alloc] initWithRecordRef:recordRef
                                                        fieldMask:contactFieldMask];

        if (!filterBlock || filterBlock(contact))
        {
            [contacts addObject:contact];
        }
    }
    pthread_mutex_unlock(&_mutex);
   return [contacts copy];
}


@end
