import Foundation
import FirewrapAuth

public struct FirebaseProfileModel {
    
    var id: String
    var email: String
    var name: String?
    
    init(id: String, email: String, name: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
    }
}
