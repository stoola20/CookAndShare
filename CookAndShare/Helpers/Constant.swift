//
//  Constant.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation
import FirebaseAuth

enum Constant {
    // CoreData
    static let modelName = "CookAndShare"
    static let entityName = "ShoppingList"

    // firestore
    static let firestoreRecipes = "recipes"
    static let firestoreUsers = "users"
    static let firestoreShares = "shares"
    static let firestoreConversations = "conversations"
    static let authorId = "authorId"

    // storyboard
    static let newpost = "NewPost"
    static let recipe = "Recipe"
    static let share = "Share"
    static let profile = "Profile"
    static let map = "Map"

    // new post
    static let newRecipe = "分享食譜"
    static let newShare = "分享食品/食材"
    static let draft = "草稿"

    static let recipeName = "食譜名稱"
    static let description = "描述"
    static let duration = "烹飪時間(分鐘)"
    static let quantity = "份量(人份)"
    static let ingredient = "食材"
    static let procedure = "步驟"

    static let recipeNameExample = "例：日式咖哩飯"
    static let descriptionExample = "請寫下這道料理的介紹或故事"
    static let ingredientName = "食材名稱"
    static let ingredientQuantity = "份量"
    static let procedureStep1 = "將洋蔥及紅蘿蔔拌炒至熟透"
    static let procedureStep2 = "加入雞腿肉翻炒"
    static let procedureStep3 = "加水煮滾"

    // share
    static let shareTitle = "例：蔬菜湯罐頭"
    static let shareDesription = "例：兩罐，購入自家樂福"
    static let meetTime = "例：今天晚上 7 - 9 點"
    static let meetPlace = "例：台北車站"

    // recipe
    static let addToShoppingList = "加入購買清單"
    static let quantityByPerson = "人份的食材"
    static let likes = "likes"
    static let saves = "saves"
    static let reports = "reports"
    static let foodRecognition = "食物辨識"

    // search
    static let title = "title"
    static let ingredientNames = "ingredientNames"
    static let search = "搜尋"
    static let typeInTitle = "請輸入食譜名"
    static let typeInIngredient = "請輸入食材名"
    static let searchByText = "文字搜尋"
    static let searchByPhoto = """
        不知道餐點的名稱？
        沒關係，讓我們幫你辨識！
    """
    static let searchRandomly = """
        還是沒有想法嗎？
        試著搖晃一下手機吧！
    """
    static let searchResult = "搜尋結果"
    static let notFound = "找不到食譜嗎？"
    static let beTheFirstOne = "成為第一個分享食譜的人吧！"
    static let addNewRecipe = "新增食譜"

    // shopping list
    static let pleaseFillIn = "請輸入食材名稱及份量"
    static let cancel = "取消"
    static let confirm = "確認"

    // user
    static let name = "name"
    static let imageURL = "imageURL"
    static let fcmToken = "fcmToken"
    static let recipesId = "recipesId"
    static let savedRecipesId = "savedRecipesId"
    static let sharesId = "sharesId"
    static let blockList = "blockList"
    static let conversationId = "conversationId"

    // conversation
    static let text = "text"
    static let image = "image"
    static let voice = "voice"
    static let location = "location"

    static let breakfast = "breakfast"
    static let chefMan = "chefMan"
    static let friedRice = "friedRice"

    // user
    // V4hMTRjOK5jOFfdB15KU 勳
    // cCV8vxF2v9DlUyfgfRwg 測試帳號
    static func getUserId() -> String {
        guard let userId = Auth.auth().currentUser?.uid else {
            return ""
        }
        return userId
    }
}
