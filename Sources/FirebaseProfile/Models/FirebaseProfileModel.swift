import Foundation
import FirewrapAuth

public struct FirebaseProfileModel {
    
    var id: String
    var email: String
    var name: String?
    
    var providers: [FirewrapAuthProvider]
    
    init(id: String, email: String, name: String? = nil, providers: [FirewrapAuthProvider]) {
        self.id = id
        self.email = email
        self.name = name
        self.providers = providers
    }
}
