//
//  PlayPortalNotification.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 12/28/18.
//

import Foundation

//  Struct representing a playPORTAL notification
public struct PlayPortalNotification: Codable {
  
  public let notificationId: String
  public let text: String
  public let sender: String
  public let acknowledged: Bool
  
  private init() {
    fatalError("`PlayPortalNotification` instance should only be initialized by decoding.")
  }
}

extension PlayPortalNotification: Equatable {
  
  public static func ==(lhs: PlayPortalNotification, rhs: PlayPortalNotification) -> Bool {
    return lhs.notificationId == rhs.notificationId
  }
}
