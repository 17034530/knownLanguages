//
//  SceneDelegate.h
//  knownLanguages
//
//  Created by Tan Junhe on 23/12/23.
//

#import <UIKit/UIKit.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow * window;

- (void)changeRootViewController:(UIViewController *)vc;

@end

