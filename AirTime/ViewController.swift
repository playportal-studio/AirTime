//
//  ViewController.swift
//  AirTime
//
//  Created by Jett Black on 9/6/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import UIKit
import KontaktSDK

let peripheralUUID = "HsDujU"

class ViewController: UIViewController {
    
    var devicesManager: KTKDevicesManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        devicesManager = KTKDevicesManager(delegate: self)
        devicesManager.startDevicesDiscovery()
    }
}

extension ViewController: KTKDevicesManagerDelegate {
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        print("Did discover: \(devices)")
        guard let device = devices.filter({$0.uniqueID == peripheralUUID}).first else { return }
        let connection = KTKDeviceConnection(nearbyDevice: device)
        print("Discovered with connection: \(connection)")
        
    }
}
