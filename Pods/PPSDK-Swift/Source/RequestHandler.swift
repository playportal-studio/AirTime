//
//  RequestHandler.swift
//
//  Created by Lincoln Fraley on 10/23/18.
//

let globalRequestHandler: RequestHandler = AlamofireRequestHandler.shared

//  Protocol to be adopted by class responsible for making requests to playPORTAL apis
protocol RequestHandler {
    
    //  MARK: - Properties
    
    var accessToken: String? { get }
    
    var refreshToken: String? { get }
    
    var isAuthenticated: Bool { get }
    
    
    //  MARK: - Methods
    
    /**
     Set tokens received through SSO.
     
     - Parameter accessToken: Access token received through SSO.
     - Parameter refreshToken: Refresh token received through SSO.
     
     - Returns: True if the tokens were set successfully
    */
    @discardableResult
    func set(accessToken: String, andRefreshToken refreshToken: String) -> Bool
    
    /**
     Clear SSO tokens.
     
     - Returns: True if tokens were cleared successfully.
    */
    @discardableResult
    func clearTokens() -> Bool
    
    /**
     Make request.
     
     - Parameter request: The request being made.
     - Parameter completion: The closure invoked after the request is made.
     - Parameter error: The error returned for an unsuccessful request.
     - Parameter response: The response returned for the request.
     - Parameter data: The data returned for a successful request.
     
     - Returns: Void
     */
    func request(_ request: URLRequestConvertible, _ completion: ((_ error: Error?, _ response: HTTPURLResponse?, _ data: Data?) -> Void)?) -> Void
}
