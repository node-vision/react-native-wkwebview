#import "RCTView.h"

@interface AQWebView : RCTView

@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL automaticallyAdjustContentInsets;
@property (nonatomic, copy) NSDictionary *source;

- (void)reload;

@end
