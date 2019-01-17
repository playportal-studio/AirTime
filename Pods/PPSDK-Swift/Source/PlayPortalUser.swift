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
    
    func asURLRequest() -> URLRequest? {
        switch self {
        case .getUserProfile:
            return Router.get(url: URLs.User.userProfile, params: nil).asURLRequest()
        case .getFriendProfiles:
            return Router.get(url: URLs.User.friendProfiles, params: nil).asURLRequest()
        }
    }
}

//  Responsible for making requests to playPORTAL user api
public final class PlayPortalUser {
    
    public static let shared = PlayPortalUser()
    private let requestHandler: RequestHandler = globalRequestHandler
    private let responseHandler: ResponseHandler = globalResponseHandler
    
    private init() {}
    
    
    //  MARK: - Methods
    
    /**
     Get currently authenticated user's playPORTAL profile.
     
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned on an unsuccessful request.
     - Parameter userProfile: The current user's profile returned on a successful request.
     
     - Returns: Void
     */
    public func getProfile(completion: @escaping (_ error: Error?, _ userProfile: PlayPortalProfile?) -> Void) -> Void {
        requestHandler.request(UserRouter.getUserProfile) {
            self.responseHandler.handleResponse($0, $1, $2, completion)
        }
    }
    
    /**
     Get currently authenticated user's playPORTAL friends' profiles.
     
     - Parameter completion: The closure called when the request finishes.
     - Parameter error: The error returned on an unsuccessful request.
     - Parameter friendProfiles: The current user's friends' profiles returned on a successful request.
     
     - Returns: Void
    */
    public func getFriendProfiles(completion: @escaping (_ error: Error?, _ friendProfiles: [PlayPortalProfile]?) -> Void) -> Void {
        requestHandler.request(UserRouter.getFriendProfiles) {
            self.responseHandler.handleResponse($0, $1, $2, completion)
        }
    }
}
