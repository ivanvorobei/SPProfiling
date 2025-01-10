import Foundation
import UIKit

public struct FirebaseProfileDeviceModel: Equatable, Codable {
    
    var id: String
    var status: FirebaseProfileDeviceStatus
    var name: String
    var deviceType: FirebaseProfileDeviceType?
    var systemName: String
    var systemVersion: String
    
    public static var current: FirebaseProfileDeviceModel? {
        
        let device = UIDevice.current
        guard let id = device.identifierForVendor?.uuidString else { return nil }
        
        return FirebaseProfileDeviceModel(
            id: id,
            status: .active,
            name: device.name,
            deviceType: .get(by: device.userInterfaceIdiom),
            systemName: device.systemName,
            systemVersion: device.systemVersion
        )
    }
    
    var firebaseDictionary: [String: Any]? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }
    
    static func convertToModels(_ dictionary: [String: Any]) -> [FirebaseProfileDeviceModel]? {
        do {
            var processData: [Any] = []
            for (id, raw) in dictionary {
                processData.append(raw)
            }
            let data = try JSONSerialization.data(withJSONObject: processData, options: [])
            let devices = try JSONDecoder().decode([FirebaseProfileDeviceModel].self, from: data)
            return devices
        } catch {
            return nil
        }
    }
    
    static func convertToModel(_ dictionary: [String: Any]) -> FirebaseProfileDeviceModel? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let decoder = JSONDecoder()
            let model = try decoder.decode(FirebaseProfileDeviceModel.self, from: data)
            return model
        } catch {
            return nil
        }
    }
}
