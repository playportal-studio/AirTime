//
//  PlayPortalImage.swift
//
//  Created by Lincoln Fraley on 10/25/18.
//

import Foundation


//  Available image endpoints
class ImageEndpoints: EndpointsBase {
  
  private static let base = ImageEndpoints.host + "/image/v1"
  
  static let `static` = ImageEndpoints.base + "/static"
}


//  Responsible for making requests to playPORTAL image api
public final class PlayPortalImageClient: PlayPortalHTTPClient {
  
  public static let shared = PlayPortalImageClient()
  
  private override init() {}
  
  /**
   Make request for playPORTAL image by its id
   
   - Parameter forImageId: Id of the image being requested
   - Parameter completion: The closure called when the request finishes.
   - Parameter error: The error returned for an unsuccessful request.
   - Parameter data: The data representing the image returned for a successful request.
   
   - Returns: Void
   */
  public func getImage(
    forImageId imageId: String,
    _ completion: @escaping (_ error: Error?, _ data: Data?) -> Void)
    -> Void
  {
    request(
      url: ImageEndpoints.static + "/" + imageId,
      method: .get,
      handleSuccess: { _, data in data },
      completionWithDecodableResult: completion
    )
  }
}
