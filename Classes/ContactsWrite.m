#import "ContactsWrite.h"
#import "Contact.h"

static NSString *hostURL = YOURAPPENGINEURL;
static NSString *user = YOURGOOGLEUSERNAME;
static NSString *pass = YOURGOOGLEPASSWORD;

@implementation ContactsWrite


- (void)insertIntoAddressBook:(NSMutableArray *)contactlist
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef person = ABPersonCreate();
	CFErrorRef error = NULL;
	Contact *currentRecord = [[Contact alloc] init];
	
	for(int i=0; i< [contactlist count]; i++)
	{
		person = ABPersonCreate();
		currentRecord = [contactlist objectAtIndex:i];
		if(![currentRecord.firstname isEqualToString:@"None"])
		{
			ABRecordSetValue(person, kABPersonFirstNameProperty, currentRecord.firstname , &error);
		}
		if(![currentRecord.lastname isEqualToString:@"None"])
		{
			ABRecordSetValue(person, kABPersonLastNameProperty, currentRecord.lastname, &error);
		}
		ABMutableMultiValueRef phoneMulti = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(phoneMulti, currentRecord.phonenumber, kABPersonPhoneMainLabel, NULL);
		ABRecordSetValue(person, kABPersonPhoneProperty, phoneMulti, &error);
		ABMutableMultiValueRef emailMulti = ABMultiValueCreateMutable(kABStringPropertyType);
		if(![currentRecord.email isEqualToString:@"None"])
		{
			ABMultiValueAddValueAndLabel(emailMulti, currentRecord.email, kABHomeLabel, NULL);
			ABRecordSetValue(person, kABPersonEmailProperty, emailMulti, &error); 
		}
		ABAddressBookAddRecord(addressBook, person, &error);
		ABAddressBookSave(addressBook, &error);
		CFRelease(phoneMulti);
		CFRelease(emailMulti);
		CFRelease(person);
	}
	[contactlist release];
	[currentRecord release];
	CFRelease(addressBook);
	
}

- (NSString *)trim:(NSString *)value
{
	// get a scanner, initialised with our input string
	NSScanner *sourceHTMLScanner = [NSScanner scannerWithString:value];
	// create a mutable output string (empty for now)
	NSMutableString *cleanedSourceHTMLString = [[NSMutableString alloc] init];
	
	// create an array of chars for all control characters between 0×00 and 0×1F, apart from \t, \n, \f and \r (which are at code points 0×09, 0×0A, 0×0C and 0×0D respectively)
	
	
	// convert this array into an NSCharacterSet
	NSString *controlCharString = @"()- ";
	NSCharacterSet *controlCharSet = [NSCharacterSet characterSetWithCharactersInString:controlCharString];
	
	// request that the scanner ignores these characters
	[sourceHTMLScanner setCharactersToBeSkipped:controlCharSet];
	
	// run through the string to remove control characters
	while ([sourceHTMLScanner isAtEnd] == NO) {
		NSString *outString;
		// scan up to the next instance of one of the control characters
		if ([sourceHTMLScanner scanUpToCharactersFromSet:controlCharSet intoString:&outString]) {
			// add the string chunk to our output string
			[cleanedSourceHTMLString appendString:outString];
		}
	}
	return cleanedSourceHTMLString;
} 

- (void)addToGoogleSpreadsheet:(ABRecordRef)nonSyncedRecord
{
	CFStringRef firstName = ABRecordCopyValue(nonSyncedRecord, kABPersonFirstNameProperty);
	CFStringRef lastName = ABRecordCopyValue(nonSyncedRecord, kABPersonLastNameProperty);
	ABMutableMultiValueRef emailMulti = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	CFStringRef phoneNumber, emailAddress = nil;
	CFIndex i;
	emailMulti = ABRecordCopyValue(nonSyncedRecord, kABPersonEmailProperty);
	for (i = 0; i < ABMultiValueGetCount(emailMulti); i++) 
	{
		if(ABMultiValueCopyValueAtIndex(emailMulti, i) != nil)
		{
			emailAddress = ABMultiValueCopyValueAtIndex(emailMulti, i);
			break;
		}
	}
	ABMutableMultiValueRef phonemulti = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	phonemulti = ABRecordCopyValue(nonSyncedRecord, kABPersonPhoneProperty);
	for (i = 0; i < ABMultiValueGetCount(phonemulti); i++) 
	{
		if(ABMultiValueCopyValueAtIndex(phonemulti, i) != nil)
		{
			phoneNumber = ABMultiValueCopyValueAtIndex(phonemulti, i);
			break;
		}
	}
	
	NSString *contactFirst = [NSString stringWithFormat:@"%@", (NSString *)firstName];
	NSString *contactLast = [NSString stringWithFormat:@"%@", (NSString *)lastName];
	NSString *contactPhone = [NSString stringWithFormat:@"%@", (NSString *)phoneNumber];
	NSString *contactEmail;
	if(emailAddress != nil)
	{
		contactEmail = [NSString stringWithFormat:@"%@", (NSString *)emailAddress];
	}
	else
	{
		contactEmail = @"";
	}
	if([contactLast isEqualToString:@"(null)"])
	{
		contactLast = @"";
	}
	contactPhone = [self trim:contactPhone]; 
	NSString *urltogo = [[NSArray arrayWithObjects: hostURL, @"/addcontact?", @"un=", user, @"&pw=", pass, @"&first=", contactFirst, @"&last=", contactLast, @"&phone=", contactPhone, @"&email=", contactEmail, nil] componentsJoinedByString:@""];
	NSLog(urltogo);
	NSMutableURLRequest *theRequest = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString:urltogo] ];
	NSHTTPURLResponse* response;
    NSError* error;
	[theRequest setHTTPMethod:@"GET"];
	NSData *returnData = [ NSURLConnection sendSynchronousRequest: theRequest returningResponse: &response error: &error];
	NSString *checkData = [[NSString alloc] initWithData:returnData encoding:NSASCIIStringEncoding];
	NSLog(checkData);
	/*[contactFirst release];
	[contactLast release];
	[contactPhone release];
	[contactEmail release];
	[urltogo release];
	[theRequest release];
	[response release];
	[error release];
	[returnData release];
	[checkData release];*/
	CFRelease(firstName);
	if(lastName != nil)
	{
		CFRelease(lastName);
	}
	CFRelease(phoneNumber);
	if(emailAddress != nil)
	{
		CFRelease(emailAddress);
	}
	CFRelease(emailMulti);
	CFRelease(phonemulti);
}

- (void)crossCheckAddressBookWithList:(NSMutableArray *)contactlist addressBook:(ABAddressBookRef)m_addressbook
{
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(m_addressbook);
	CFIndex nPeople = ABAddressBookGetPersonCount(m_addressbook);
	for (int i=0;i < nPeople;i++) 
	{
		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
		if([self recordExistInSpreadsheet:ref allContacts:contactlist] == NO)
		{
			[self addToGoogleSpreadsheet:ref];
		}
		//CFRelease(ref);
	}
	CFRelease(allPeople);
	//CFRelease(nPeople);
}

- (void)crossCheckListWithAddressBook:(NSMutableArray *)contactlist addressBook:(ABAddressBookRef)m_addressbook
{
	Contact *currentRecord = [[Contact alloc] init];
	for (int i=0;i < [contactlist count];i++) 
	{
		currentRecord = [contactlist objectAtIndex:i];
		if([self recordExistInAddressBook:currentRecord allAddressBook:m_addressbook] == NO)
		{
			[self insertSingleRecordIntoAddressBook:currentRecord];
		}
		[currentRecord release];
	}
}

- (BOOL)recordExistInSpreadsheet:(ABRecordRef)checkAddRecord allContacts:(NSMutableArray *)contactlist
{
	CFStringRef firstName = ABRecordCopyValue(checkAddRecord, kABPersonFirstNameProperty);
	CFStringRef lastName = ABRecordCopyValue(checkAddRecord, kABPersonLastNameProperty);
	NSString *contactFirst = [NSString stringWithFormat:@"%@", (NSString *)firstName];
	NSString *contactLast = [NSString stringWithFormat:@"%@", (NSString *)lastName];
	if([contactLast isEqualToString:@"(null)"])
	{
		contactLast = @"None";
	}
	Contact *checkRecord = [[Contact alloc] init];
	Boolean foundrecord = NO;
	for(int i=0; i< [contactlist count]; i++)
	{
		checkRecord = [contactlist objectAtIndex:i];
		if([checkRecord.firstname isEqualToString:contactFirst] && [checkRecord.lastname isEqualToString:contactLast])
		{
				foundrecord = YES;
				break;
		}
	}
	/*[checkRecord release];
	CFRelease(firstName);
	[contactFirst release];
	if(lastName != nil)
	{
		CFRelease(lastName);
		[contactLast release];
	}*/
	return foundrecord;
}

- (BOOL)recordExistInAddressBook:(Contact *)checkRecord allAddressBook:(ABAddressBookRef)bookList
{
	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(bookList);
	CFIndex nPeople = ABAddressBookGetPersonCount(bookList);
	Boolean foundrecord = NO;
	for (int i=0;i < nPeople;i++) 
	{
		ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
		CFStringRef firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
		CFStringRef lastName = ABRecordCopyValue(ref, kABPersonLastNameProperty);
		NSString *contactFirst = [NSString stringWithFormat:@"%@", (NSString *)firstName];
		NSString *contactLast = [NSString stringWithFormat:@"%@", (NSString *)lastName];
		if([contactLast isEqualToString:@"(null)"])
		{
			contactLast = @"None";
		}
		if([checkRecord.firstname isEqualToString:contactFirst] && [checkRecord.lastname isEqualToString:contactLast])
		{
			foundrecord = YES;
			break;
		}
		//CFRelease(firstName);
		//CFRelease(lastName);
		//[contactFirst release];
		//[contactLast release];
	}
	CFRelease(allPeople);
	//CFRelease(nPeople);
	return foundrecord;
}

- (void)insertSingleRecordIntoAddressBook:(Contact *)singleRecord
{
	ABAddressBookRef addressBook = ABAddressBookCreate();
	ABRecordRef person = ABPersonCreate();
	CFErrorRef error = NULL;
	if(![singleRecord.firstname isEqualToString:@"None"])
	{
		ABRecordSetValue(person, kABPersonFirstNameProperty, singleRecord.firstname , &error);
	}
	if(![singleRecord.lastname isEqualToString:@"None"])
	{
		ABRecordSetValue(person, kABPersonLastNameProperty, singleRecord.lastname, &error);
	}
	ABMutableMultiValueRef phoneMulti = ABMultiValueCreateMutable(kABMultiStringPropertyType);
	ABMultiValueAddValueAndLabel(phoneMulti, singleRecord.phonenumber, kABPersonPhoneMainLabel, NULL);
	ABRecordSetValue(person, kABPersonPhoneProperty, phoneMulti, &error);
	ABMutableMultiValueRef emailMulti = ABMultiValueCreateMutable(kABStringPropertyType);
	if(![singleRecord.email isEqualToString:@"None"])
	{
		ABMultiValueAddValueAndLabel(emailMulti, singleRecord.email, kABHomeLabel, NULL);
		ABRecordSetValue(person, kABPersonEmailProperty, emailMulti, &error); 
	}
	ABAddressBookAddRecord(addressBook, person, &error);
	ABAddressBookSave(addressBook, &error);
	CFRelease(phoneMulti);
	CFRelease(emailMulti);
	CFRelease(person);
}



@end
