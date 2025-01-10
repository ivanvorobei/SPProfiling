#if canImport(SwiftUI)
import SwiftUI

public class FirebaseProfileProvider: ObservableObject {
    
    @Published fileprivate(set) public var devices: [FirebaseProfileDeviceModel] = []
    
    public init() {
        FirebaseProfile.enableObserveDevicesList()
        
        NotificationCenter.default.addObserver(.firebaseProfileDidUpdatedDevices) { [ weak self] _ in
            guard let self else { return }
            devices = FirebaseProfile.devices ?? []
        }
    }
}
#endif
