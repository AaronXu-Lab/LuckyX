//
//  AppDelegate.swift
//  LuckyX
//
//  Created by 徐炜楠 on 2018/11/18.
//  Copyright © 2018 徐炜楠. All rights reserved.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try SampleParticipants.installIfNeeded(in: Realm(), defaults: .standard)
        } catch {
            NSLog("无法初始化示例名单：%@", error.localizedDescription)
        }
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        return true
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


}


// The storyboard supplies the window and root controller for this scene.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
}

/// Fictional participants for trying every lottery mode on a fresh installation.
enum SampleParticipants {
    static let installationKey = "SampleParticipantsInstalledV1"

    static func installIfNeeded(in realm: Realm, defaults: UserDefaults) throws {
        guard !defaults.bool(forKey: installationKey) else { return }
        guard realm.objects(Person.self).isEmpty,
              realm.objects(Prize.self).isEmpty,
              defaults.string(forKey: "UserDefaultEditPerson") == nil else {
            defaults.set(true, forKey: installationKey)
            return
        }
        let colors = ["红", "绿", "黄", "蓝", "紫", "粉"]
        let wishes = ["想要一副耳机", "想要一个行李箱", "想去旅行", "想要机械键盘", "想要运动手表"]
        var people: [Person] = []
        var lines: [String] = []
        for (colorIndex, color) in colors.enumerated() {
            for index in 1...30 {
                let person = Person()
                person.name = "测试\(color)队\(String(format: "%02d", index))"
                let serial = colorIndex * 30 + index
                // Exercise numeric, S-prefixed, and IN-prefixed employee numbers.
                let prefix = ["8", "S", "IN"][(index - 1) % 3]
                let displayedNumber = prefix + String(format: "%04d", serial)
                person.number = Int(displayedNumber.replacingOccurrences(of: "S", with: "7").replacingOccurrences(of: "IN", with: "6"))!
                person.color = color
                person.wish = index % 6 == 0 ? "未填写心愿" : wishes[(index - 1) % wishes.count]
                people.append(person)
                lines.append("\(person.name) \(color) \(displayedNumber) \(person.wish)")
            }
        }
        try realm.write { realm.add(people) }
        defaults.set(lines.joined(separator: "\n"), forKey: "UserDefaultEditPerson")
        defaults.set(true, forKey: installationKey)
    }
}
