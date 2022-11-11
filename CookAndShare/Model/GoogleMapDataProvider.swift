//
//  GoogleMapDataProvider.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import UIKit

class GoogleMapDataProvider {
    static var shared = GoogleMapDataProvider()

    func fetchNearbySearch(location: String, keyword: String, completion: @escaping (ListResponse?) -> Void) {
        if let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location)&radius=3000&key=\(APIKey.apiKey)&keyword=\(keyword)&language=zh-TW".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    error == nil {
                    DispatchQueue.main.async {
                        do {
                            let response = try JSONDecoder().decode(ListResponse.self, from: data)
                            completion(response)
                        } catch {
                            completion(nil)
                        }
                    }
                } else {
                    print("錯誤：\(String(describing: error))")
                }
            }
            .resume()
        } else {
            print("URL失敗")
        }
    }

    func fetchPlaceDetail(placeId: String, completion: @escaping (DetailResponse?) -> Void) {
        if let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&language=zh-TW&key=\(APIKey.apiKey)") {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if  let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    error == nil {
                    DispatchQueue.main.async {
                        do {
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .secondsSince1970 // 時間
                            completion(try decoder.decode(DetailResponse.self, from: data))
                        } catch {
                            print(error)
                            completion(nil)
                        }
                    }
                } else {
                    print(error)
                }
            }
            .resume()
        }
    }

    func getPhoto(url: String, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if  let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200,
                    error == nil {
                    DispatchQueue.main.async {
                        completion(UIImage(data: data))
                    }
                } else {
                    print(error)
                }
            }
            .resume()
        }
    }
}
