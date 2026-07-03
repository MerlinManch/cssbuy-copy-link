#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ChatGPTOverlay : NSObject
+ (instancetype)shared;
- (void)toggle;
@end

@implementation ChatGPTOverlay {
    UIWindow *_overlayWindow;
    WKWebView *_webView;
    BOOL _visible;
}

+ (instancetype)shared {
    static ChatGPTOverlay *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [ChatGPTOverlay new];
    });
    return instance;
}

- (void)setupIfNeeded {
    if (_overlayWindow) return;

    UIWindowScene *scene = nil;
    for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
        if ([s isKindOfClass:[UIWindowScene class]]) {
            scene = (UIWindowScene *)s;
            break;
        }
    }

    _overlayWindow = [[UIWindow alloc] initWithWindowScene:scene];
    _overlayWindow.frame = UIScreen.mainScreen.bounds;
    _overlayWindow.windowLevel = UIWindowLevelAlert + 1;
    _overlayWindow.backgroundColor = UIColor.clearColor;

    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    _overlayWindow.rootViewController = vc;

    CGRect webFrame = CGRectInset(UIScreen.mainScreen.bounds, 20, 80);
    _webView = [[WKWebView alloc] initWithFrame:webFrame];
    _webView.layer.cornerRadius = 16;
    _webView.layer.masksToBounds = YES;
    [vc.view addSubview:_webView];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeBtn setTitle:@"✕ Schließen" forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(20, 40, 120, 32);
    closeBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [closeBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    closeBtn.layer.cornerRadius = 8;
    [closeBtn addTarget:self action:@selector(toggle) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:closeBtn];

    NSURL *url = [NSURL URLWithString:@"https://chat.openai.com"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)toggle {
    [self setupIfNeeded];
    _visible = !_visible;
    _overlayWindow.hidden = !_visible;
    if (_visible) [_overlayWindow makeKeyAndVisible];
}

@end

__attribute__((constructor)) static void entry() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
            if ([s isKindOfClass:[UIWindowScene class]]) {
                for (UIWindow *w in ((UIWindowScene *)s).windows) {
                    if (w.isKeyWindow) { keyWindow = w; break; }
                }
            }
        }
        if (!keyWindow) return;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
            initWithTarget:[ChatGPTOverlay shared] action:@selector(toggle)];
        tap.numberOfTouchesRequired = 3;
        tap.cancelsTouchesInView = NO;
        [keyWindow addGestureRecognizer:tap];
    });
}
