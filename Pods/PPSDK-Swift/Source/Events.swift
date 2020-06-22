//
//  Events.swift
//  Alamofire
//
//  Created by Lincoln Fraley on 12/10/18.
//

import Foundation

enum Event {
  
  case authenticated(accessToken: String, refreshToken: String)
  case loggedOut(error: Error?)
  case firstRun
}

protocol EventSubscriber: class {
  
  func on(event: Event)
}

class EventHandler {
  
  private typealias SubscriberId = UInt
  
  static let shared = EventHandler()
  private let subscribers = Synchronized<[EventSubscriber]>(value: [])
  
  private var s = [SubscriberId: EventSubscriber]()
  
  func subscribe(_ subscriber: EventSubscriber) {
    //        subscribers.value = subscribers.value + [subscriber]
    let id = UInt(bitPattern: ObjectIdentifier(subscriber as AnyObject))
    if s[id] == nil {
      s[id] = subscriber
    }
  }
  
  func unsubscribe(_ subscriber: EventSubscriber) {
    let id = UInt(bitPattern: ObjectIdentifier(subscriber as AnyObject))
    s[id] = nil
  }
  
  func addSubscriptions() {
    //  todo: remove
    subscribe(PlayPortalAuthClient.shared)
  }
  
  func publish(_ event: Event) {
    //        for subscriber in subscribers.value {
    //            subscriber.on(event: event)
    //        }
    for (id, _) in s {
      s[id]?.on(event: event)
    }
  }
}

extension EventHandler: EventSubscriber {
  
  func on(event: Event) {
    switch event {
    case .loggedOut:
      subscribers.value = []
      s = [:]
    default:
      break
    }
  }
}
