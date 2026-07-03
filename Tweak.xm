#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>
#import <objc/runtime.h>

static char ChatGPTOverlayGestureInstalledKey;

@interface ChatGPTOverlay : NSObject
+ (instancetype)shared;
- (void)installGestureRecognizers;
- (void)openInSafari;
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

- (UIWindowScene *)activeWindowScene {
    for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
        if ([s isKindOfClass:[UIWindowScene class]] && s.activationState == UISceneActivationStateForegroundActive) {
            return (UIWindowScene *)s;
        }
    }

    for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
        if ([s isKindOfClass:[UIWindowScene class]]) {
            return (UIWindowScene *)s;
        }
    }

    return nil;
}

- (void)setupIfNeeded {
    if (_overlayWindow) return;

    UIWindowScene *scene = [self activeWindowScene];
    if (!scene) return;

    _overlayWindow = [[UIWindow alloc] initWithWindowScene:scene];
    _overlayWindow.frame = UIScreen.mainScreen.bounds;
    _overlayWindow.windowLevel = UIWindowLevelAlert + 1;
    _overlayWindow.backgroundColor = UIColor.clearColor;
    _overlayWindow.hidden = YES;

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

    UIButton *safariBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [safariBtn setTitle:@"Login/Safari" forState:UIControlStateNormal];
    safariBtn.frame = CGRectMake(CGRectGetMaxX(closeBtn.frame) + 12, 40, 120, 32);
    safariBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [safariBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    safariBtn.layer.cornerRadius = 8;
    [safariBtn addTarget:self action:@selector(openInSafari) forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:safariBtn];

    NSURL *url = [NSURL URLWithString:@"https://chat.openai.com"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)installGestureRecognizers {
    for (UIScene *s in [UIApplication sharedApplication].connectedScenes) {
        if (![s isKindOfClass:[UIWindowScene class]]) continue;

        for (UIWindow *window in ((UIWindowScene *)s).windows) {
            if (!window || window == _overlayWindow) continue;
            if (objc_getAssociatedObject(window, &ChatGPTOverlayGestureInstalledKey)) continue;

            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                initWithTarget:self action:@selector(toggle)];
            tap.numberOfTouchesRequired = 3;
            tap.cancelsTouchesInView = NO;
            [window addGestureRecognizer:tap];

            objc_setAssociatedObject(window, &ChatGPTOverlayGestureInstalledKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

- (void)openInSafari {
    [self setupIfNeeded];
    if (!_overlayWindow.rootViewController) return;

    NSURL *url = _webView.URL ?: [NSURL URLWithString:@"https://chat.openai.com"];
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
    safari.modalPresentationStyle = UIModalPresentationFullScreen;
    [_overlayWindow.rootViewController presentViewController:safari animated:YES completion:nil];
}

- (void)toggle {
    [self setupIfNeeded];
    if (!_overlayWindow) return;

    _visible = !_visible;
    _overlayWindow.hidden = !_visible;
    if (_visible) [_overlayWindow makeKeyAndVisible];
}

@end

static void chatgpt_overlay_install(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ChatGPTOverlay shared] installGestureRecognizers];
    });
}

__attribute__((constructor))
static void chatgpt_overlay_entry(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        NSOperationQueue *queue = [NSOperationQueue mainQueue];

        [center addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:queue usingBlock:^(__unused NSNotification *note) {
            chatgpt_overlay_install();
        }];
        [center addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:queue usingBlock:^(__unused NSNotification *note) {
            chatgpt_overlay_install();
        }];
        [center addObserverForName:UIWindowDidBecomeKeyNotification object:nil queue:queue usingBlock:^(__unused NSNotification *note) {
            chatgpt_overlay_install();
        }];

        chatgpt_overlay_install();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            chatgpt_overlay_install();
        });
    });
}
