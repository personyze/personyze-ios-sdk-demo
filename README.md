# personyze-ios-sdk-demo

Demo app for the [Personyze iOS SDK](https://github.com/personyze/personyze-ios-sdk) 2.0: send events and page
views, see what Personyze decided, open an action and watch it report what the visitor does.

The demo of the 1.x SDK is on the `v1` branch.

## Run it

Xcode 26 or later. Open `Personyze SDK Demo.xcodeproj`; Xcode fetches the SDK, a Swift package, by itself. Run on
a simulator or a device (iOS 15 or later), and:

1. Enter the account's API key (Settings > Integrations > Full-featured API in the Personyze panel).
2. Queue some events - a profile field, a product viewed or bought, an article read - and press "Proceed
   navigation" to send them with a page view, or "Only events" to send them alone.
3. The campaigns the visitor matches and the actions Personyze decided appear below. Tap an action: an HTML one
   renders in the SDK's view, which reports it shown and reports taps on it (the line above it says what was
   tapped); a JSON one shows as text.

The visit shows in the panel's Live visits, as from an iOS device.

## What it shows of the SDK

| | |
| --- | --- |
| `AppDelegate.swift` | `Personyze.initialize` as the app starts, and a notification delegate passing taps on to `Personyze.handleNotificationResponse` |
| `DemoViewController.swift` | Events, `Personyze.navigate` with its events closure, `Personyze.refresh`, `Personyze.results` |
| `ActionViewController.swift` | `PersonyzeActionView` |
| `Info.plist` | The background refresh the SDK uses when the app declares it (`com.personyze.sdk.refresh`, `fetch`) |

Until SDK 2.0.0 is released, the project follows the SDK's `v2-wip` branch: Xcode's File > Packages > Update to
Latest Package Versions picks up its latest.

See also:

- [Personyze Android SDK](https://github.com/personyze/personyzeandroidsdk)
- [Personyze Android SDK Demo app](https://github.com/personyze/personyzeandroidsdk-demo)
- [Personyze iOS SDK](https://github.com/personyze/personyze-ios-sdk)
