//
//  ProfileView.swift
//  GreenScore
//
//  Created by Yamil Yscapa on 02/04/25.
//

//
//  ChallengesView.swift
//  GreenScore
//

//
import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Foto y nombre
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)

                        Text("Your Name")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("🌱 Eco Points: 0")
                            .foregroundColor(.green)
                            .font(.subheadline)
                    }

                    // Cards informativas
                    VStack(spacing: 16) {
                        profileCard(title: "Action History", icon: "clock")
                        profileCard(title: "Completed Challenges", icon: "checkmark.seal")
                        profileCard(title: "Settings", icon: "gear")
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
    }

    func profileCard(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 32)

            Text(title)
                .font(.headline)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}
