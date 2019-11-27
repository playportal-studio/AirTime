//
//  PlayPortalAuthClient.swift
//
//  Created by Lincoln Fraley on 10/22/18.
//

import Foundation
import SafariServices

//  Available playPORTAL environments
public enum PlayPortalEnvironment: String {
  
  case sandbox = "SANDBOX"
  case develop = "DEVELOP"
  case production = "PRODUCTION"
}


//  Can be optionally implemented to handle any SSO errors, errors during refresh, or successful logouts
@objc public protocol PlayPortalLoginDelegate: class {
  
  /**
   Called when an error occurs during SSO flow.
   
   - Parameter with: The error that occurred.
   
   - Returns: Void
   */
  @objc optional func didFailToLogin(with error: Error) -> Void
  
  /**
   Called when an error occurs during refresh or logout.
   
   - Parameter with: The error that occurred.
   
   - Returns: Void
   */
  @objc optional func didLogout(with error: Error) -> Void
  
  /**
   Called when logout occurs without error.
   
   - Returns: Void
   */
  @objc optional func didLogoutSuccessfully() -> Void
}

//  Available auth endpoints
class AuthEndpoints: EndpointsBase {
  
  private static let base = AuthEndpoints.host + "/oauth"
  
  static let signIn = AuthEndpoints.base + "/signin"
  static let token = AuthEndpoints.base + "/token"
  static let logout = AuthEndpoints.base + "/logout"
}


/**
 Responsible for user authentication and token management
 */
public final class PlayPortalAuthClient: PlayPortalHTTPClient {
  
  
  //  MARK: - Properties
  
  //  TODO - remove properties that were moved to playportalclient
  public static let shared = PlayPortalAuthClient()
  private(set) var environment = PlayPortalEnvironment.sandbox
  //    private var clientId = ""
  //    private var clientSecret = ""
  var appId: String {
    get {
      return PlayPortalAuthClient.clientId + PlayPortalAuthClient.clientSecret
    }
  }
  private var redirectURI = ""
  private var isAuthenticatedCompletion: ((_ error: Error?, _ userProfile: PlayPortalProfile?) -> Void)?
  private weak var loginDelegate: PlayPortalLoginDelegate?
  private var safariViewController: SFSafariViewController?
  
  
  //  MARK: - Init/Deinit
  
  private override init() { }
  
  deinit {
    EventHandler.shared.unsubscribe(self)
  }
  
  
  
  
  /**
   Configures the sdk with an app's credentials, environment and redirect URI.
   
   - Parameter forEnvironment: playPORTAL environment the sdk will make requests to.
   - Parameter withClientId: Client id associated with the app.
   - Parameter andClientSecret: Client secret associated with the app.
   - Parameter andRedirectURI: The redirect uri the playPORTAL SSO will use to return an authenticated user's tokens.
   
   - Returns: Void
   */
  public func configure(
    forEnvironment environment: PlayPortalEnvironment,
    withClientId clientId: String,
    andClientSecret clientSecret: String,
    andRedirectURI redirectURI: String)
    -> Void
  {
    EventHandler.shared.addSubscriptions()
    
    //  Because keychain items aren't cleared on app uninstall, but user defaults is,
    //  check flag in user defaults so that old keychain items can be cleared
    if !UserDefaults.standard.bool(forKey: "\(clientId)-PPSDK-firstRun") {
      UserDefaults.standard.set(true, forKey: "\(clientId)-PPSDK-firstRun")
      EventHandler.shared.publish(.firstRun)
      globalStorageHandler.delete("accessToken")
      globalStorageHandler.delete("refreshToken")
    }
    
    //  Set configuration
    PlayPortalAuthClient.environment = environment
    PlayPortalAuthClient.clientId = clientId
    PlayPortalAuthClient.clientSecret = clientSecret
    self.redirectURI = redirectURI
  }
  
  /**
   Check if current user is authenticated. If not, SSO flow will need to be initiated.
   
   - Parameter loginDelegate: Optionally include login delegate.
   - Parameter completion: The closure invoked after requesting the user's profile.
   - Parameter error: The error returned from an unsuccessful request.
   - Parameter userProfile: The playPORTAL user profile returned from a successful request.
   
   - Returns: Void
   */
  public func isAuthenticated(
    loginDelegate: PlayPortalLoginDelegate? = nil,
    _ completion: @escaping (_ error: Error?, _ userProfile: PlayPortalProfile?) -> Void)
    -> Void
  {
    EventHandler.shared.addSubscriptions()
    self.loginDelegate = loginDelegate
    
    if PlayPortalAuthClient.isAuthenticated {
      //  If authenticated, request current user's profile
      PlayPortalUserClient.shared.getMyProfile(completion: completion)
    } else {
      //  If not authenticated, set `isAuthenticatedCompletion` to be used after SSO flow finishes
      isAuthenticatedCompletion = completion
      completion(nil, nil)
    }
  }
  
  /**
   Opens playPORTAL SSO.
   
   - Parameter delegate: PlayPortalLoginDelegate to handle any SSO errors.
   - Parameter from: UIViewController to present SFSafariViewController; defaults to topmost view controller.
   
   - Returns: Void
   */
  func login(from viewController: UIViewController? = UIApplication.topMostViewController()) {
    
    guard var components = URLComponents(string: AuthEndpoints.signIn) else {
      fatalError("Couldn't create login url.")
    }
    
    components.queryItems = [
      URLQueryItem(name: "client_id", value: PlayPortalAuthClient.clientId),
      URLQueryItem(name: "client_secret", value: PlayPortalAuthClient.clientSecret),
      URLQueryItem(name: "redirect_uri", value: redirectURI),
      URLQueryItem(name: "response_type", value: "implicit"),
      URLQueryItem(name: "state", value: "state"),
      URLQueryItem(name: "app_login", value: String(PlayPortalAuthClient.environment != .sandbox))
    ]
    guard let url = components.url else {
      fatalError("Couldn't create login url.")
    }
    
    //  Open SSO sign in with safari view controller
    safariViewController = SFSafariViewController(url: url)
    safariViewController!.modalTransitionStyle = .coverVertical
    viewController?.present(safariViewController!, animated: true, completion: nil)
  }
  
  /**
   This function must be invoked in the AppDelegate's application(_:handleOpen:) method to handle a successful redirect from the playPORTAL SSO.
   
   - Parameters url: The redirect URI called by playPORTAL SSO containing a user's tokens.
   
   - Returns: Void
   */
  public func open(url: URL) -> Void {
    
    //  Dismiss safari view controller
    safariViewController?.dismiss(animated: true, completion: nil)
    
    //  Extract tokens
    guard let accessToken = url.getParameter(for: "access_token") else {
      loginDelegate?.didFailToLogin?(with: PlayPortalError.SSO.ssoFailed(message: "Could not extract access token from redirect uri."))
      return
    }
    guard let refreshToken = url.getParameter(for: "refresh_token") else {
      loginDelegate?.didFailToLogin?(with: PlayPortalError.SSO.ssoFailed(message: "Could not extract refresh token from redirect uri."))
      return
    }
    
    EventHandler.shared.publish(Event.authenticated(accessToken: accessToken, refreshToken: refreshToken))
    
    PlayPortalAuthClient.accessToken = accessToken
    PlayPortalAuthClient.refreshToken = refreshToken
    
    //  Request current user's profile
    if let completion = isAuthenticatedCompletion {
      PlayPortalUserClient.shared.getMyProfile(completion: completion)
    }
  }
  
  //  TODO: - remove all refresh code
  struct TokenResponse: Codable {
    
    let accessToken: String
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
      case accessToken = "access_token"
      case refreshToken = "refresh_token"
    }
  }
  
  /**
   Called when a refresh is required.
   
   - Parameter completion: The closure invoked when the request finishes.
   - Parameter error: The error returned on an unsuccessful request.
   - Parameter accessToken: The new access token returned on a successful request.
   - Parameter refreshToken: The new refresh token returned on a successful request.
   
   - Returns: Void
   */
  
  //  todo: remove
  func refresh(
    accessToken: String,
    refreshToken: String,
    completion: @escaping (_ error: Error?, _ accessToken: String?, _ refreshToken: String?) -> Void)
    -> Void
  {
    //        let request = AuthRouter.refresh(accessToken: accessToken, refreshToken: refreshToken, clientId: PlayPortalClient.clientId, clientSecret: PlayPortalClient.clientSecret, grantType: "refresh_token")
    //        RequestHandler.shared.request(request) { (error, tokenResponse: TokenResponse?) in
    //            completion(error, tokenResponse?.accessToken, tokenResponse?.refreshToken)
    //        }
  }
  
  override func onEvent() {
    print("calling on event in auth")
  }
  
  /**
   Logout current user.
   
   - Returns: Void
   */
  public func logout() -> Void {
    
    var body = [String: String]()
    
    if let refreshToken = PlayPortalAuthClient.refreshToken {
      body["refresh_token"] = refreshToken
    }
    
    request(
      url: AuthEndpoints.logout,
      method: .post,
      body: body,
      handleSuccess: { _, data in data }
    ) { error, _ in
      PlayPortalAuthClient.lock.lock(); defer { PlayPortalAuthClient.lock.unlock() }
      
      URLSession.shared.getAllTasks { $0.forEach { $0.cancel() }}
      globalStorageHandler.delete("accessToken")
      globalStorageHandler.delete("refreshToken")
      PlayPortalAuthClient.isRefreshing = false
      PlayPortalAuthClient.requestsToRetry.removeAll()
      
      self.onEvent()
      
      if let error = error {
        self.loginDelegate?.didLogout?(with: error)
      } else {
        self.loginDelegate?.didLogoutSuccessfully?()
      }
    }
  }
}

extension PlayPortalAuthClient: EventSubscriber {
  
  func on(event: Event) {
    switch event {
    case let .loggedOut(error):
      if let error = error {
        loginDelegate?.didLogout?(with: error)
      } else {
        loginDelegate?.didLogoutSuccessfully?()
      }
    default:
      break
    }
  }
}
