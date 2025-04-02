//
//  HomePage.swift
//  GreenScore
//
//  Created by Yamil Yscapa on 02/04/25.
//

import SwiftUI

struct HomeView: View {

    var streak: Int = 10

    var body: some View {
        VStack(alignment: .leading) {
            ViewTitle(streak: streak).padding(.top, 40)
            CircularProgressBar(progress: 0.25).padding(.top, 24)
                Spacer()
            }
    }

    struct ViewTitle: View {

        var streak: Int

        var body: some View {
                HStack() {
                    Text("Streak -")
                        .font(
                            .system(
                                size: 24,
                                weight: .medium)
                        )
                    Text("\(streak) days")
                        .font(
                            .system(
                                size: 24,
                                weight: .medium)
                        ).foregroundStyle(Color("MainColor"))
                }
        }
    }
}

#Preview {
    HomeView()
}
