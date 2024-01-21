//
//  ProfileVC.m
//  knownLanguages
//
//  Created by Tan Junhe on 20/1/24.
//

#import "ProfileVC.h"
#import "knownLanguages-Swift.h"
 
@interface ProfileVC ()

@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *currentPWTF;
@property (weak, nonatomic) IBOutlet UITextField *PWTFnew;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UITextField *dobTF;
@property (weak, nonatomic) IBOutlet UIPickerView *genderPV;

@property UIDatePicker *datePicker;

@property NSString *url;
@property NSArray *genderList;

@property NSString *name;
@property NSString *token;
@property NSString *dob;
@property NSString *gender;

@property FormatDate *FD;

@end

@implementation ProfileVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self startLoad];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self startLoad];
    
}

- (void)startLoad{
    _url = [[IPSetting sharedInstance] setUrl];

    _genderList = [UserGender sharedInstance].gender;
    
    _FD = [[FormatDate alloc] init];
    
    _name = [[NSUserDefaults standardUserDefaults] stringForKey:@"name"];
    _token = [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    NSDictionary *jsonBodyDict = @{@"name": _name, @"token":_token};
    NSData *params = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];
    [self apiCall:@"profile" :params :@"POST"];
    
    [_nameTF setText:_name];
    
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
    _genderPV.delegate = self;
    _genderPV.dataSource = self;
    
}

- (IBAction)updateBTN:(id)sender {
    _gender = _gender == _genderList[0] ? @"" : _gender;
    NSDictionary *jsonBodyDict = @{@"name": _name,
                                   @"password": [[self currentPWTF] text],
                                   @"newPassword": [[self PWTFnew] text],
                                   @"email": [[self emailTF] text],
                                   @"dob": _dob,
                                   @"gender": _gender,
                                   @"token":_token};
    NSData *params = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];
    [self apiCall:@"updateProfile" :params :@"PATCH"];
}

- (IBAction)logoutBTN:(id)sender {
    [self logout];
}

- (void)dateChange:(UIDatePicker *)datePicker {
    _dobTF.text = [_FD formatDateWithDate:datePicker.date];
    _dob = [_FD formatDateSQLWithDate:datePicker.date];
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

- (void)logout{
    NSDictionary *jsonBodyDict = @{@"name": _name, @"token":_token};
    NSData *params = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:kNilOptions error:nil];
    [self apiCall:@"logout" :params :@"DELETE"];
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
            if(!error) {
                if([endPoint isEqualToString:@"logout"]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[EndSession sharedInstance] logout];
                    });
                }else if([endPoint isEqualToString:@"profile"]){
                    
                    
                    NSArray<NSDictionary *> *result = (NSArray<NSDictionary *> *)jsonResult[@"result"];
                    NSDictionary *result0 = result[0];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[self emailTF] setText:[result0 objectForKey:@"email"]];

                        self.dob = [[result0 objectForKey:@"DOB"] isKindOfClass:[NSString class]] ? [self.FD formatDateWithDate:[self.FD dateFromISOStringWithDateString:[result0 objectForKey:@"DOB"]]] : @"";
                    
                        [self.dobTF setText:self.dob];

                        self.datePicker.date = self.dob ? [self.FD dateForPVWithDate:[self.FD formatDateWithDate:[self.FD dateFromISOStringWithDateString:self.dob]]] : [NSDate date];
                        
                        self.gender = [[result0 objectForKey:@"gender"] isKindOfClass:[NSString class]] ? [result0 objectForKey:@"gender"] : self.genderList[0];
                        
                        [self.genderPV selectRow:[self.genderList indexOfObject:self.gender] inComponent:0 animated:YES];
                    
                    });
                    
                }else if([endPoint isEqualToString:@"updateProfile"]){
                    bool check = [[jsonResult objectForKey:@"check"] boolValue];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self alertShowUp:check ? @"Successfully" : @"Error" :[jsonResult objectForKey:@"result"]];
                        [[self currentPWTF] setText:@""];
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
