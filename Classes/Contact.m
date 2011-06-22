//
//  Contact.m
//  Contact Sync 1
//
//  Created by iPhone Dev on 1/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Contact.h"


@implementation Contact

@synthesize firstname, lastname, phonenumber, email;

- (void)dealloc {
    [firstname release];
    [lastname release];
    [phonenumber release];
	[email release];
    [super dealloc];
}

@end
