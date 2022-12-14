# CookAndShare
<p align="left">
    <img src="https://img.shields.io/badge/platform-iOS-blue">
    <img src="https://img.shields.io/badge/release-v1.2.1-green">
</p>

<p align="left">
    <a href="https://itunes.apple.com/app/id6444237378">
    <img src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"></a>
</p>

## About
A smart cooking App with recipe recording, food recognition, and food-sharing features. You can reduce food waste, improve your cooking skills, and connect with people.

## Features
### Search Recipe
- Browse popular recipes or different types of recipes to view the recipe details, ingredient list, and cooking steps.
- Provide four ways for recipe searching, including recipe name, ingredient name, food recognition, and random recommendation.

### Food Sharing
- Share food with others or request food for free.

### Instant Messaging
- If there is a food need, you can contact users through the communication function
- You can also discuss cooking tips with each other.

### Map Search
- View nearby supermarkets, markets, and food banks and navigate directly to the destination.

### Shopping List
- Add the necessary ingredients to the shopping list and no longer forget to buy ingredients when you go shopping.

## Screenshots
![1](https://user-images.githubusercontent.com/103205827/207544432-7d98cae8-f0e3-4339-ac22-3873082600e9.png)
![2](https://user-images.githubusercontent.com/103205827/207544448-0b498e89-4b51-472b-b3f2-a530a0eec510.png)
![3](https://user-images.githubusercontent.com/103205827/207544465-ebd51a5f-5fb4-43f9-93b9-0d4ffcb5dc66.png)
![4](https://user-images.githubusercontent.com/103205827/207544506-c14c5008-a183-47c1-a43a-8f6eb4aadfdf.png)

![5](https://user-images.githubusercontent.com/103205827/207544538-e81e4a37-808d-43e5-91ed-7af976ce72b3.png)
![6](https://user-images.githubusercontent.com/103205827/207544551-c1b0fa59-8ed1-4495-aa11-e577f41d893c.png)
![7](https://user-images.githubusercontent.com/103205827/207544561-cab9f294-442a-4706-b01d-b52c201759fc.png)

![8](https://user-images.githubusercontent.com/103205827/207544572-5cedc8ff-e7ca-4d44-af79-eae93d2dd84a.png)
![9](https://user-images.githubusercontent.com/103205827/207544580-57b1dfdb-755c-4e64-a20d-0235654edec3.png)
![10](https://user-images.githubusercontent.com/103205827/207544592-d69b578f-f576-4934-8455-24d2a84fe10b.png)

## Techniques
- Provided multiple functions for recipe searching, including food recognition and random suggestions through **Shake Gesture**.
- Applied **Core ML model** to build a real-time **food recognition** App, and translated the results from English into Mandarin via Google Translation API.
- Implemented instant messaging, including sending text, images, location, and voice with **Firebase Cloud Messaging** and **Push Notification**.
- Enabled recording and playing voice messages by using **AVFoundation**.
- Searched markets and food banks with **Google Map API** and **Google Place API**.
- Simplified duplicate code by using protocol-oriented programming.
- Applied Swift **Generics** and **Result type** to enhance readability and maintainability.
- Stored shopping list items with **Core Data** for persistent storage.
- Integrated data storage with **Firestore Database** and **Firebase Cloud Storage**.
- Organized user system with **Firebase Authentication**.

## Libraries
- GoogleMaps
- GooglePlaces
- [Firebase](https://github.com/firebase/firebase-ios-sdk)
- [Lottie](https://github.com/airbnb/lottie-ios)
- [SPAlert](https://github.com/ivanvorobei/SPAlert)
- [Hero](https://github.com/HeroTransitions/Hero)
- [ESPullToRefresh](https://github.com/eggswift/pull-to-refresh)
- [IQKeyboardManager](https://github.com/hackiftekhar/IQKeyboardManager)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [Alamofire](https://github.com/Alamofire/Alamofire)
- [KeychainSwift](https://github.com/evgenyneu/keychain-swift)
- [SwiftJWT](https://cocoapods.org/pods/SwiftJWT)
- [SwiftLint](https://github.com/realm/SwiftLint)

## Version
> 1.2.1

## Release Notes
Version  | Date      | Note
:-------:|-----------|--------------------------------
1.1.1    |2022/12/02 | First released on App Store.
1.2.0    |2022/12/04 | Added new features, optimized recipe UI, and fixed image flashing bugs.
1.2.1    |2022/12/13 | Optimized recipe classification and fixed block list bug.

## Requirements
> Xcode 13 or later

> iOS 14.0 or later

> Swift 5 or later

## Contact
Ying Hsun Chen | <cookandsharec@gmail.com>

## License
CookAndShare is released under the MIT license. See [LICENSE](https://github.com/stoola20/CookAndShare/blob/main/LISENCE) for details.

Hsun 2022.10
