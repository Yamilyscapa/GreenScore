//
//  Navbar.swift
//  GreenScore
//
//  Created by Yamil Yscapa on 01/04/25.
//

import SwiftUI

struct Navbar: View {

    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor.white
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    NavbarTab(iconName: "house.fill")
                    Text("Home")
                }
            ChallengesView()
                .tabItem {
                    NavbarTab(iconName: "trophy.fill")
                    Text("Challenges")
                }
            ProfileView()
                .tabItem {
                    NavbarTab(iconName: "plus.app.fill")
                    Text("Log")
                }
            LogActionView()
                .tabItem {
                    NavbarTab(iconName: "person.fill")
                    Text("Profile")
                }

        }
        .accentColor(Color("MainColor"))
    }
}

// Navigation tabs
struct NavbarTab: View {
    var iconName: String

    var body: some View {
        Image(systemName: iconName).imageScale(.large)

    }
}

#Preview {
    Navbar()
}
