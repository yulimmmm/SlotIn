//
//  RecommendCalendarView.swift
//  SlotIn
//
//  Created by Yulim KIm on 6/2/25.
//

import SwiftUI

struct RecommendCalendarView: View {
    @State private var currentWeekIndex = 0
    let weeks: [WeekData] // 1주차, 2주차 ...

    var body: some View {
        VStack(spacing: 16) {
            // 상단 주차 헤더
            HStack {
                Button(action: {
                    if currentWeekIndex > 0 {
                        currentWeekIndex -= 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }

                Spacer()

                Text(weeks[currentWeekIndex].title) // 예: "6월 1주차"
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    if currentWeekIndex < weeks.count - 1 {
                        currentWeekIndex += 1
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }

            // 요일 + 시간 슬롯 표시
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(weeks[currentWeekIndex].days, id: \.dayName) { day in
                        VStack {
                            Text(day.dayName)
                                .foregroundColor(.gray)
                            ForEach(day.slots) { slot in
                                Text(slot.timeRange)
                                    .font(.caption)
                                    .padding(6)
                                    .frame(width: 70)
                                    .background(slot.isSelected ? Color.green : Color.gray.opacity(0.3))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.black)
    }
}
