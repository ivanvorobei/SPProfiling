import Foundation
import FirebaseWrapperAuth

public struct FirebaseProfileModel {
    
    var id: String
    var email: String
    var name: String?
    
    var providers: [FirebaseAuthProvider]
    
    init(id: String, email: String, name: String? = nil, providers: [FirebaseAuthProvider]) {
        self.id = id
        self.email = email
        self.name = name
        self.providers = providers
    }
}
