#import "RCTView.h"

@interface AQWebView : RCTView

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL automaticallyAdjustContentInsets;
@property (nonatomic, strong) NSString *html;
@property (nonatomic, assign) NSString *baseURL;

- (void)reload;

@end
