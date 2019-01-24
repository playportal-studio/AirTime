//
//  PlayPortalLeaderboard.swift
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation

//  Available routes for playPORTAL leaderboard api
fileprivate enum LeaderBoardRouter: URLRequestConvertible {
    
    case get(categories: [String], page: Int?, limit: Int?)
    case update(score: Double, categories: [String])
    
    func asURLRequest() -> URLRequest? {
        switch self {
        case let .get(categories, page, limit):
            let params: [String: String?] = [
                "categories": categories.joined(separator: ","),
                "page": page.flatMap {String($0)},
                "limit": limit.flatMap {String($0)}
            ]
            return Router.get(url: URLs.Leaderboard.leaderboard, params: params).asURLRequest()
        case let .update(score, categories):
            let body: [String: Any] = [
                "score": score,
                "categories": categories
            ]
            return Router.post(url: URLs.Leaderboard.leaderboard, body: body, params: nil).asURLRequest()
        }
    }
}


//  Responsible for making requests to playPORTAL leaderboard api
public final class PlayPortalLeaderboard {
    
    public static let shared = PlayPortalLeaderboard()
    private let requestHandler: RequestHandler = globalRequestHandler
    private let responseHandler: ResponseHandler = globalResponseHandler
    
    private init() {}
    
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
    public func getLeaderboard(
        _ page: Int? = nil,
        _ limit: Int? = nil,
        forCategories categories: [String],
        _ completion: @escaping (_ error: Error?, _ leaderboardEntries: [PlayPortalLeaderboardEntry]?) -> Void)
        -> Void
    {
        requestHandler.request(LeaderBoardRouter.get(categories: categories, page: page, limit: limit)) {
            self.responseHandler.handleResponse($0, $1, $2, atKey: "docs", completion)
        }
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
        requestHandler.request(LeaderBoardRouter.update(score: score, categories: categories)) {
            self.responseHandler.handleResponse($0, $1, $2, completion)
        }
    }
}
