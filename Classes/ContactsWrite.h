//
//  ContactsWrite.h
//  Contact Sync 1
//
//  Created by iPhone Dev on 1/22/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Contact.h"


@interface ContactsWrite : NSObject {

}


- (void)insertIntoAddressBook:(NSMutableArray *)contactlist;
- (void)addToGoogleSpreadsheet:(ABRecordRef)nonSyncedRecord;
- (void)crossCheckAddressBookWithList:(NSMutableArray *)contactlist addressBook:(ABAddressBookRef)m_addressbook;
- (void)crossCheckListWithAddressBook:(NSMutableArray *)contactlist addressBook:(ABAddressBookRef)m_addressbook;
- (void)insertSingleRecordIntoAddressBook:(Contact *)singleRecord;
- (BOOL)recordExistInSpreadsheet:(ABRecordRef)checkAddRecord allContacts:(NSMutableArray *)contactlist;
- (BOOL)recordExistInAddressBook:(Contact *)checkRecord allAddressBook:(ABAddressBookRef)bookList;
- (NSString *)trim:(NSString *)value;

@end
