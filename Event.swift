//
//  Event.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 5/2/21.
//

import UIKit

class Event: NSObject {
    
    var titler: String!
    var urlImage: String!
    var urlImage2: String!
    var urlImage3: String?
    var descript: String?
    var uid: String!
    var name: String!
    var startDate: Date!
    var endDate: Date!
    var repeating: Bool!
    var dateStart: String?
    var key: String!
    var long: Double!
    var lat: Double!
    var postedName: String!
    var postedId: String!
    var filters: [String]!
    var subfilters: [String]!
    var distanceAway: Double?
    var longLatKey: String!
    var creatorUn: String!
    var isAnnonymous: Bool!
    var timeCreated: Int!
}

class homeObject: NSObject {
    var titler: String!
    var type: Int!
    var key: String!
    var desc: String?
    var imageUrl: String?
    var urlImage2: String!
    var urlImage3: String?
    var long: Double!
    var lat: Double?
    var distanceAway: Double?
    var longLatKey: String!
    var types: [String]!
    var filters: [String]?
    var openHour: Int!
    var openMin: Int!
    var closeHour: Int!
    var closeMin: Int!
    var closedDays: [Int]?
    var hasHours: Bool!
    var ratio: Double?
    var searchFilters: [String]!
    var sortRank: Int!
    var annonymousPost: Bool!
    var timeCreated: Int!
    var creatorUn: String!
    var startDate: Date!
    var endDate: Date!
    var views: Int!
}

class PhotoPost: NSObject {
    
    var urlImage: String!
    //var postedByName: String!
    var timePosted: Int!
    var latitude: Double!
    var longitude: Double!
    var views: Int!
    var key: String!
    var postById: String!
    var distanceAway: Double!
    var keyPlace: String!
    var filters: [String]!
    var subfilters: [String]!
}

class Place: NSObject {
    var titler: String!
    var key: String!
    var desc: String?
    var imageUrl: String?
    var urlImage2: String?
    var urlImage3: String?
    var long: Double!
    var lat: Double?
    var distanceAway: Double?
    var longLatKey: String!
    var types: [String]!
    var filters: [String]?
    var subfilters: [String]!
    var openHour: Int!
    var openMin: Int!
    var closeHour: Int!
    var closeMin: Int!
    var closedDays: [Int]?
    var hasHours: Bool!
    var ratio: Double?
    var searchFilters: [String]!
    var sortRank: Int!
}

class searchObject: NSObject {
    var name: String!
    var key: String!
    var isSelected: Bool!
    var long: Double!
    var lat: Double!
}

class reviewObject: NSObject {
    var descrpt: String!
    var creator: String!
    var timePosted: Int!
    var likeDislike: Int!
    var key: String!
}




