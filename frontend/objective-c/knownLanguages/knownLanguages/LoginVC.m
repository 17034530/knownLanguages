//
//  LoginVC.m
//  knownLanguages
//
//  Created by Tan Junhe on 26/8/23.
//

#import "LoginVC.h"
#import "DataController.h"
#import "SceneDelegate.h"

@interface LoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *ipSetting;

@property NSString * url;
@property NSString *name;

@end

@implementation LoginVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _url = [[IPSetting sharedInstance] setUrl];
    [self linkIPSettingVC];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _url = [[IPSetting sharedInstance] setUrl];
    [self linkIPSettingVC];
}

- (void) linkIPSettingVC {
#if DEBUG
    self.ipSetting.enabled = NO;
    self.ipSetting.tintColor = [UIColor clearColor];
#else
    self.ipSetting.enabled = YES;
#endif
}

- (IBAction)loginBTN:(id)sender {
    _name = [[self nameTF] text];
    NSDictionary *jsonBodyDict = @{@"name": _name, @"password":[[self passwordTF] text], @"device":[[UIDevice currentDevice] name]};
    NSData *params = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];
    [self apiCall:@"login" :params :@"POST"];
}

- (void)alertShowUp: (NSString*)title : (NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            //button click event
                        }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)apiCall: (NSString*)endPoint : (NSData*)params : (NSString*)resMethod{
    
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = resMethod;
    
    [request setURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@",_url,endPoint]]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:params];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(error){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertShowUp:@"Error" :[error localizedDescription]];
            });
        }else{
            NSError *error;
            NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//            NSLog(@"The response is - %@",jsonResult);
            if(!error){
                if([endPoint isEqualToString:@"login"]){
                    bool check = [[jsonResult objectForKey:@"check"] boolValue];
                    if(check)
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:[jsonResult objectForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setObject:[self name] forKey:@"name"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                            UIViewController *mainTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
                            SceneDelegate *sceneDelegate = (SceneDelegate *)[[[UIApplication sharedApplication] connectedScenes].allObjects.firstObject delegate];
                            [sceneDelegate changeRootViewController:mainTabBarController];
                        });
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertShowUp:@"Error" :[jsonResult objectForKey:@"result"]];
                        });
                    }
                }
            }else{
                NSLog(@"%@",error);
            }

        }
        
    }];
    [dataTask resume];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
