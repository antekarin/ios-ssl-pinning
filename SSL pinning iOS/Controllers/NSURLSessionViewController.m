
#import "NSURLSessionViewController.h"

@interface NSURLSessionViewController () <NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation NSURLSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
}

- (IBAction)loadDataHandler:(id)sender {
    [self.activityIndicator startAnimating];

    [[self.urlSession dataTaskWithURL:[NSURL URLWithString:self.textField.text] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
            if (!error) {
                self.textView.text = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                self.textView.textColor = [UIColor blackColor];
            } else {
                self.textView.text = error.description;
                self.textView.textColor = [UIColor redColor];
            }
        });
    }] resume];
}

#pragma mark - NSURLSession delegate

-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    id<NSURLAuthenticationChallengeSender> sender = [challenge sender];
    
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
    NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
    
    NSString *pathToCert = [[NSBundle mainBundle]pathForResource:@"github.com" ofType:@"cer"];
    NSData *localCertificate = [NSData dataWithContentsOfFile:pathToCert];
    
    if ([remoteCertificateData isEqualToData:localCertificate]) {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    } else {
        [sender cancelAuthenticationChallenge:challenge];
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, NULL);
    }
}

@end
