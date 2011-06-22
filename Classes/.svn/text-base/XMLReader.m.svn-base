#import "XMLReader.h"
#import "Contact.h"

@implementation XMLReader

@synthesize contactObj = _contactObj;
@synthesize contentOfCurrentContact = _contentOfCurrentContact;

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error
{	
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    NSError *parseError = [parser parserError];
    if (parseError && error) 
	{
        *error = parseError;
    }
    [parser release];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) 
	{
        elementName = qName;
    }
    
    if ([elementName isEqualToString:@"contact"]) {
        self.contactObj = [[Contact alloc] init];
        [(id)[[UIApplication sharedApplication] delegate] performSelectorOnMainThread:@selector(addToContactList:) withObject:self.contactObj waitUntilDone:YES];
        return;
    }
        
	if ([elementName isEqualToString:@"firstname"]) 
	{
        self.contentOfCurrentContact = [NSMutableString string];
    } 
	else if ([elementName isEqualToString:@"lastname"]) 
	{
        self.contentOfCurrentContact = [NSMutableString string];
    } 
	else if ([elementName isEqualToString:@"phonenumber"]) 
	{
        self.contentOfCurrentContact = [NSMutableString string];
    } 
	else if ([elementName isEqualToString:@"email"]) 
	{
        self.contentOfCurrentContact = [NSMutableString string];
    } 
	else 
	{
        self.contentOfCurrentContact = nil;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{     
    if (qName) 
	{
        elementName = qName;
    }
    
    if ([elementName isEqualToString:@"firstname"])
	{
		self.contactObj.firstname = self.contentOfCurrentContact;
    } 
	else if ([elementName isEqualToString:@"lastname"]) 
	{
        self.contactObj.lastname = self.contentOfCurrentContact;
    } 
	else if ([elementName isEqualToString:@"phonenumber"]) 
	{
        self.contactObj.phonenumber = self.contentOfCurrentContact;
    }
	else if ([elementName isEqualToString:@"email"]) 
	{
        self.contactObj.email = self.contentOfCurrentContact;
    } 
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.contentOfCurrentContact) 
	{
        [self.contentOfCurrentContact appendString:string];
    }
}

@end
