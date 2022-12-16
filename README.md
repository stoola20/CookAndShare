# CookAndShare
<p align="center">
    <img src="https://user-images.githubusercontent.com/103205827/208052192-a886e470-dfef-4416-a2be-75e61bc58df9.png">
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platform-iOS-blue">
    <img src="https://img.shields.io/badge/release-v1.2.1-green">
</p>

<p align="center">
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
![1](https://user-images.githubusercontent.com/103205827/207550333-0bfdc8de-0010-4a89-9dc8-48e4c7fd0b13.png)
![2](https://user-images.githubusercontent.com/103205827/207550347-e6126940-682a-4dbd-9365-dba42477e518.png)
![3](https://user-images.githubusercontent.com/103205827/207550353-f9e4fbc2-61a6-41af-b0c7-39fc3c4ccf65.png)
![4](https://user-images.githubusercontent.com/103205827/207550356-fad0d338-3ad9-4f2e-afe5-95220ff27b92.png)

![5](https://user-images.githubusercontent.com/103205827/207550358-da50802c-4ce9-4062-bfa7-12325c47e1c2.png)
![6](https://user-images.githubusercontent.com/103205827/207550363-d7ec3b8e-c738-47e8-8d59-1347244f7c2b.png)
![7](https://user-images.githubusercontent.com/103205827/207550367-59bbebaa-3041-4fde-9cc3-0cd81ed73bcf.png)

![8](https://user-images.githubusercontent.com/103205827/207550371-936dc436-4941-437b-a481-8e0f9bf78edd.png)
![9](https://user-images.githubusercontent.com/103205827/207550377-c84148e8-fb42-41ac-81a9-f42d828256cc.png)
![10](https://user-images.githubusercontent.com/103205827/207550384-bf15bb4d-17e3-44a2-8fed-e3a421d53cd3.png)

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
1.2.1    |2022/12/13 | Optimized recipe classification and fixed block list bug.
1.2.0    |2022/12/04 | Added new features, optimized recipe UI, and fixed image flashing bugs.
1.1.1    |2022/12/02 | First released on App Store.

## Requirements
> Xcode 12 or later

> iOS 14.0 or later

> Swift 5 or later

## Contact
Ying Hsun Chen | <cookandsharec@gmail.com>

## License
CookAndShare is released under the MIT license. See [LICENSE](https://github.com/stoola20/CookAndShare/blob/main/LISENCE) for details.
