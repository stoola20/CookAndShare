//
//  Map.swift
//  CookAndShare
//
//  Created by Hsun Chen on 2022/11/3.
//

import Foundation

struct ListResponse: Codable {
    var results: [PlaceResult]
    var status: String
}

struct PlaceResult: Codable {
    var name: String
    var placeId: String
    var address: String
    let geometry: Geometry

    enum CodingKeys: String, CodingKey {
        case name
        case placeId = "place_id"
        case address = "vicinity"
        case geometry
    }
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat, lng: Double
}

struct DetailResponse: Codable {
    var result: InfoResult
}

struct InfoResult: Codable {
    var name: String
    var photos: [Photo]
    var reviews: [Review]
}

struct Photo: Codable {
    let height: Int
    let htmlAttributions: [String]
    let photoReference: String
    let width: Int

    enum CodingKeys: String, CodingKey {
        case height
        case htmlAttributions = "html_attributions"
        case photoReference = "photo_reference"
        case width
    }
}

struct Review: Codable {
    var authorName: String
    var profilePhotoURL: String
    var relativeTimeDescription: String
    var text: String
    var time: Date

    enum CodingKeys: String, CodingKey {
        case authorName = "author_name"
        case profilePhotoURL = "profile_photo_url"
        case relativeTimeDescription = "relative_time_description"
        case text, time
    }
}
