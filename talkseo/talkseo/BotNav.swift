//
//  BotNav.swift
//  talkseo
//
//  Created by 곽가린 on 11/18/25.
//

import SwiftUI

struct BotNav: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack {
            BotNavItem(imageName: "timer", title: "타이머", index: 0, selectedTab: $selectedTab)
            BotNavItem(imageName: "write", title: "기록", index: 1, selectedTab: $selectedTab)
            BotNavItem(imageName: "commu", title: "커뮤니티", index: 2, selectedTab: $selectedTab)
            BotNavItem(imageName: "my", title: "마이페이지", index: 3, selectedTab: $selectedTab)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .shadow(color: .black.opacity(0.07), radius: 4, y: -1)
    }
}


struct BotNavItem: View {
    var imageName: String
    var title: String
    var index: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                Image(imageName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(selectedTab == index ? .green : .black)

                Text(title)
                    .font(.caption)
                    .foregroundColor(selectedTab == index ? .green : .black)
            }
            .frame(maxWidth: .infinity)
        }
    }
}



