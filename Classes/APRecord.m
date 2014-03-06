//
//  APRecord.m
//  AddressBook
//
//  Created by Marcin Krzyzanowski on 08/03/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import "APRecord.h"
#import "APPhoneWithLabel.h"

@implementation APRecord

- (id)initWithRecordRef:(ABRecordRef)recordRef
{
    if (self = [self init]) {
        self.recordID = ABRecordGetRecordID(recordRef);
        self.recordType = ABRecordGetRecordType(recordRef);
    }
    return self;
}

#pragma mark - utils

- (NSString *)stringProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    CFTypeRef valueRef = (ABRecordCopyValue(recordRef, property));
    return (__bridge_transfer NSString *)valueRef;
}

- (NSArray *)arrayProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self enumerateMultiValueOfProperty:property fromRecord:recordRef
                              withBlock:^(ABMultiValueRef multiValue, NSUInteger index)
     {
         CFTypeRef value = ABMultiValueCopyValueAtIndex(multiValue, index);
         NSString *string = (__bridge_transfer NSString *)value;
         if (string)
         {
             [array addObject:string];
         }
     }];
    return array.copy;
}

- (NSArray *)arrayOfPhonesWithLabelsFromRecord:(ABRecordRef)recordRef
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self enumerateMultiValueOfProperty:kABPersonPhoneProperty fromRecord:recordRef
                              withBlock:^(ABMultiValueRef multiValue, NSUInteger index)
     {
         CFTypeRef rawPhone = ABMultiValueCopyValueAtIndex(multiValue, index);
         NSString *phone = (__bridge_transfer NSString *)rawPhone;
         if (phone)
         {
             NSString *label = [self localizedLabelFromMultiValue:multiValue index:index];
             APPhoneWithLabel *phoneWithLabel = [[APPhoneWithLabel alloc] initWithPhone:phone
                                                                                  label:label];
             [array addObject:phoneWithLabel];
         }
     }];
    return array.copy;
}

- (UIImage *)imagePropertyFullSize:(BOOL)isFullSize fromRecord:(ABRecordRef)recordRef
{
    ABPersonImageFormat format = isFullSize ? kABPersonImageFormatOriginalSize :
    kABPersonImageFormatThumbnail;
    NSData *data = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(recordRef, format);
    return [UIImage imageWithData:data scale:UIScreen.mainScreen.scale];
}

- (NSString *)localizedLabelFromMultiValue:(ABMultiValueRef)multiValue index:(NSUInteger)index
{
    NSString *label;
    CFTypeRef rawLabel = ABMultiValueCopyLabelAtIndex(multiValue, index);
    if (rawLabel)
    {
        CFStringRef localizedLabel = ABAddressBookCopyLocalizedLabel(rawLabel);
        if (localizedLabel)
        {
            label = (__bridge_transfer NSString *)localizedLabel;
        }
        CFRelease(rawLabel);
    }
    return label;
}

- (void)enumerateMultiValueOfProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
                            withBlock:(void (^)(ABMultiValueRef multiValue, NSUInteger index))block
{
    ABMultiValueRef multiValue = ABRecordCopyValue(recordRef, property);
    NSUInteger count = (NSUInteger)ABMultiValueGetCount(multiValue);
    for (NSUInteger i = 0; i < count; i++)
    {
        block(multiValue, i);
    }
    CFRelease(multiValue);
}


@end
