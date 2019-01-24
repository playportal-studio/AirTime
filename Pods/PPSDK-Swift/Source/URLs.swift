//
//  URLs.swift
//
//  Created by Lincoln Fraley on 10/24/18.
//

import Foundation

//  Struct containing playPORTAl api available hosts and paths
struct URLs {
    
    //  MARK: - Properties
    
    static let sandboxHost = "https://sandbox.playportal.io"
    static let productionHost = "https://api.playportal.io"
    static let developHost = "https://develop-api.goplayportal.com"
    
    
    //  MARK: - Initializers
    
    private init() {}
    
    
    //  MARK: - Methods
    
    /**
     Get playPORTAL api host based on environment.
     
     - Paramenter forEnvironment: The playPORTAL environment currently being executed in.
     
     - Returns: The host.
     */
    static func getHost(forEnvironment environment: PlayPortalEnvironment) -> String {
        switch environment {
        case .sandbox:
            return URLs.sandboxHost
        case .develop:
            return URLs.developHost
        case .production:
            return URLs.productionHost
        }
    }
    
    
    //  MARK: - Internal structs for representing available apis and their endpoints
    
    struct OAuth {
        
        private init() {}
        
        static let signIn = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/oauth/signin"
        static let token = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/oauth/token"
        static let logout = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/oauth/logout"
    }
    
    struct User {
        
        private init() {}
        
        static let userProfile = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/user/v1/my/profile"
        static let friendProfiles = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/user/v1/my/friends"
    }
    
    struct Image {
        
        private init() {}
        
        static let staticImage = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/image/v1/static"
    }
    
    struct Leaderboard {
        
        private init() {}
        
        static let leaderboard = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/leaderboard/v1"
    }
    
    struct App {
        
        private init() {}
        
        internal static let bucket = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + "/app/v1/bucket"
    }
}
