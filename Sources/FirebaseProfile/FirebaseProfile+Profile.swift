import Foundation
import FirewrapDatabase

extension FirebaseProfile {
    
    enum Profile {
        
        static func getProfileFromFirestore(completion: @escaping (FirebaseProfileModel?) -> Void) {
            guard let profile = FirebaseProfile.profile, let document = self.firewrapDocument else {
                completion(nil)
                return
            }
            document.get(.server) { data in
                if let data {
                    guard let email = data["email"] as? String else {
                        completion(nil)
                        return
                    }
                    completion(.init(
                        id: profile.id,
                        email: email,
                        name: data["name"] as? String)
                    )
                } else {
                    completion(nil)
                }
            }
        }
        
        static func saveProfileToFirestore() {
            guard let document = self.firewrapDocument else { return }
            guard let currentProfile = FirebaseProfile.profile else { return }
            
            document.set([
                "email" : currentProfile.email,
                "name" : currentProfile.name ?? FirewrapFieldNil()
            ], merge: true, completion: {})
        }
        
        static func startObserveChanges() {
            
        }
        
        static func endObserveChanges() {
            
        }
        
        static var firewrapDocument: FirewrapDocument? {
            guard let currentProfile = FirebaseProfile.profile else { return nil }
            return FirewrapDocument("/profiles/" + currentProfile.id)
        }
    }
}
