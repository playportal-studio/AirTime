//
//  URLs.swift
//
//  Created by Lincoln Fraley on 10/24/18.
//

import Foundation

//  Namespace containing playPORTAl api available hosts and paths
enum URLs {
    
    static let sandboxHost = "https://api.playportal.io"
    static let productionHost =  "https://sandbox.playportal.io"
    static let developHost = "https://develop-api.goplayportal.com"
    
    
   
   
    
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
    
    enum OAuth {
        
        private static let prefix = "/oauth"
        static let signIn = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + OAuth.prefix + "/signin"
        static let token = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + OAuth.prefix + "/token"
        static let logout = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + OAuth.prefix + "/logout"
    }
    
    enum User {
        
        private static let prefix = "/user/v1"
        static let userProfile = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + User.prefix + "/my/profile"
        static let friendProfiles = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + User.prefix + "/my/friends"
        static let search = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + User.prefix + "/search"
        static let randomSearch = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + User.prefix + "/search/random"
    }
    
    enum Image {
        
        private static let prefix = "/image/v1"
        static let staticImage = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + Image.prefix + "/static"
    }
    
    enum Leaderboard {
        
        private static let prefix = "/leaderboard/v1"
        static let leaderboard = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + Leaderboard.prefix
    }
    
    enum App {
        
        private static let prefix = "/app/v1"
        static let data = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + App.prefix + "/data"
        static let bucket = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + App.prefix + "/bucket"
        static let bucketList = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + App.prefix + "/bucket/list"
    }
    
    enum Notification {
        
        private static let prefix = "/notifications/v1"
        static let create = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + Notification.prefix
        static let register = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + Notification.prefix + "/register"
        static let read = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + Notification.prefix
        static let acknowledge = URLs.getHost(forEnvironment: PlayPortalAuth.shared.environment) + Notification.prefix + "/acknowledge"
    }
}
