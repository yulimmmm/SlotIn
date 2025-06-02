//
//  HistoryView.swift
//  SlotIn
//
//  Created by Yulim KIm on 6/1/25.
//

import SwiftUI

struct HistoryView: View {
    
    struct Constants {
      static let GrayGray100: Color = Color(red: 0.95, green: 0.95, blue: 0.95)
    }
    
    var body: some View {
        VStack {
            Text("작업 선택")
              .font(
                Font.custom("SF Pro", size: 28)
                  .weight(.bold)
              )
              .kerning(0.38)
              .foregroundColor(Constants.GrayGray100)
            
            Text("기존 일정이 등록된 날짜를 선택해주세요")
            .font(
            Font.custom("SF Pro", size: 17)
            .weight(.semibold)
            )
            .foregroundColor(Constants.GrayGray100)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        .padding()

        }
    }

#Preview {
    HistoryView()
}
