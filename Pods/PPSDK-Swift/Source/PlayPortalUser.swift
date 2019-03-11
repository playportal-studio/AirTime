//
//  PlayPortalUser.swift
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation


//  Available routes for playPORTAL user api
fileprivate enum UserRouter: URLRequestConvertible {
    
    case getUserProfile
    case getFriendProfiles
    case search(searchTerm: String, page: Int?, limit: Int?)
    case randomSearch(count: Int)
    case createRandomUser(clientId: String, dateOfBirth: String, deviceToken: String?)
    
    func asURLRequest() -> URLRequest {
        switch self {
        case .getUserProfile:
            return Router.get(url: URLs.User.userProfile, params: nil).asURLRequest()
        case .getFriendProfiles:
            return Router.get(url: URLs.User.friendProfiles, params: nil).asURLRequest()
        case let .search(searchTerm, page, limit):
            let params: [String: Any?] = [
                "term": searchTerm,
                "page": page,
                "limit": limit
            ]
            return Router.get(url: URLs.User.search, params: params).asURLRequest()
        case let .randomSearch(count):
            let params = [
                "count": count
            ]
            return Router.get(url: URLs.User.randomSearch, params: params).asURLRequest()
        case let .createRandomUser(clientId, dateOfBirth, deviceToken):
            let body: [String: Any?] = [
                "clientId": clientId,
                "dateOfBirth": dateOfBirth,
                "deviceToken": deviceToken,
                "anonymous": true
            ]
            return Router.put(url: URLs.User.userProfile, body: body, params: nil).asURLRequest()
        }
    }
}

//  Responsible for making requests to playPORTAL user api
public final class PlayPortalUser {
    
    public static let shared = PlayPortalUser()
    
    private init() {}
    
    /**
     Get currently authenticated user's playPORTAL profile.
     
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned on an unsuccessful request.
     - Parameter userProfile: The current user's profile returned on a successful request.
     
     - Returns: Void
     */
    public func getProfile(
        completion: @escaping (_ error: Error?, _ userProfile: PlayPortalProfile?) -> Void)
        -> Void
    {
        RequestHandler.shared.request(UserRouter.getUserProfile, completion)
    }
    
    /**
     Get currently authenticated user's playPORTAL friends' profiles.
     
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned on an unsuccessful request.
     - Parameter friendProfiles: The current user's friends' profiles returned on a successful request.
     
     - Returns: Void
    */
    public func getFriendProfiles(
        completion: @escaping (_ error: Error?, _ friendProfiles: [PlayPortalProfile]?) -> Void)
        -> Void
    {
        RequestHandler.shared.request(UserRouter.getFriendProfiles, completion)
    }
    
    /**
     Search for users by search term.
     - Parameter searchTerm: Term to search users by.
     - Parameter page: Supports pagination; at what page to get users from.
     - Paramter limit: How many entries to return.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter users: The users returned for a successful request.
    */
    public func searchUsers(
        searchTerm: String,
        page: Int? = nil,
        limit: Int? = nil,
        completion: @escaping (_ error: Error?, _ users: [PlayPortalProfile]?) -> Void)
        -> Void
    {
        let request = UserRouter.search(searchTerm: searchTerm, page: page, limit: limit)
        RequestHandler.shared.request(request, at: "docs", completion)
    }
    
    /**
     Get a random number of users.
     - Parameter count: The number of users being requested.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter users: The random users returned for a successful request.
    */
    public func searchRandomUsers(
        count: Int,
        completion: @escaping (_ error: Error?, _ users: [PlayPortalProfile]?) -> Void)
        -> Void
    {
        let request = UserRouter.randomSearch(count: count)
        RequestHandler.shared.request(request, completion)
    }
    
    /**
    Create an anonymous user that can be used in place of a user created through the playPORTAL signup flow.
     - Parameter clientId: Client id associated with the app.
     - Parameter dateOfBirth: Date string representing the user's date of birth. This is required to create the appropriate type of account for the user.
     - Parameter deviceToken: Device token used for push notifications for this user.
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter anonymousUser: The anonymous user created for a successful request.
    */
    public func createAnonymousUser(
        clientId: String,
        dateOfBirth: String,
        deviceToken: Data? = nil,
        completion: @escaping (_ error: Error?, _ anonymousUser: PlayPortalProfile?) -> Void)
        -> Void
    {
        let request = UserRouter.createRandomUser(clientId: clientId, dateOfBirth: dateOfBirth, deviceToken: deviceToken?.toHex)
        RequestHandler.shared.createAnonymousUser(request, completion)
    }
}
