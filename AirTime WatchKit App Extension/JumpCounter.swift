//
//  JumpCounter.swift
//  SwingWatch WatchKit Extension
//
//  Created by Lincoln Fraley on 9/7/18.
//  Copyright © 2018 Apple Inc. All rights reserved.
//

import Foundation

func sumSquares(arr: [Double]) -> Double {
    return sqrt(arr.reduce(0.0) { $0 + pow($1, 2) })
}

typealias JumpFoundCallback = (_ jump: Int) -> Void

class JumpCounter {
    
    //  MARK: Properties
    
    let upperBound: Double
    let lowerBound: Double
    let sampleRate: Int
    let bufferSize: Int
    let jumpFound: JumpFoundCallback
    
    var buffer = [Double]()
    var initialSum: Double?
    var currentPeak: Double?
    var jumpTestCounter = 0
    var jumps = 0
    
    //  MARK:  Initialization
    
    init(
        upperBound: Double,
        lowerBound: Double,
        sampleRate: Int,
        bufferSize: Int,
        jumpFound: @escaping JumpFoundCallback
        ) {
        self.upperBound = upperBound
        self.lowerBound = lowerBound
        self.sampleRate = sampleRate
        self.bufferSize = bufferSize
        self.jumpFound = jumpFound
    }
    
    //  MARK: Methods
    func input(x: Double, y: Double, z: Double) {
        
        //  Get sum of squares of components
        let sumOfSquares = sumSquares(arr: [x, y, z])
        
        //  If there is a current peak, continue adding to buffer to get next normalized data point
        if currentPeak != nil {
            
            testForJump(sumOfSquares: sumOfSquares)
            
            //  Else, continue to add to buffer to get next peak
        } else {
            
            buffer.append(sumOfSquares)
            
            //  If buffer has reached buffer size, get sum of buffer
            if buffer.count == bufferSize {
                let sum = buffer.reduce(0, +)
                
                //  If there is already an initialSum, subtract it from the sum to get the normalized data
                if let initialSum = initialSum {
                    let normalized = sum - initialSum
                    
                    //  If normalized is greater than upperBound, set it as the currentPeak
                    if normalized >= upperBound {
                        currentPeak = normalized
                    }
                } else {
                    initialSum = sum
                }
                
                buffer.removeFirst()
            }
        }
    }
    
    func testForJump(sumOfSquares: Double) {
        
        //  If buffer has reached buffer size, get sum
        if buffer.count == bufferSize {
            let sum = buffer.reduce(0, +)
            let normalized = sum - initialSum!
            
            //  Jump found
            if normalized <= lowerBound {
                jumps += 1
                jumpFound(jumps)
                
                currentPeak = nil
            } else {
                
                jumpTestCounter += 1
                
                if (jumpTestCounter >= sampleRate) {
                    
                    currentPeak = nil
                    jumpTestCounter = 0
                }
            }
            
            buffer.removeAll()
        } else {
            buffer.append(sumOfSquares)
        }
    }
    
    func sumSquares(arr: [Double]) -> Double {
        var sum = 0.0
        arr.forEach { sum += pow($0, 2) }
        return sqrt(sum)
    }
}
