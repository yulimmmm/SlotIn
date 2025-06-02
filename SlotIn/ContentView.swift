//
//  ContentView.swift
//  SlotIn
//
//  Created by Yulim KIm on 6/1/25.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("작업")
            }
            
            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Image(systemName: "archivebox")
                Text("보관함")
            }
        }
        .tint(Color(red: 0.43, green: 0.73, blue: 0.52))
    }
}


#Preview {
    ContentView()
}
