//
//  InterfaceController.swift
//  AirTime WatchKit App Extension
//
//  Created by Lincoln Fraley on 9/7/18.
//  Copyright © 2018 Dynepic, Inc. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import CoreMotion


class ChallengeInterfaceController: WKInterfaceController {

    //  MARK: - Outlets
    
    @IBOutlet var jumpLabel: WKInterfaceButton!
    
    
    //  MARK: Properties
    
    var active = false
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    let upperBound = 20.0
    let lowerBound = 2.0
    let sampleRate = 60
    var sampleInterval: Int {
        get { return 1 / sampleRate }
    }
    var bufferSize: Int {
        get { return sampleRate / 5 }
    }
    var jumpCounter: JumpCounter?
    var numJumps = 0
    
    //  MARK: Initialization
   
    override init() {
        super.init()
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
        self.start()
    }
    
    // MARK: WKInterfaceController
    
    override func willActivate() {
        super.willActivate()
        active = true
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        active = false
    }

    func start() {
        numJumps = 0
        jumpLabel.setTitle("\(numJumps)")
        
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return
        }
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .play
        workoutConfiguration.locationType = .outdoor
        
        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        // Start the workout session and device motion updates.
        healthStore.start(session!)
        
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        // Reset everything when we start.
        jumpCounter = JumpCounter(upperBound: upperBound, lowerBound: lowerBound, sampleRate: sampleRate, bufferSize: bufferSize, jumpFound: jumpFound)
        
        motionManager.deviceMotionUpdateInterval = TimeInterval(sampleInterval)
        motionManager.startAccelerometerUpdates(to: queue) { deviceMotion, error in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            if let deviceMotion = deviceMotion {
                self.jumpCounter?.input(x: deviceMotion.acceleration.x, y: deviceMotion.acceleration.y, z: deviceMotion.acceleration.z)
            }
        }
    }
    
    @IBAction func stop() {
        if (session == nil) {
            return
        }
        // Stop the device motion updates and workout session.
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
        healthStore.end(session!)
        
        // Clear the workout session.
        session = nil
        
        //  Clear jump counter
        jumpCounter = nil
        
        jumpLabel.setTitle("\(0)")
        
        //send numJump to phone
        
        WKInterfaceController.reloadRootControllers(withNames: ["InitialInterfaceController"], contexts: [])
    }
    
    //  MARK: Methods
    
    func jumpFound(jumps: Int) {
        numJumps = jumps
        jumpLabel.setTitle("\(numJumps)")
    }
    
    @IBAction func incrementJumpLabel() {
        numJumps = numJumps + 1
        jumpLabel.setTitle("\(numJumps)")
    }
    
}
