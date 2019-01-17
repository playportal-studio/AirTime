//
//  PlayPortalDataBucket.swift
//
//  Created by Lincoln Fraley on 10/29/18.
//

import Foundation

//  Class representing a playPORTAL data bucket
public struct PlayPortalDataBucket {
    
    //  MARK: - Properties
    
    public let id: String
    public let createdDate: Date
    public let users: [String]
    public let isPublic: Bool
    public let data: [String: Any]
    
    //  Used to create date from date string
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter
    }()
    
    
    //  MARK: - Initializers
    
    /**
     Create data bucket from json
     
     - Parameter from: The JSON object representing the data bucket.
     
     - Throws: If any of the properties are unable to be deserialized from the JSON.
     
     - Returns: `PlayPortalDataBucket` instance
    */
    internal init(from json: [String: Any]) throws {
        
        //  Deserialize all properties
        guard let id = json["id"] as? String else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'id' from JSON.")
        }
        guard let dateString = json["createdDate"] as? String
            , let createdDate = PlayPortalDataBucket.dateFormatter.date(from: dateString)
            else {
                throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'createdDate' from JSON.")
        }
        guard let users = json["users"] as? [String] else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'users' from JSON.")
        }
        guard let isPublic = json["public"] as? Int else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'public' from JSON.")
        }
        guard let data = json["data"] as? [String: Any] else {
            throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize 'data' from JSON.")
        }
        
        self.id = id
        self.createdDate = createdDate
        self.users = users
        self.isPublic = isPublic == 1
        self.data = data
    }
}
