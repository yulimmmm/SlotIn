//
//  HomeView.swift
//  SlotIn
//
//  Created by Yulim KIm on 6/1/25.
//

//공휴일 제외시키기

import SwiftUI
import EventKit

struct HomeView: View {
    // 캘린더 이벤트를 관리하는 ViewModel
    @StateObject private var eventManager = CalendarEventManager()

    // 선택된 날짜 (기본은 오늘)
    @State private var selectedDate = Date()
    
    // 사용자가 선택한 이벤트 ID
    @State private var selectedEventID: String?
    
    // 캘린더 뷰 보이기 여부
    @State private var isCalendarVisible = false

    // 선택된 이벤트 객체
    var selectedEvent: EKEvent? {
        eventManager.events.first { $0.eventIdentifier == selectedEventID }
    }

    // MARK: - 추천 슬롯 생성 (한 주 단위)
    func generateWeekRecommendationSlots(for selectedDate: Date) -> [RecommendationSlot] {
        var slots: [RecommendationSlot] = []
        let calendar = Calendar.current

        // 해당 주차의 시작~끝 날짜 범위
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }

        // 0~6일 (월~일) 각각의 날짜를 순회하며 빈 시간 계산
        for offset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: offset, to: weekInterval.start) {
                // 해당 날짜의 이벤트 필터링
                let dayEvents = eventManager.events.filter {
                    calendar.isDate($0.startDate, inSameDayAs: date)
                }.sorted { $0.startDate < $1.startDate }

                // 해당 날짜에서 비어 있는 슬롯 계산
                let daySlots = findFreeSlots(for: date, with: dayEvents)
                slots.append(contentsOf: daySlots)
            }
        }

        return slots
    }

    // MARK: - 하루 단위로 빈 시간대 찾기
    func findFreeSlots(for date: Date, with dayEvents: [EKEvent]) -> [RecommendationSlot] {
        var slots: [RecommendationSlot] = []
        let calendar = Calendar.current

        let dayStart = calendar.date(bySettingHour: 7, minute: 0, second: 0, of: date)!
        let dayEnd = calendar.date(bySettingHour: 23, minute: 0, second: 0, of: date)!

        var previousEnd = dayStart

        for event in dayEvents {
            let gap = event.startDate.timeIntervalSince(previousEnd)

            // 최소 30분 이상 비어있을 때만 추천 슬롯으로 추가
            if gap >= 30 * 60 {
                slots.append(RecommendationSlot(
                    timeRange: timeRangeString(from: previousEnd, to: event.startDate),
                    day: weekdayString(from: previousEnd),
                    displayDate: displayDateString(from: previousEnd),
                    reason: "이 시간대는 다른 일정과 겹치지 않아요!",
                    isSelected: false
                ))
            }
            previousEnd = max(previousEnd, event.endDate)
        }

        // 하루 마지막 여유 시간도 체크
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

    // MARK: - 포맷 함수 (시간범위 / 날짜 / 요일)
    func timeRangeString(from start: Date, to end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
    }

    func displayDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }

    func weekdayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    // MARK: - UI
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {

            Text("작업 선택")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 30)
                .padding(.top, 45)
                .padding(.horizontal, 30)

            Text("기존 일정이 등록된 날짜를 선택해주세요")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.bottom, 15)

            // 날짜 선택 버튼
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        isCalendarVisible.toggle()
                    }
                }) {
                    Text(formattedDate1(selectedDate))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(red: 0.43, green: 0.73, blue: 0.52))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.37, green: 0.37, blue: 0.37))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 30)

            // 이벤트 목록 & 캘린더 뷰
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if isCalendarVisible {
                        // 날짜 선택 캘린더
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                            .datePickerStyle(.graphical)
                            .tint(Color(red: 0.43, green: 0.73, blue: 0.52))
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                            .transition(.opacity)
                            .environment(\.colorScheme, .dark)
                            .onChange(of: selectedDate) { newDate in
                                eventManager.requestAccessAndFetchEvents(for: newDate)
                            }

                    } else if !eventManager.events.isEmpty {
                        // 이벤트가 있는 경우
                        Text("\(formattedDate2(selectedDate))에 등록된 작업 목록")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)

                        LazyVStack(spacing: 10) {
                            // 캘린더에서 가져온 모든 이벤트를 반복하여 표시
                            ForEach(eventManager.events, id: \.eventIdentifier) { event in
                                EventCardView(event: event, isSelected: selectedEventID == event.eventIdentifier)
                                    .onTapGesture {
                                        if selectedEventID == event.eventIdentifier {
                                            selectedEventID = nil
                                        } else {
                                            selectedEventID = event.eventIdentifier
                                        }
                                    }
                            }
                        }

                        Spacer()

                        // 추천 시간으로 이동
                        NavigationLink(
                            destination: {
                                let slots = eventManager.findAvailableTimeSlots(on: selectedDate)
                                let selectedSlot = slots.first ?? RecommendationSlot(
                                    timeRange: "10:00 - 11:00",
                                    day: "월",
                                    displayDate: formattedDate2(selectedDate),
                                    reason: "기본 추천"
                                )
                                RecommendView(
                                    selectedEventTitle: selectedEvent?.title ?? "제목 없음",
                                    selectedRecommendation: selectedSlot,
                                    slotsByDay: Dictionary(grouping: slots, by: { $0.day })
                                )
                            },
                            label: {
                                Text("가능한 시간 추천 받기")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(selectedEventID != nil ? Color(red: 0.43, green: 0.73, blue: 0.52) : Color(red: 0.37, green: 0.37, blue: 0.37))
                                    .foregroundColor(selectedEventID != nil ? .black : .white)
                                    .cornerRadius(10)
                            }
                        )
                        .disabled(selectedEventID == nil)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 30)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .onAppear {
                    // 화면이 나타날 때 이벤트 가져오기
                    eventManager.requestAccessAndFetchEvents(for: selectedDate)
                }
            }
        }
    }

    // MARK: - 날짜 포맷 (선택된 날짜를 버튼에 표시할 용도)
    
    func formattedDate1(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }

    func formattedDate2(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일(E)"
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView()
}
