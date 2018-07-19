//
//  VenueDataModel.swift
//  MenaTest
//
//  Created by Mena on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import Foundation
import FoursquareAPIClient
import CoreStore

class VenueDataModel {
    static let shared = VenueDataModel()
    
    private let apiClient: FoursquareAPIClient!
    
    private init() {
        apiClient = FoursquareAPIClient(clientId: "15O53CIH21HCYWPWGL30SDDREH0YFUQIZUFNN0LU0BJIYDV1", clientSecret: "I3FJNJDYPTWEH1BP3XUW5OFTSUUS3IAADNB5IUSTBTLBLYPN")
    }
    
    func loadVenues(_ latitude: Double, _ longitude: Double, _ completionHandler: (( _ error: Error?) -> ())?) {
        let parameter = [
            "ll": "\(latitude),\(longitude)",
            "categoryId": "4bf58dd8d48988d1ca941735",
            "limit": "5"
        ]
        apiClient.request(path: "venues/search", parameter: parameter) { result in
            switch result {
            case let .success(data):
                let decoder: JSONDecoder = JSONDecoder()
                do {
                    let response = try decoder.decode(Response<SearchResponse>.self, from: data)
                    let venues = response.response.venues
                    CoreStore.perform(asynchronous: { (transaction) -> Void in
                        transaction.deleteAll(From<VenueItem>())
                    }, completion: { (result) in
                        CoreStore.perform(asynchronous: { (transaction) -> Void in
                            for venue in venues {
                                let venueItem = transaction.create(Into<VenueItem>())
                                venueItem.venueName = venue.name
                                if let category = venue.categories?.first {
                                    venueItem.categoryId = category.categoryId
                                    venueItem.categoryName = category.name
                                    venueItem.categoryIconUrl = category.icon.categoryIconUrl
                                }
                            }
                        }, completion: { (result) in
                            completionHandler?(nil)
                        })
                    })
                } catch {
                    completionHandler?(error)
                }
            case let .failure(error):
                completionHandler?(error)
            }
        }
    }
}

struct Location: Codable {
    let address: String?
    let latitude: Double
    let longitude: Double
    
    private enum CodingKeys: String, CodingKey {
        case address
        case latitude = "lat"
        case longitude = "lng"
    }
}

struct VenueCategory: Codable {
    let categoryId: String
    let name: String
    let icon: VenueCategoryIcon
    
    private enum CodingKeys: String, CodingKey {
        case categoryId = "id"
        case name
        case icon
    }
}

struct VenueCategoryIcon: Codable {
    let prefix: String
    let suffix: String
    
    var categoryIconUrl: String {
        return String(format: "%@%d%@", prefix, 88, suffix)
    }
}

struct Venue: Codable {
    let venueId: String
    let name: String
    let location: Location
    let categories: [VenueCategory]?
    
    private enum CodingKeys: String, CodingKey {
        case venueId = "id"
        case name
        case location
        case categories
    }
}

struct Response <Response: Codable> : Codable {
    let response: Response
}

struct SearchResponse : Codable {
    let venues: [Venue]
}
