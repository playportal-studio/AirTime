//
//  PlayPortalLeaderboardEntry.swift
//
//  Created by Lincoln Fraley on 10/29/18.
//

import Foundation

//  Class representing a playPORTAL user's leaderboard entry
public struct PlayPortalLeaderboardEntry: Codable {
    
    //  MARK: - Properties
    public let score: Double
    public let rank: Int
    public let categories: [String]
    public let user: PlayPortalProfile
}
