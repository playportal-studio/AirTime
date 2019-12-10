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
import WatchConnectivity

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
    var jumpsArray : [Date] = []
    
    var watchSession: WCSession? {
        didSet {
            if let session = watchSession {
                session.delegate = self
                session.activate()
            }
        }
    }
    
    //  MARK: Initialization
   
    override init() {
        super.init()
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
        self.start()
    }
    
    // MARK: WKInterfaceController
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.watchSession = WCSession.default
    }
    
    override func willActivate() {
        super.willActivate()
        active = true
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        active = false
    }

    func start() {
        jumpsArray = []
        jumpLabel.setTitle("\(jumpsArray.count)")
        
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
        
        let longestJumpTime = calculateLongestJump()
        print("LONGEST: \(longestJumpTime)")
        
        //send numJump to phone
        do {
            try watchSession!.updateApplicationContext(
                [
                    "totalJumps" : jumpsArray.count,
                    "longestJump": longestJumpTime
                ]
            )
        } catch {
            print("ERROR")
        }
        
//        WKInterfaceController.reloadRootControllers(withNames: ["InitialInterfaceController"], contexts: [])
        WKInterfaceController.reloadRootControllers(withNamesAndContexts: [(name: "InitialInterfaceController", context: [:] as AnyObject)])
    }
    
    //  MARK: Methods
    
    func jumpFound(time: Date) {
        
        jumpsArray.append(time)
        jumpLabel.setTitle("\(jumpsArray.count)")
    }
    
    @IBAction func incrementJumpLabel() {
        #if DEBUG
        jumpsArray.append(Date())
        jumpLabel.setTitle("\(jumpsArray.count)")
        #endif
    }
    
    func calculateLongestJump() -> Double {
        var longestJumpTime : Double = 0.0
        var index = 0
        while index < jumpsArray.count - 1 {
            let firstJumpTime: Date = jumpsArray[index]
            let secondJumpTime: Date = jumpsArray[index+1]
            let jumpDuration = secondJumpTime.timeIntervalSince(firstJumpTime)
            if (jumpDuration > longestJumpTime) {
                longestJumpTime = jumpDuration
            }
            index += 1
        }
        return longestJumpTime
    }
    
}

extension ChallengeInterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("Session activation did complete")
    }
}

extension TimeInterval {
    public var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    public var seconds: Int {
        return Int(self) % 60
    }
    
    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    private var hours: Int {
        return Int(self) / 3600
    }
    
    var stringTime: String {
        if hours != 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes != 0 {
            return "\(minutes)m \(seconds)s"
        } else if milliseconds != 0 {
            return "\(seconds)s \(milliseconds)ms"
        } else {
            return "\(seconds)s"
        }
    }
}
