#import "Contact_Sync_1AppDelegate.h"
#import "Contact_Sync_1ViewController.h"
#import "Contact.h"
#import "XMLReader.h"
#import "ContactsWrite.h"

static NSString *hostURL = @"http://spacechaos.appspot.com";
static NSString *user = @"shobyabdi";
static NSString *pass = @"thereisnogodbutallah";
//static NSString *testURL = @"http://spacechaos.appspot.com/allcontacts?un=shobyabdi&pw=thereisnogodbutallah";

@implementation Contact_Sync_1AppDelegate

@synthesize window;
@synthesize viewController;
@synthesize list;

-(void)getContactData
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSError *parseError = nil;
	
	NSString *passinData = [[NSArray arrayWithObjects: hostURL, @"/allcontacts?", @"un=", user, @"&pw=", pass, nil] componentsJoinedByString:@""];
    
    XMLReader *streamingParser = [[XMLReader alloc] init];
    [streamingParser parseXMLFileAtURL:[NSURL URLWithString:passinData] parseError:&parseError];
    [streamingParser release];
	
	ContactsWrite *writingToContacts = [[ContactsWrite alloc] init]; 
	ABAddressBookRef m_addressbook = ABAddressBookCreate();
	CFIndex nPeople = ABAddressBookGetPersonCount(m_addressbook);
	if(nPeople > 0)
	{
		if(nPeople > [list count])
		{
			[writingToContacts crossCheckAddressBookWithList:self.list addressBook:m_addressbook];
		}
		else if(nPeople < [list count])
		{
			[writingToContacts crossCheckListWithAddressBook:self.list addressBook:m_addressbook];
		}
	}
	else
	{
		[writingToContacts insertIntoAddressBook:self.list];
	}
	[writingToContacts release];
    [pool release];
}

- (void)addToContactList:(Contact *)newContact
{
    [self.list addObject:newContact];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
	self.list = [NSMutableArray array];
	[self getContactData];
	//NSString *text = @"Hello World";
	//[viewController updateString:text];
	//[NSThread detachNewThreadSelector:@selector(getContactData) toTarget:self withObject:nil];
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
	[self dealloc];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
