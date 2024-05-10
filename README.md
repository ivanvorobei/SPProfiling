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

# Using


