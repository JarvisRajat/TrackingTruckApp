//
//  Constants.swift
//  TrackTruckApp
//
//  Created by Rajat Raj on 18/11/21.
//

import Foundation
class Constants {
    
    static func conversionToTimestamp(myMilliseconds: Int)-> String {
        let epochTime = TimeInterval(myMilliseconds) / 1000
        let date = Date(timeIntervalSince1970: epochTime)
        return stringFromTime(interval: Date().timeIntervalSince(date))
    }
    
    static func stringFromTime(interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        return formatter.string(from: interval)!
    }
    
    static func splitDuration(durationText: String)->(val: Int, unit: String) {
        let duration = durationText.components(separatedBy: " ")
        let val = Int(duration[0]) ?? 0
        return(val, duration[1])
    }
    
    static func isInErrorState(val: Int, unit: String)-> Bool {
        if unit == "days" {
            return true
        } else if unit == "hours" && val >= 4 {
            return true
        } else {
            return false
        }
    }
}
