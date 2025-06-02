//
//  EventCardView.swift
//  SlotIn
//
//  Created by Yulim KIm on 6/2/25.
//

import SwiftUI
import EventKit

/// 개별 이벤트를 카드 형식으로 보여주는 뷰
struct EventCardView: View {
    
    /// 표시할 이벤트 객체
    let event: EKEvent
    
    /// 현재 이 이벤트가 선택된 상태인지 여부
    let isSelected: Bool

    var body: some View {
        // 선택 여부에 따라 텍스트 색상을 다르게 설정
        let titleColor = isSelected
            ? Color(red: 0.07, green: 0.14, blue: 0.09) // 선택되었을 때 텍스트 색상 (어두운 녹색)
            : Color(red: 0.84, green: 0.98, blue: 0.87) // 기본 텍스트 색상 (밝은 녹색)

        VStack(alignment: .leading, spacing: 4) {
            // 이벤트 제목
            Text(event.title ?? "제목 없음")
                .font(.subheadline)
                .foregroundColor(titleColor)
                .bold()

            // 시작 시간 ~ 종료 시간
            Text("\(timeString(from: event.startDate)) - \(timeString(from: event.endDate))")
                .font(.caption)
                .foregroundColor(titleColor.opacity(0.8))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        // 카드 배경 색상 (선택 여부에 따라 변경)
        .background(isSelected
                    ? Color(red: 0.43, green: 0.73, blue: 0.52) // 선택 시 밝은 녹색 배경
                    : Color(red: 0.37, green: 0.37, blue: 0.37)) // 기본 배경 색
        .cornerRadius(8)
        // 선택되었을 때 상단 오른쪽에 체크 표시
        .overlay(
            Group {
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.black)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .topTrailing)
                }
            }
        )
    }

    /// Date 객체를 "HH:mm" 형식의 문자열로 변환
    func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
