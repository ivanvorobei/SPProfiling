import Foundation
import UIKit

public struct FirebaseProfileDeviceModel: Equatable, Codable, Identifiable {
    
    public var id: String
    public var status: FirebaseProfileDeviceStatus
    public var name: String
    public var deviceType: FirebaseProfileDeviceType?
    public var systemName: String
    public var systemVersion: String
    
    public var lastActiveDate: Date
    public var addedDate: Date
    
    public static var current: FirebaseProfileDeviceModel? {
        
        let device = UIDevice.current
        guard let id = device.identifierForVendor?.uuidString else { return nil }
        let firstRegistrationDate = getFirstRegistrationDate()
        
        return FirebaseProfileDeviceModel(
            id: id,
            status: .active,
            name: device.name,
            deviceType: .get(by: device.userInterfaceIdiom),
            systemName: device.systemName,
            systemVersion: device.systemVersion,
            lastActiveDate: Date().start(of: .day),
            addedDate: firstRegistrationDate
        )
    }
    
    var firebaseDictionary: [String: Any]? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
    }
    
    private static func getFirstRegistrationDate() -> Date {
        let key = "firebaseprofile_device_first_registration"
        let savedDate = UserDefaults.standard.date(forKey: key)
        if let savedDate {
            return savedDate
        } else {
            let now = Date().start(of: .day)
            UserDefaults.standard.setValue(now, forKey: key)
            return now
        }
    }
    
    
    
    /*
    static func convertToModels(_ dictionary: [[String: Any]]) -> [FirebaseProfileDeviceModel]? {
        /*do {
         print(dictionary)
         var processData: [Any] = []
         for (id, raw) in dictionary {
         processData.append(raw)
         }
         let data = try JSONSerialization.data(withJSONObject: processData, options: [])
         let devices = try JSONDecoder().decode([FirebaseProfileDeviceModel].self, from: data)
         return devices
         } catch {
         return nil
         }*/
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode([FirebaseProfileDeviceModel].self, from: jsonData)
        }
        catch {
            return nil
        }
    }
    
    /*static func convertToModel(_ dictionary: [String: Any]) -> FirebaseProfileDeviceModel? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let decoder = JSONDecoder()
            let model = try decoder.decode(FirebaseProfileDeviceModel.self, from: data)
            return model
        } catch {
            return nil
        }
    }*/
    
    static func convertToModel(_ data: [String: Any]) -> FirebaseProfileDeviceModel? {
        // JSONSerialization с опцией fragmentsAllowed позволит работать с верхнеуровневым не-объектом JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed)
            
            // Настраиваем DateDecodingStrategy, чтобы декодер знал, как преобразовать строку в Date
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // Декодируем данные в модель
            return try decoder.decode(FirebaseProfileDeviceModel.self, from: jsonData)
        } catch {
            return nil
        }
    }*/
}
