import Foundation
import UIKit

public enum FirebaseProfileDeviceType: String, CaseIterable, Codable {
    
    case iphone
    case ipad
    case tv
    case mac
    case vision
    
    static func get(by idiom: UIUserInterfaceIdiom) -> FirebaseProfileDeviceType? {
        switch idiom {
        case .unspecified:
            return nil
        case .phone:
            return .iphone
        case .pad:
            return .ipad
        case .tv:
            return .tv
        case .carPlay:
            return nil
        case .mac:
            return .mac
        case .vision:
            return .vision
        @unknown default:
            return nil
        }
    }
}
