//
//  ApplyDeviceConfigViewController.swift
//  Developer Samples
//
//  Created by Szymon Bobowiec on 24.01.2017.
//  Copyright © 2017 kontakt.io. All rights reserved.
//

import UIKit
import KontaktSDK

class ViewController: UIViewController {

    // =========================================================================
    // MARK: - Constants
    
    let DEVICE_NOT_FOUND_TIMEOUT: TimeInterval! = TimeInterval(7.0)
    
    var devicesManager: KTKDevicesManager!
    
    var configuration: KTKDeviceConfiguration!
    
    var timer: Timer!
    
    // =========================================================================
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize Devices Manager
        devicesManager = KTKDevicesManager(delegate: self)
        set()
        applyConfig()
    }
    
    // =========================================================================
    // MARK: - Actions
    
    func applyConfig() {
        showInfo(info: "Looking for device ...")
        devicesManager.startDevicesDiscovery(withInterval: 2.0)
        
        // Schedule timer - perform actions when device not found
        timer = Timer.scheduledTimer(timeInterval: DEVICE_NOT_FOUND_TIMEOUT,
                                     target: self,
                                     selector: #selector(onDeviceNotFound),
                                     userInfo: nil,
                                     repeats: false);
    }
    
    func onDeviceNotFound() {
        devicesManager.stopDevicesDiscovery()
        showError(error: "Device not found")
    }
    
    // =========================================================================
    // MARK: - Private

    private func set() {
        
        // Validate unique ID length
        let uniqueID = "HsDujU"
        configuration = KTKDeviceConfiguration(uniqueID: uniqueID)
        
        // Validate major value
        let major = UInt16(123)
        configuration.major = major as NSNumber?
        
        // Validate minor value
        let minor = UInt16(456)
        configuration.minor = minor as NSNumber?

    }
    
    // =========================================================================
    // MARK: - Helper Methods
    
    func showInfo(info: String!) {
        print("INFO")
        print(info)
        print()
    }
    
    func showError(error: String!) {
        print("ERROR")
        print(error)
        print()
    }
    
    func showSuccessInfo(info: String!) {
        print("SUCCESS INFO")
        print(info)
        print()
    }
    
}

// =========================================================================
// MARK: - KTKDevicesManagerDelegate

extension ViewController: KTKDevicesManagerDelegate {
    
    func devicesManager(_ manager: KTKDevicesManager, didDiscover devices: [KTKNearbyDevice]) {
        
        // Filter for desired device
        if let device = devices.filter({$0.uniqueID == configuration.uniqueID}).first {
            // Device found - stop discovery
            devicesManager.stopDevicesDiscovery()
            
            // Invalidate timer
            timer.invalidate()
            
            // Try to connect with device
            let connection: KTKDeviceConnection? = KTKDeviceConnection(nearbyDevice: device)
            
            // Check if connected
            if let connection = connection {
                showInfo(info: "Applying configuration ...")
                
                // Write config if connected to device
                connection.write(configuration) { synchronized, appliedConfiguration, error in
                    // Check if config applied successfully
                    if let _ = error {
                        self.showError(error: "Error while applying configuration")
                    } else {
                        self.showSuccessInfo(info: "Configuration applied")
                    }
                }
            }
        }
    }
    
    func devicesManagerDidFail(toStartDiscovery manager: KTKDevicesManager, withError error: Error) {
        print("Discovery did fail with error: \(String(describing: error))")
        self.showError(error: "Device discovery did fail")
    }
    
}
