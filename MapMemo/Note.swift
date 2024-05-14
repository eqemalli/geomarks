//
//  Note.swift
//  MapMemo
//
//  Created by Enxhi Qemalli on 23.4.24.
//

import Foundation

struct Note: Codable{
    let id: String
    var title: String
    var content: String
    var latitude: Double
    var longitude: Double
    var date: Date
}
