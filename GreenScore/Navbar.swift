//
//  Navbar.swift
//  GreenScore
//
//  Created by Yamil Yscapa on 01/04/25.
//

import SwiftUI

struct Navbar: View {
    var body: some View {
        TabView {
                HomeView()
                    .tabItem {
                        NavbarTab(iconName: "house.fill")
                }
                ChallengesView()
                    .tabItem {
                        NavbarTab(iconName: "trophy.fill")
                    }
                ProfileView()
                    .tabItem {
                        NavbarTab(iconName: "plus.app.fill")
                    }
                LogActionView()
                    .tabItem {
                        NavbarTab(iconName: "person.fill")
                    }
            }.accentColor(Color("MainColor"))
            .frame(maxWidth: .infinity)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.gray).opacity(0.25),
                    alignment: .top
                ).padding(.horizontal, 20)
    }
    }

// Navigation tabs
struct NavbarTab: View {
    
    var iconName: String
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: iconName)
                .resizable()
                .foregroundColor(.gray)
                .frame(width: 30, height: 30)
                .scaledToFit()
                .frame(width: 60, height: 60)
        }
    }
}
