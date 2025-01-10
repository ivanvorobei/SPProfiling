import Foundation
import SwiftBoost
import FirewrapAuth
import FirewrapDatabase

extension FirebaseProfile {
    
    static func printConsole(_ text: String) {
        debug("FirebaseProfile: " + text)
    }
    
    static func formattedJSON(_ json: [String : Any]?) -> String {
        return json?.debugDescription ?? "nil"
        /*do {
            guard let json else { return "> Empty JSON" }
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString ?? "empty"
        } catch {
            print("Invalid json format, but printed any way: \(json)")
            return "empty"
        }*/
    }
    
    // MARK: Firestore Documents & Collections
    
    enum FirewrapModels {
        
        static func makeFirewrapProfileDocument() -> FirewrapDocument? {
            guard let currentProfile = FirebaseProfile.profile else { return nil }
            return FirewrapDocument("/users/" + currentProfile.id)
        }
        
        static func makeFirewrapDevicesCollection() -> FirewrapCollection? {
            guard let profileDocument = makeFirewrapProfileDocument() else { return nil }
            return FirewrapCollection(profileDocument.path + "/devices")
        }
        
        static func makeFirewrapDeviceDocument() -> FirewrapDocument? {
            guard let devicesCollection = makeFirewrapDevicesCollection() else { return nil }
            guard let currentDeviceID = FirebaseProfileDeviceModel.current?.id else { return nil }
            return FirewrapDocument(devicesCollection.path + "/" + currentDeviceID)
        }
    }
}
