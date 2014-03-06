//
//  APAddressBook.m
//  APAddressBook
//
//  Created by Alexey Belkevich on 1/10/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "APAddressBook.h"
#import "APContact.h"
#import "APGroup.h"

#import <pthread.h>

@interface APAddressBook ()
@property (nonatomic, readonly) ABAddressBookRef addressBook;
@end

@implementation APAddressBook {
    pthread_mutex_t _mutex;
}

#pragma mark - life cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        CFErrorRef *error = NULL;
        _addressBook = ABAddressBookCreateWithOptions(NULL, error);
        if (error)
        {
            NSLog(@"%@", (__bridge_transfer NSString *)CFErrorCopyFailureReason(*error));
            return nil;
        }
        _mutex = (pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER;
    }
    return self;
}

- (void)dealloc
{
    if (_addressBook)
    {
        CFRelease(_addressBook);
    }
}

#pragma mark - public

+ (APAddressBookAccess)access
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    switch (status)
    {
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted:
            return APAddressBookAccessDenied;

        case kABAuthorizationStatusAuthorized:
            return APAddressBookAccessGranted;

        default:
            return APAddressBookAccessUnknown;
    }
}

- (void)loadContacts:(void (^)(NSArray *contacts, NSError *error))callbackBlock
{
    [self loadContacts:dispatch_get_main_queue() fieldMask:APContactFieldDefault completion:callbackBlock];
}

- (void)loadContacts:(APContactField)fieldMask completion:(void (^)(NSArray *contacts, NSError *error))callbackBlock
{
    [self loadContacts:dispatch_get_main_queue() fieldMask:fieldMask completion:callbackBlock];
}

- (void)loadContacts:(dispatch_queue_t)completionQueue fieldMask:(APContactField)fieldMask completion:(void (^)(NSArray *contacts, NSError *error))callbackBlock
{
    NSArray *descriptors = self.sortDescriptors;
    APContactFilterBlock filterBlock = self.filterBlock;

    __weak typeof(self) weakSelf = self;
    pthread_mutex_lock(&_mutex);
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef errorRef)
    {
        dispatch_barrier_sync(completionQueue, ^{
            NSArray *array = nil;
            NSError *error = nil;
            if (granted)
            {
                CFArrayRef peopleArrayRef = ABAddressBookCopyArrayOfAllPeople(weakSelf.addressBook);
                NSUInteger contactCount = (NSUInteger)CFArrayGetCount(peopleArrayRef);
                NSMutableArray *contacts = [[NSMutableArray alloc] init];
                for (NSUInteger i = 0; i < contactCount; i++)
                {
                    ABRecordRef recordRef = CFArrayGetValueAtIndex(peopleArrayRef, i);
                    APContact *contact = [[APContact alloc] initWithRecordRef:recordRef
                                                                    fieldMask:fieldMask];
                    if (!filterBlock || filterBlock(contact))
                    {
                        [contacts addObject:contact];
                    }
                }
                [contacts sortUsingDescriptors:descriptors];
                array = contacts.copy;
                CFRelease(peopleArrayRef);
            }
            else if (errorRef)
            {
                error = (__bridge NSError *)errorRef;
            }

            if (callbackBlock)
            {
                dispatch_async(completionQueue, ^{
                    callbackBlock(array, error);
                });
            }
        });
    });
    pthread_mutex_unlock(&_mutex);
}

- (void)loadGroups:(void (^)(NSArray *groups, NSError *error))callbackBlock
{
    [self loadGroups:dispatch_get_main_queue() completion:callbackBlock];
}

- (void)loadGroups:(dispatch_queue_t)completionQueue completion:(void (^)(NSArray *groups, NSError *error))callbackBlock
{
    __weak typeof(self) weakSelf = self;
    pthread_mutex_lock(&_mutex);
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef errorRef)
    {
        dispatch_barrier_sync(completionQueue, ^{
            NSError *error = nil;
            NSArray *array = nil;
            if (granted)
            {
                NSMutableArray *groups = [NSMutableArray array];
                CFArrayRef groupsArrayRef = ABAddressBookCopyArrayOfAllGroups(weakSelf.addressBook);
                for (CFIndex i = 0; i < CFArrayGetCount(groupsArrayRef); i++) {
                    ABRecordRef recordRef = (ABRecordRef)CFArrayGetValueAtIndex(groupsArrayRef, i);
                    APGroup *apGroup = [[APGroup alloc] initWithRecordRef:recordRef];
                    [groups addObject:apGroup];
                }
                array = [groups copy];
                CFRelease(groupsArrayRef);
            }
            else if (errorRef)
            {
                error = (__bridge NSError *)errorRef;
            }

            if (callbackBlock)
            {
                dispatch_async(completionQueue, ^{
                    callbackBlock(array, error);
                });
            }
        });
    });
    pthread_mutex_unlock(&_mutex);
}

@end
