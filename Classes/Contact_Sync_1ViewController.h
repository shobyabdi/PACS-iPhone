#import <UIKit/UIKit.h>

@interface Contact_Sync_1ViewController : UIViewController {
	
	IBOutlet UILabel *label;
	IBOutlet UIProgressView *progress;
	NSString *string;

}

@property (nonatomic, retain) UIProgressView *progress;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, copy) NSString *string;

- (void)updateString:(NSString *)statussofar;

@end

