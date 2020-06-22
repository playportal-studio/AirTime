//
//  PlayPortalLeaderboardClient.swift
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation

class LeaderboardEndpoints: EndpointsBase {
  
  private static let base = LeaderboardEndpoints.host + "/leaderboard/v1"
  
  static let leaderboard = LeaderboardEndpoints.base
}


//  Responsible for making requests to playPORTAL leaderboard api
public final class PlayPortalLeaderboardClient: PlayPortalHTTPClient {
  
  public static let shared = PlayPortalLeaderboardClient()
  
  private override init() {}
  
  /**
   Request leaderboard entries.
   - Parameter page: Supports pagination: at what page to get leaderboards from; defaults to nil (returns first page).
   - Parameter limit: How many entries to get; defaults to nil (returns 10 entries).
   - Parameter forCategories: What entries to return based on their tags.
   - Parameter completion: The closure called when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Parameter leaderboardEntries: The leaderboard entries returned for a successful request.
   - Returns: Void
   */
  public func getLeaderboardEntries(
    _ page: Int? = nil,
    _ limit: Int? = nil,
    forCategories categories: [String],
    _ completion: @escaping (_ error: Error?, _ leaderboardEntries: [PlayPortalLeaderboardEntry]?) -> Void)
    -> Void
  {
    
    let queryParams: [String: Any?] = [
      "categories": categories.joined(separator: ","),
      "page": page,
      "limit": limit
    ]
    
    let handleSuccess: HandleSuccess<[PlayPortalLeaderboardEntry]> = { response, data in
      guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
        let docs = json["docs"] else {
          throw PlayPortalError.API.unableToDeserializeResult(message: "Unable to deserialize PlayPortalLeaderboardEntry array.")
      }
      
      let data = try JSONSerialization.data(withJSONObject: docs, options: [])
      return try self.defaultSuccessHandler(response: response, data: data)
    }
    
    request(
      url: LeaderboardEndpoints.leaderboard,
      method: .get,
      queryParameters: queryParams,
      handleSuccess: handleSuccess,
      completionWithDecodableResult: completion
    )
  }
  
  /**
   Add score to the global leaderboard.
   - Parameter score: The score being added.
   - Parameter forCategories: List of categories to tag the score with.
   - Parameter completion: The closure called when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Parameter leaderboardEntry: The leaderboard entry returned for a successful request.
   - Returns: Void
   */
  public func updateLeaderboard(
    _ score: Double,
    forCategories categories: [String],
    _ completion: ((_ error: Error?, _ leaderboardEntry: PlayPortalLeaderboardEntry?) -> Void)?)
    -> Void
  {
    let body: [String: Any] = [
      "score": score,
      "categories": categories
    ]

    request(
      url: LeaderboardEndpoints.leaderboard,
      method: .post,
      body: body,
      completionWithDecodableResult: completion
    )
  }
}
