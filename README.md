# FirebaseProfile

## Configure

In App Delegate add options, its getting values from your plist-file:

```swift
let filePath = Bundle.main.path(forResource: "GoogleService-Info.plist", ofType: .empty)!
let options = FirebaseOptions(contentsOfFile: filePath)!
FirebaseProfile.configure(with: options)     
```

If you use Sign in with Email, as well add to App Delegate handle URL:

```
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
   return FirebaseProfile.application(app, open: url, options: options)
}
```

# Auth

# Devices

After auth device list observing. When you first time sign in device saved to list user's devices. If you sign out from other device, its signout automatically when user open app next time.

> Since iOS 16 you can't get clean [device name](https://developer.apple.com/documentation/uikit/uidevice/1620015-name)

You will get just "iPhone" or same. For get it correctly, need [special entitliment](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_device-information_user-assigned-device-name) and pass review. When you get it, device name will upgrade automatically for new users and for old users after launch app.

