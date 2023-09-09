//
//  DataController.h
//  knownLanguages
//
//  Created by Tan Junhe on 27/8/23.
//

#import <Foundation/Foundation.h>

@interface IPSetting : NSObject

@property NSString *IPAddress;
@property NSString *Port;

+ (instancetype)sharedInstance;
- (NSString*) setUrl;

@end


@interface EndSession : NSObject

+ (instancetype)sharedInstance;
- (void)logout;
@end


@interface UserGender : NSObject

@property(readwrite, strong) NSArray *gender;

+ (instancetype)sharedInstance;

@end


@interface FormatDate : NSObject

- (NSString *)formatDate: (NSDate *)date;
- (NSString *)formatDateSQL: (NSDate *)date;
- (NSDate *)dateFromISOString: (NSString *)dateString;
- (NSDate *)dateForPV: (NSString *)dateString;

@end
