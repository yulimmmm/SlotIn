//
//  CalendarEventManager.swift
//  SlotIn
//
//  Created by Yulim KIm on 6/2/25.
//

import EventKit
import Foundation

/// 캘린더 이벤트를 관리하고, 비어 있는 시간대를 추천 슬롯으로 추출하는 뷰 모델
class CalendarEventManager: ObservableObject {
    
    /// EventKit의 이벤트 저장소 인스턴스 (사용자 캘린더에 접근)
    private let eventStore = EKEventStore()
    
    /// 특정 날짜에 해당하는 이벤트들을 저장하는 퍼블리시드 변수
    @Published var events: [EKEvent] = []

    // MARK: - 권한 요청 + 이벤트 가져오기

    /// 사용자에게 캘린더 접근 권한을 요청하고, 승인되면 해당 날짜의 이벤트를 가져옴
    /// - Parameter date: 선택된 날짜
    func requestAccessAndFetchEvents(for date: Date) {
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.fetchEvents(for: date)
                }
            } else {
                print("Access denied or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    /// 특정 날짜의 이벤트들을 EventKit에서 가져와 `events` 배열에 저장
    /// - Parameter date: 가져올 기준 날짜
    private func fetchEvents(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // 해당 날짜의 전체 이벤트 범위 설정
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        self.events = eventStore.events(matching: predicate)
    }

    // MARK: - 추천 시간대 생성

    /// 주어진 날짜에 비어 있는 시간대들을 추출하여 추천 슬롯으로 반환
    /// - Parameter date: 대상 날짜
    /// - Returns: RecommendationSlot 배열 (빈 시간대 목록)
    func findAvailableTimeSlots(on date: Date) -> [RecommendationSlot] {
        // 해당 날짜의 이벤트 필터링 및 정렬
        let dayEvents = events
            .filter { Calendar.current.isDate($0.startDate, inSameDayAs: date) }
            .sorted { $0.startDate < $1.startDate }

        var slots: [RecommendationSlot] = []
        let calendar = Calendar.current

        // 하루 시작 시간 (07:00) ~ 종료 시간 (23:00)
        let dayStart = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: date)!
        let dayEnd = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: date)!

        var previousEnd = dayStart

        // 이벤트 사이의 빈 구간을 계산
        for event in dayEvents {
            let gap = event.startDate.timeIntervalSince(previousEnd)
            if gap >= 30 * 60 { // 최소 30분 이상일 때만 추천
                slots.append(RecommendationSlot(
                    timeRange: timeRangeString(from: previousEnd, to: event.startDate),
                    day: weekdayString(from: previousEnd),
                    displayDate: displayDateString(from: previousEnd),
                    reason: "이 시간대는 다른 일정과 겹치지 않아요!",
                    isSelected: false
                ))
            }
            // 이전 종료 시간 갱신
            previousEnd = max(previousEnd, event.endDate)
        }

        // 하루의 마지막 여유 시간 확인
        if dayEnd.timeIntervalSince(previousEnd) >= 30 * 60 {
            slots.append(RecommendationSlot(
                timeRange: timeRangeString(from: previousEnd, to: dayEnd),
                day: weekdayString(from: previousEnd),
                displayDate: displayDateString(from: previousEnd),
                reason: "하루의 마지막 여유 시간이에요.",
                isSelected: false
            ))
        }

        return slots
    }

    // MARK: - 날짜 및 시간 포맷터

    /// 날짜에서 요일(월, 화 등)을 추출
    private func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    /// 두 시간 사이를 "HH:mm ~ HH:mm" 형식으로 반환
    private func timeRangeString(from start: Date, to end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start)) ~ \(formatter.string(from: end))"
    }

    /// 날짜를 "6월 2일 (일)" 형식으로 반환
    private func displayDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }
}
