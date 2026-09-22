# GEN-00498 — Add Branch.io SDK to Gradle and CocoaPods
Metric: Dependency Resolution Pass · Pass/Fail

## Android — android/app/build.gradle
```gradle
dependencies {
    implementation 'io.branch.sdk.android:library:5.+'
}
```

## iOS — ios/Podfile
```ruby
pod 'BranchSDK'
```
Then run `cd ios && pod install`.
