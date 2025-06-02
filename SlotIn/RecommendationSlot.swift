//
//  RecommendationSlot.swift
//  SlotIn
//
//  Created by Yulim KIm on 6/2/25.
//

import Foundation

struct WeekData {
    let title: String  // "6월 1주차"
    let days: [DayData]
}

struct DayData {
    let dayName: String  // "월", "화", ...
    let slots: [RecommendationSlot]
}

struct RecommendationSlot: Identifiable {
    let id = UUID()
    let timeRange: String
    let day: String
    let displayDate: String
    let reason: String
    var isSelected: Bool = false
}
