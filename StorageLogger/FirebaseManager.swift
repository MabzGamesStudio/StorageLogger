import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    private init() {}
}


//import UIKit
//
//import FirebaseCore
//
//
//@UIApplicationMain
//
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//
//  var window: UIWindow?
//
//
//  func application(_ application: UIApplication,
//
//    didFinishLaunchingWithOptions launchOptions:
//
//      [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//
//    FirebaseApp.configure()
//
//    return true
//
//  }
//
//}
