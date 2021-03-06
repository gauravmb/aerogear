SharedShoot
===========
Playing well with Shoot'nShare app, SharedShoot allows you to see all the pictures shared via [Keycloak backend](https://github.com/aerogear/aerogear-backend-cookbook/tree/master/Shoot) and download photos from your friends.
You login using OpenID Connect.

Supported platforms: iOS7, iOS8, iOS9.

**NOTES:** On iOS8, this demo securely stores OAuth2 tokens in your iOS keychain, we chosen to use ```WhenPasscodeSet``` policy as a result to run this app you need to have **your passcode set**.
For iOS7, the ```WhenUnlockedThisDeviceOnly``` is choosen, no need of passcode to be set.
For more details see [WhenPasscodeSet blog post](http://corinnekrych.blogspot.fr/2014/09/new-kids-on-block-whenpasswordset.html) and [Keychain and WhenPasscodeSet blog post](http://corinnekrych.blogspot.fr/2014/09/touchid-and-keychain-ios8-best-friends.html)

### Run it in Xcode

The project uses [cocoapods](http://cocoapods.org) for handling its dependencies. As a pre-requisite, install [cocoapods](http://blog.cocoapods.org/) and then install the pod. On the root directory of the project run:

```bash
pod install
```
and then double click on the generated .xcworkspace to open in Xcode.