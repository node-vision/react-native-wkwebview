#import <WebKit/WebKit.h>
#import "AQWebViewManager.h"
#import "AQWebView.h"

#import "RCTBridge.h"
#import "RCTUIManager.h"
#import "RCTWebView.h"
#import "UIView+React.h"

@implementation AQWebViewManager

RCT_EXPORT_MODULE()

- (UIView *) view
{
    return [[AQWebView alloc] init];
}

RCT_REMAP_VIEW_PROPERTY(url, URL, NSURL);
RCT_EXPORT_VIEW_PROPERTY(contentInset, UIEdgeInsets);
RCT_EXPORT_VIEW_PROPERTY(automaticallyAdjustContentInsets, BOOL);
RCT_EXPORT_VIEW_PROPERTY(html, NSString*);
RCT_EXPORT_VIEW_PROPERTY(baseURL, NSString*);
RCT_EXPORT_VIEW_PROPERTY(onLoadingStart, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLoadingFinish, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLoadingError, RCTDirectEventBlock)

RCT_EXPORT_METHOD(reload:(nonnull NSNumber *)reactTag)
{
  [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, AQWebView *> *viewRegistry) {
    AQWebView *view = viewRegistry[reactTag];
    if (![view isKindOfClass:[AQWebView class]]) {
      RCTLogError(@"Invalid view returned from registry, expecting RCTWebView, got: %@", view);
    }
    else {
      [view reload];
    }
  }];
}

@end