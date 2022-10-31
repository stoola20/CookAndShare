//
//  Constant.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/10/28.
//

import Foundation

struct Constant {
    // firestore
    static let firestoreRecipes = "recipes"
    
    // storyboard
    static let newpost = "NewPost"
    static let recipe = "Recipe"
    static let share = "Share"
    
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
    
    // recipe
    static let addToShoppingList = "加入購買清單"
    static let quantityByPerson = "人份的食材"
    
    // search
    static let title = "title"
    static let ingredientNames = "ingredientNames"
    static let typeInTitle = "請輸入食譜名"
    static let typeInIngredient = "請輸入食材名"
    static let searchByText = "文字搜尋"
    static let searchByPhoto = """
        不知道食材的名稱？
        沒關係，讓我們幫你辨識！
    """
    static let searchRandomly = """
        還是沒有想法嗎？
        試著搖晃一下手機吧！
    """
    static let searchResult = "搜尋結果"
}
