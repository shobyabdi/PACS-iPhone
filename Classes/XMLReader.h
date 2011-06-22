#import "Contact.h"

@interface XMLReader : NSObject {

@private        
    Contact *_contactObj;
    NSMutableString *_contentOfCurrentContact;
}

@property (nonatomic, retain) Contact *contactObj;
@property (nonatomic, retain) NSMutableString *contentOfCurrentContact;

- (void)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error;

@end
