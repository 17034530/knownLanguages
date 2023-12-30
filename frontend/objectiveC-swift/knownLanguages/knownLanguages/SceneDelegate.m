//
//  SceneDelegate.m
//  knownLanguages
//
//  Created by Tan Junhe on 23/12/23.
//

#import "SceneDelegate.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    if (!windowScene) {
        return;
    }

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // If the user is logged in before
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"token"] != nil) {
        // Instantiate the main tab bar controller and set it as the root view controller
        // using the storyboard identifier we set earlier
        UIViewController *mainTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBar"];
        self.window.rootViewController = mainTabBarController;
    } else {
        // If the user isn't logged in
        // Instantiate the navigation controller and set it as the root view controller
        // using the storyboard identifier we set earlier
//        UINavigationController *loginNavController = [storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
//        self.window.rootViewController = loginNavController;

    }

}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}

- (void)changeRootViewController:(UIViewController *)vc{
    if (!self.window) {
        return;
    }
    
    // Change the root view controller to your specific view controller
    self.window.rootViewController = vc;
}



@end
