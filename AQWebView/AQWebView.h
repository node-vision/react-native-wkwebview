#import "RCTView.h"

@interface AQWebView : RCTView

@property (nonatomic, assign) UIEdgeInsets contentInset;
@property (nonatomic, assign) BOOL automaticallyAdjustContentInsets;
@property (nonatomic, copy) NSDictionary *source;
@property (nonatomic, copy) NSArray<NSString*> *blockedPrefixes;

- (void)reload;
- (void)goBack;
- (void)goForward;
- (BOOL)canGoBack;
- (BOOL)canGoForward;

@end
