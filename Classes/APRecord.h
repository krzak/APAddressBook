//
//  APRecord.h
//  AddressBook
//
//  Created by Marcin Krzyzanowski on 08/03/14.
//  Copyright (c) 2014 alterplay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface APRecord : NSObject {
    @protected
    ABRecordID _recordID;
    ABRecordType _recordType;
}

@property (nonatomic, assign) ABRecordID recordID;
@property (nonatomic, assign) ABRecordType recordType;

- (id)initWithRecordRef:(ABRecordRef)recordRef;

- (NSString *)stringProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef;
- (NSArray *)arrayProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef;
- (NSArray *)arrayOfPhonesWithLabelsFromRecord:(ABRecordRef)recordRef;
- (UIImage *)imagePropertyFullSize:(BOOL)isFullSize fromRecord:(ABRecordRef)recordRef;
- (NSString *)localizedLabelFromMultiValue:(ABMultiValueRef)multiValue index:(NSUInteger)index;
- (void)enumerateMultiValueOfProperty:(ABPropertyID)property fromRecord:(ABRecordRef)recordRef
                            withBlock:(void (^)(ABMultiValueRef multiValue, NSUInteger index))block;

@end
