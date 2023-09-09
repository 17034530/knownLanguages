//
//  DataController.m
//  knownLanguages
//
//  Created by Tan Junhe on 27/8/23.
//

#import "DataController.h"
#import "SceneDelegate.h"

@implementation IPSetting

+ (instancetype)sharedInstance {
    static IPSetting *sharedInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[IPSetting alloc] init];
        });
        return sharedInstance;
}   

- (NSString *)setUrl {
    IPSetting *ipsetting = [IPSetting sharedInstance];
    
    if(ipsetting.IPAddress.length == 0 && ipsetting.IPAddress.length == 0){
        NSString *configFileDir = @"config/config";//change this to base unless config.plist is created
        NSString *configFileURL = [[NSBundle mainBundle] pathForResource:configFileDir ofType:@"plist"];
        NSData *configData = [[NSFileManager defaultManager] contentsAtPath:configFileURL];
        NSError *error;
        NSPropertyListFormat plistFormat;
        NSDictionary *config = [NSPropertyListSerialization propertyListWithData:configData options:NSPropertyListImmutable format:&plistFormat error:&error];
            
        ipsetting.IPAddress = [config valueForKey:@"ipaddress"];
        ipsetting.Port = [config valueForKey:@"port"];
    }
    return [NSString stringWithFormat:@"http://%@:%@/",ipsetting.IPAddress,ipsetting.Port];
}

@end

@implementation EndSession

+ (instancetype)sharedInstance {
    static EndSession *sharedInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[EndSession alloc] init];
        });
        return sharedInstance;
}

- (void)logout {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:bundleIdentifier];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
    SceneDelegate *sceneDelegate = (SceneDelegate *)[[[UIApplication sharedApplication] connectedScenes].allObjects.firstObject delegate];
    [sceneDelegate changeRootViewController:loginVC];

}

@end


@implementation UserGender

+ (instancetype)sharedInstance {
    static UserGender *sharedInstance = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[UserGender alloc] init];
            
        });
        return sharedInstance;
}

+ (void)initialize{
    [[UserGender sharedInstance] setGender:[[NSArray alloc] initWithObjects:@"Prefer not to say", @"Male", @"Female", @"Others", nil]];
}
@end


@implementation FormatDate

- (NSString *)formatDateSQL:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    return [formatter stringFromDate:date];
}

- (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyy"];
    return [formatter stringFromDate:date];
}

- (NSDate *)dateFromISOString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    return [formatter dateFromString:dateString] ?: [NSDate date];
}

- (NSDate *)dateForPV:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMMM yyyy"];
    return [formatter dateFromString:dateString] ?: [NSDate date];
}

@end
