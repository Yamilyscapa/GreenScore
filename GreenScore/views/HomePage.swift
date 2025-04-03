//
//  HomePage.swift
//  GreenScore
//
//  Created by Yamil Yscapa on 02/04/25.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query var FootprintModel: [Footprint]

    var body: some View {
        ScrollView {
            HStack {
                ViewTitle().padding(.leading, 24)
                Spacer()
            }
            CircularProgressBar(progress: FootprintModel.first?.total ?? 0.00)
                .padding(.vertical, 40)

            VStack {
                HStack {
                    Text("Progress")
                        .font(
                            .system(
                                size: 24,
                                weight: .medium)
                        ).padding(.leading, 24)
                    Spacer()
                }.padding(.bottom, 24)

                ProgressCard(
                    category: "Water", color: .blue, icon: "drop.fill",
                    percentage: FootprintModel.first?.water ?? 0.0)
                ProgressCard(
                    category: "Energy", color: .yellow, icon: "bolt.fill",
                    percentage: FootprintModel.first?.energy ?? 0.0)
                ProgressCard(
                    category: "Transport", color: .red, icon: "car.fill",
                    isLarge: true,
                    percentage: FootprintModel.first?.transport ?? 0.0)
                ProgressCard(
                    category: "Waste", color: .green, icon: "trash.fill",
                    isLarge: true,
                    percentage: FootprintModel.first?.waste ?? 0.0)
            }.padding(.top, 40).padding(.bottom, 80)
        }.padding(.top, 50)
    }

    struct ProgressCard: View {
        var category: String
        var color: Color
        var icon: String
        var isLarge: Bool = false
        var percentage: Double

        var body: some View {
            VStack {
                HStack(alignment: .center) {

                    Image(systemName: icon)
                        .resizable()
                        .foregroundColor(.white)
                        .frame(
                            width: isLarge ? 23 : 20, height: isLarge ? 22 : 30
                        )
                        .frame(width: 60, height: 60)
                        .background(color)
                        .cornerRadius(100)
                        .scaledToFit()
                    VStack {
                        HStack {
                            Text(category)
                                .font(.system(size: 20, weight: .semibold))
                            Spacer()
                        }

                        LinearProgressBar(progress: percentage)

                    }.padding(.leading, 10)
                    Spacer()

                }.frame(width: 300, height: 90).padding(.horizontal, 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.gray, lineWidth: 4).opacity(0.25)
                    )
                    .cornerRadius(12)
            }
        }
    }

    struct ViewTitle: View {
        @Environment(\.modelContext) private var context
        @Query var streakModel: [Streak]

        var body: some View {
            HStack {
                Text("Streak -")
                    .font(
                        .system(
                            size: 24,
                            weight: .bold)
                    )
                Text("\(streakModel.first?.days ?? 0) days")
                    .font(
                        .system(
                            size: 24,
                            weight: .bold)
                    ).foregroundStyle(Color("MainColor"))
            }
        }
    }
}

#Preview {
    HomeView().modelContainer(for: [Streak.self, Footprint.self])
}
