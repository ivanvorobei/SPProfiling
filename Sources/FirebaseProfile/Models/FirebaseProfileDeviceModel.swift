import Foundation
import UIKit

public struct FirebaseProfileDeviceModel {
    
    var id: String
    var name: String
    var deviceType: FirebaseProfileDeviceType?
    var systemName: String
    var systemVersion: String
    
    public static var current: FirebaseProfileDeviceModel? {
        let device = UIDevice.current
        guard let id = device.identifierForVendor?.uuidString else { return nil }
        return FirebaseProfileDeviceModel(
            id: id,
            name: device.name,
            deviceType: .get(by: device.userInterfaceIdiom),
            systemName: device.systemName,
            systemVersion: device.systemVersion
        )
    }
}

public enum FirebaseProfileDeviceType: String, CaseIterable {
    
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
