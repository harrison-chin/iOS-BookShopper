//
//  AppDelegate.swift
//  BookShopper
//
//  Created by Harrison Chin on 5/15/18.
//  Copyright © 2018 TaqTIk Health. All rights reserved.
//

import UIKit
import Braintree

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let urlScheme = "com.taqtik.lab.BookShopper"
    let webBaseURL = "https://lab.taqtik.com/api/"
//    let webBaseURL = "http://localhost:3000/api/"
    
    // user preferences
    var userFirstName:String = ""
    var userLastName:String = ""
    var userEmail:String = ""
    var userPhone:String = ""

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        BTAppSwitch.setReturnURLScheme(urlScheme)
        getUserProfile()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare(urlScheme) == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Faviorite Packages List
    func saveUserProfile() {
        var jsonString = ""
        jsonString += "{\n"
        jsonString += "\"firstName\": \"\(self.userFirstName)\",\n"
        jsonString += "\"lastName\": \"\(self.userLastName)\",\n"
        jsonString += "\"email\": \"\(self.userEmail)\",\n"
        jsonString += "\"phone\": \"\(self.userPhone)\""
        jsonString += "}"
        let defaults = UserDefaults.standard
        defaults.set(jsonString, forKey: "Key_UserProfile")
    }
    
    func getUserProfile() {
        let defaults = UserDefaults.standard
        if let jsonString = defaults.string(forKey: "Key_UserProfile") {
            if let jsonData = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                do {
                    let object = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
                    if let dictionary = object as? [String: Any] {
                        if let firstName = dictionary["firstName"] as? String {
                            self.userFirstName = firstName
                        }
                        if let lastName = dictionary["lastName"] as? String {
                            self.userLastName = lastName
                        }
                        if let email = dictionary["email"] as? String {
                            self.userEmail = email
                        }
                        if let phone = dictionary["phone"] as? String {
                            self.userPhone = phone
                        }
                    }
                }
                catch {
                    print("getUserProfile error")
                }
            }
        }
    }
}

