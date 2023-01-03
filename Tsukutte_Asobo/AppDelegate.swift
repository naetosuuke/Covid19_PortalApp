//
//  AppDelegate.swift
//  Tsukutte_Asobo
//
//  Created by Daisuke Doi on 2022/12/21.
//

import UIKit
import Firebase //Firebaseのライブラリを読み込み
import FirebaseFirestore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        CovidAPI.getPrefecture(completion: {(result: [CovidInfo.Prefecture]) -> Void in //ライフサイクル 最初の画面を起動し終わったタイミングで県別APIデータを入手し、シングルトンにデータを代入している。
            CovidSingleton.shared.prefecture = result
        })
        FirebaseApp.configure() // configureを読み込み
        /*FireStoreへの接続確認用スクリプト
         
        Firestore.firestore().collection("users").document("Message").setData([
            "UserMessage": "message",
            "Date": "messageDate",
            "UserId": "messageId"
        ], merge: false) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Documents successfully written!")
            }
        }
         */
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

