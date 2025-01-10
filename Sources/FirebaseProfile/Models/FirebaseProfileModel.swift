import Foundation
import FirewrapAuth

public struct FirebaseProfileModel: Equatable {
    
    public var id: String
    public var email: String
    public var name: String?
    
    init(id: String, email: String, name: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
    }
    
    func match(id: String, email: String, name: String?) -> Bool {
        return id == self.id && email == self.email && name == self.name
    }
}
