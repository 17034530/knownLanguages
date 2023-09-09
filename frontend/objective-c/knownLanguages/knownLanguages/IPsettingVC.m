//
//  IPsettingVC.m
//  knownLanguages
//
//  Created by Tan Junhe on 3/9/23.
//

#import "IPsettingVC.h"
#import "DataController.h"
#import "SceneDelegate.h"

@interface IPsettingVC ()
@property (weak, nonatomic) IBOutlet UITextField *ipAddressTF;
@property (weak, nonatomic) IBOutlet UITextField *portTF;

@property IPSetting *ipsetting;
@end

@implementation IPsettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
    _ipsetting = [IPSetting sharedInstance];
}
- (IBAction)updateIPBTN:(id)sender {
    if(_ipAddressTF.text.length != 0 && _portTF.text.length != 0){
        _ipsetting.IPAddress = _ipAddressTF.text;
        _ipsetting.Port = _portTF.text;
        [self alertShowUp:@"Updated" : [NSString stringWithFormat:@"Your new IP address is %@ and port is %@",_ipsetting.IPAddress,_ipsetting.Port]];
    }else{
        [self alertShowUp:@"Error" :@"Ip address or Port cannot be empty"];
    }
}

- (void)alertShowUp: (NSString*)title : (NSString*)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if([title isEqualToString:@"Updated"]){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
                SceneDelegate *sceneDelegate = (SceneDelegate *)[[[UIApplication sharedApplication] connectedScenes].allObjects.firstObject delegate];
                [sceneDelegate changeRootViewController:loginVC];
            }
        }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
