//
//  DataProviderModal.swift
//  TrackTruckApp
//
//  Created by Rajat Raj on 16/11/21.
//

import Foundation
struct TruckDataRuleEngine: Codable {
    let data: [TruckData]?
}
struct TruckData: Codable {
    let id: Int?
    let truckNumber: String?
    let lastWaypoint: PositionData?
    let lastRunningState: RunningStates?
}
struct PositionData: Codable {
    let lat: Double?
    let lng: Double?
    let createTime: Int?
    let speed: Double?
    let ignitionOn: Bool?
}
struct RunningStates: Codable {
    let stopStartTime: Int?
    let truckRunningState: Int?
}
