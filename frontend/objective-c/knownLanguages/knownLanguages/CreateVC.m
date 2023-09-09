//
//  CreateVC.m
//  knownLanguages
//
//  Created by Tan Junhe on 2/9/23.
//

#import "CreateVC.h"
#import "DataController.h"
#import "SceneDelegate.h"

@interface CreateVC ()
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *dobTF;
@property (weak, nonatomic) IBOutlet UIPickerView *genderPV;


@property UIDatePicker *datePicker;

@property NSString *url;
@property NSArray *genderList;

@property NSString *name;
@property NSString *password;
@property NSString *token;
@property NSString *dob;
@property NSString *gender;

@property FormatDate *FD;

@end

@implementation CreateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _url = [[IPSetting sharedInstance] setUrl];
    _genderList = [[UserGender sharedInstance] gender];
    
    _FD = [[FormatDate alloc] init];
    
    _datePicker = [[UIDatePicker alloc] init];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [_datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    _datePicker.frame = CGRectMake(0, 0, 0, 300);
    _datePicker.maximumDate = [[NSDate alloc] init];
    _dobTF.inputView = _datePicker;
    if (@available(iOS 14.0, *)) {
        _datePicker.preferredDatePickerStyle = UIDatePickerStyleInline;
    } else if (@available(iOS 13.4, *)) {
        _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    } else {
        
    }
    
    _dob = @"";
    _gender = _genderList[0];
    _genderPV.delegate = self;
    _genderPV.dataSource = self;
}

//pickerview gender
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
   return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _genderList.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _genderList[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.gender = _genderList[row];
}


- (void)dateChange:(UIDatePicker *)datePicker {
    _dobTF.text = [_FD formatDate:datePicker.date];
    _dob = [_FD formatDateSQL:datePicker.date];
}

- (IBAction)createBTN:(id)sender {
    _gender = _gender == _genderList[0] ? @"" : _gender;
    _name = _nameTF.text;
    _password = _passwordTF.text;
    NSDictionary *jsonBodyDict = @{@"name": _name,
                                   @"password": _password,
                                   @"email": _emailTF.text,
                                   @"dob": _dob,
                                   @"gender": _gender};
    NSData *params = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];
    [self apiCall:@"createUser" :params :@"POST"];
}

- (void)loadDefault {
    [[self nameTF] setText:@""];
    [[self passwordTF] setText:@""];
    [[self emailTF] setText:@""];
    _dob = @"";
    _datePicker.date = [NSDate date];
    _gender = _genderList[0];
    [_genderPV selectRow:0 inComponent:0 animated:YES];
    
}

- (void)alertShowUp: (NSString*)title : (NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([title  isEqual: @"Successfully"]){
            NSDictionary *jsonBodyDict = @{@"name": self.name, @"password":self.password, @"device":[[UIDevice currentDevice] name]};
            NSData *params = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];
            [self apiCall:@"login" :params :@"POST"];
        }else{
            if([message containsString:@"name"]){
                [[self nameTF] setText:@""];
            }else if([message containsString:@"password"]){
                [[self passwordTF] setText:@""];
            }else if([message containsString:@"email"]){
                [[self emailTF] setText:@""];
            }else{
                [self loadDefault];
            }
        }
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
            if(!error) {
                bool check = [[jsonResult objectForKey:@"check"] boolValue];
                if(check){
                    if([endPoint isEqualToString:@"createUser"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertShowUp:@"Successfully" :[jsonResult objectForKey:@"result"]];
                        });
                    }else if([endPoint isEqualToString:@"login"]){
                        [[NSUserDefaults standardUserDefaults] setObject:[jsonResult objectForKey:@"token"] forKey:@"token"];
                        [[NSUserDefaults standardUserDefaults] setObject:[self name] forKey:@"name"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                            UIViewController *mainTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
                            SceneDelegate *sceneDelegate = (SceneDelegate *)[[[UIApplication sharedApplication] connectedScenes].allObjects.firstObject delegate];
                            [sceneDelegate changeRootViewController:mainTabBarController];
                        });
                    }
                    
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self alertShowUp:@"Error" :[jsonResult objectForKey:@"result"]];
                    });
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
