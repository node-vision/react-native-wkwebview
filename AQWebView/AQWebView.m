#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import "AQWebView.h"
#import "RCTAutoInsetsProtocol.h"
#import "RCTConvert.h"

// lots of code from https://github.com/facebook/react-native/blob/master/React/Views/RCTWebView.m

@interface AQWebView () <RCTAutoInsetsProtocol, WKNavigationDelegate>
@property (nonatomic, copy) RCTDirectEventBlock onLoadingStart;
@property (nonatomic, copy) RCTDirectEventBlock onLoadingFinish;
@property (nonatomic, copy) RCTDirectEventBlock onLoadingError;
@property (nonatomic, copy) RCTDirectEventBlock onPrefixBlocked;
@property (nonatomic, strong) NSString *userLoadedUrl;
@end

@implementation AQWebView
{
  WKWebView *_webView;
  UIActivityIndicatorView *_spinner;
  UIRefreshControl *_refreshControl;
}

- (instancetype)initWithFrame:(CGRect)frame
{
  if ((self = [super initWithFrame:frame])) {
    super.backgroundColor = [UIColor clearColor];
    _automaticallyAdjustContentInsets = YES;
    _contentInset = UIEdgeInsetsZero;

    _webView = [[WKWebView alloc] initWithFrame:self.bounds];
    _webView.allowsBackForwardNavigationGestures = YES;
    _webView.allowsLinkPreview = YES;
    _webView.navigationDelegate = self;
    [self addSubview:_webView];

    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_spinner startAnimating];
    [_webView addSubview:_spinner];

    /*
    _refreshControl = [[UIRefreshControl alloc] init];
    [_webView.scrollView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
     */

    [_webView addConstraint:[NSLayoutConstraint constraintWithItem:_spinner
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_webView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];

    [_webView addConstraint:[NSLayoutConstraint constraintWithItem:_spinner
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_webView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1
                                                          constant:0]];
  }
  return self;
}

- (void)reload
{
  [_webView loadRequest:[NSURLRequest requestWithURL:_webView.URL]];
}

- (void)setSource:(NSDictionary *)source
{
  if (![_source isEqualToDictionary:source]) {
    _source = [source copy];
    
    // Check for a static html source first
    NSString *html = [RCTConvert NSString:source[@"html"]];
    if (html) {
      NSURL *baseURL = [RCTConvert NSURL:source[@"baseUrl"]];
      _userLoadedUrl = [baseURL absoluteString];
      [_webView loadHTMLString:html baseURL:baseURL];
      return;
    }
    
    NSURLRequest *request = [RCTConvert NSURLRequest:source];
    // Because of the way React works, as pages redirect, we actually end up
    // passing the redirect urls back here, so we ignore them if trying to load
    // the same url. We'll expose a call to 'reload' to allow a user to load
    // the existing page.
    if ([request.URL isEqual:_webView.URL]) {
      return;
    }
    if (!request.URL) {
      // Clear the webview
      [_webView loadHTMLString:@"" baseURL:nil];
      return;
    }
    _userLoadedUrl = [request.URL absoluteString];
    [_webView loadRequest:request];
  }
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  _webView.frame = self.bounds;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
  _contentInset = contentInset;
  [RCTView autoAdjustInsetsForView:self
                    withScrollView:_webView.scrollView
                      updateOffset:NO];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
  CGFloat alpha = CGColorGetAlpha(backgroundColor.CGColor);
  self.opaque = _webView.opaque = (alpha == 1.0);
  _webView.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor
{
  return _webView.backgroundColor;
}

- (void)refreshContentInset
{
  [RCTView autoAdjustInsetsForView:self
                    withScrollView:_webView.scrollView
                      updateOffset:YES];
}

- (NSMutableDictionary<NSString *, id> *)baseEvent
{
  NSMutableDictionary<NSString *, id> *event = [[NSMutableDictionary alloc] initWithDictionary:
    @{
      @"url": [_webView.URL absoluteString] ?: @"",
      @"loading" : @(_webView.loading),
      @"title": [_webView title] ?: @"",
      @"canGoBack": @(_webView.canGoBack),
      @"canGoForward" : @(_webView.canGoForward),
    }
  ];
  
  return event;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
  NSURL *url = navigationAction.request.URL;
  NSString *urlStr = [url absoluteString];
  BOOL block = false;

  if ([urlStr isEqual: @""]) {
    urlStr = @"about:blank";
  }

  if (![urlStr isEqual: _userLoadedUrl]) {
    for (id prefix in _blockedPrefixes) {
      if ([urlStr hasPrefix:prefix]) {
        NSMutableDictionary<NSString *, id> *event = [[NSMutableDictionary alloc] initWithDictionary:
                                                      @{
                                                        @"url": urlStr,
                                                        }
                                                      ];
        _onPrefixBlocked(event);
        decisionHandler(WKNavigationActionPolicyCancel);
        block = true;
        break;
      }
    }
  }

  if (!block) {
    decisionHandler(WKNavigationActionPolicyAllow);
  }
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
  [_spinner stopAnimating];
  [_refreshControl endRefreshing];

  if (_onLoadingFinish) {
    NSMutableDictionary<NSString *, id> *event = [self baseEvent];
    _onLoadingFinish(event);
  }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
  if (_onLoadingStart) {
    NSMutableDictionary<NSString *, id> *event = [self baseEvent];
    _onLoadingStart(event);
  }
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(nonnull NSError *)error
{
  [_spinner stopAnimating];
  [_refreshControl endRefreshing];

  if (_onLoadingError) {
    NSMutableDictionary<NSString *, id> *event = [self baseEvent];
    [event addEntriesFromDictionary:@{
                                      @"domain": error.domain,
                                      @"code": @(error.code),
                                      @"description": error.localizedDescription,
                                    }];
    _onLoadingError(event);
  }
}

@end
