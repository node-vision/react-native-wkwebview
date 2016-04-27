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

RCT_EXPORT_VIEW_PROPERTY(contentInset, UIEdgeInsets);
RCT_EXPORT_VIEW_PROPERTY(automaticallyAdjustContentInsets, BOOL);
RCT_EXPORT_VIEW_PROPERTY(onLoadingStart, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLoadingFinish, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLoadingError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary)
RCT_EXPORT_VIEW_PROPERTY(blockedPrefixes, NSArray<NSString*>)
RCT_EXPORT_VIEW_PROPERTY(onPrefixBlocked, RCTDirectEventBlock)

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

RCT_EXPORT_METHOD(navigationState:(nonnull NSNumber *)reactTag callback:(RCTResponseSenderBlock)callback)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, AQWebView *> *viewRegistry) {
        AQWebView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[AQWebView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTWebView, got: %@", view);
        }
        else {
            BOOL canGoForward = [view canGoForward];
            BOOL canGoBack = [view canGoBack];
            NSDictionary *data = @{@"canGoForward": @(canGoForward),
                                   @"canGoBack": @(canGoBack)};
            callback(@[[NSNull null], data]);
        }
    }];
}

RCT_EXPORT_METHOD(goBack:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, AQWebView *> *viewRegistry) {
        AQWebView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[AQWebView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTWebView, got: %@", view);
        }
        else {
            [view goBack];
        }
    }];
}
RCT_EXPORT_METHOD(goForward:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, AQWebView *> *viewRegistry) {
        AQWebView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[AQWebView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTWebView, got: %@", view);
        }
        else {
            [view goForward];
        }
    }];
}

@end