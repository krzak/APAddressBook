//
//  APContact.m
//  APAddressBook
//
//  Created by Alexey Belkevich on 1/10/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APContact.h"
#import "APPhoneWithLabel.h"

@interface APContact ()
@property (nonatomic, assign, readwrite) APContactField fieldMask;
@end

@implementation APContact

#pragma mark - life cycle

- (id)initWithRecordRef:(ABRecordRef)recordRef fieldMask:(APContactField)fieldMask
{
    self = [self initWithRecordRef:recordRef];
    if (self)
    {
        _fieldMask = fieldMask;
        if (fieldMask & APContactFieldFirstName)
        {
            _firstName = [self stringProperty:kABPersonFirstNameProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldLastName)
        {
            _lastName = [self stringProperty:kABPersonLastNameProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldCompany)
        {
            _company = [self stringProperty:kABPersonOrganizationProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldPhones)
        {
            _phones = [self arrayProperty:kABPersonPhoneProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldPhonesWithLabels)
        {
            _phonesWithLabels = [self arrayOfPhonesWithLabelsFromRecord:recordRef];
        }
        if (fieldMask & APContactFieldEmails)
        {
            _emails = [self arrayProperty:kABPersonEmailProperty fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldPhoto)
        {
            _photo = [self imagePropertyFullSize:YES fromRecord:recordRef];
        }
        if (fieldMask & APContactFieldThumbnail)
        {
            _thumbnail = [self imagePropertyFullSize:NO fromRecord:recordRef];
        }
    }
    return self;
}

@end
