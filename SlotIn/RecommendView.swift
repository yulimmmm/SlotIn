//
//  RecommendView.swift
//  SlotIn
//
//  Created by Yulim KIm on 6/2/25.
//

import SwiftUI

struct RecommendView: View {
    let selectedEventTitle: String
    let selectedRecommendation: RecommendationSlot
    let slotsByDay: [String: [RecommendationSlot]]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 헤더
            Text("추천 시간")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.top)
            
            Text(selectedEventTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0.43, green: 0.73, blue: 0.52))
                .padding(.horizontal)
            
            // 요일별 슬롯 타임라인
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 20) {
                    ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { day in
                        VStack(spacing: 8) {
                            Text(day)
                                .foregroundColor(.gray)
                            
                            ForEach(slotsByDay[day] ?? []) { slot in
                                Text(slot.timeRange)
                                    .font(.caption2)
                                    .frame(width: 60, height: 40)
                                    .background(slot.id == selectedRecommendation.id ? Color.green : Color.black)
                                    .foregroundColor(slot.id == selectedRecommendation.id ? .black : .white)
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            
            // 선택된 슬롯 정보
            VStack(alignment: .leading, spacing: 8) {
                Text(selectedRecommendation.displayDate)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.green)
                
                Text(selectedRecommendation.timeRange)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("추천 사유")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(selectedRecommendation.reason)
                    .font(.footnote)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: {
                    // 저장 기능
                }) {
                    Text("추천 시간 보관하기")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(OutlinedButtonStyle())
                .fontWeight(.semibold)

                Button(action: {
                    // 비교 기능
                }) {
                    Text("기존 일정과 비교")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .buttonStyle(FilledButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black)

        }
    }
}

// MARK: - 버튼 스타일

struct OutlinedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 1))
    }
}

struct FilledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .foregroundColor(.black)
            .padding()
            .background(Color(red: 0.43, green: 0.73, blue: 0.52))
            .cornerRadius(10)
    }
}



