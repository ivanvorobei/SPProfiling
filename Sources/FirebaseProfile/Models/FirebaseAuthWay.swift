import UIKit

public enum FirebaseAuthWay {
    
    case apple(_ controller: UIViewController)
    case google(_ controller: UIViewController)
    case email(_ email: String, handleURL: URL)
}
