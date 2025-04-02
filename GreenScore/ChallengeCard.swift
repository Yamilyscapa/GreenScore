//
//  ChallengeCard.swift
//  GreenScore
//
//  Created by Yamil Yscapa on 02/04/25.
//


import SwiftUI

struct ChallengeCard: View {
    var challenge: Challenge
    var onStart: () -> Void
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {  // Base 8 spacing
            HStack {
                Text(challenge.title)
                    .font(.headline)
                    .bold()

                Spacer()

                Text("\(challenge.points) points")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }

            ProgressView(value: challenge.progress, total: 1)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.green))

            RoundedRectangle(cornerRadius: 8)  // Base 8
                .fill(Color.gray.opacity(0.3))
                .frame(height: 96)  // Base 8: 12 * 8

            Text(challenge.description)
                .font(.subheadline)
                .foregroundColor(.primary)

            if challenge.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Completed")
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            } else {
                Button(action: {
                    showDetails = true
                }) {
                    Text("Start challenge")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)  // Base 8
                        .padding(.horizontal, 16)  // Base 8: 2 * 8
                        .background(Color("MainColor"))
                        .cornerRadius(16)  // Base 8: 2 * 8
                }
            }
        }
        .padding(16)  // Base 8: 2 * 8
        .background(Color.white)
        .cornerRadius(16)  // Base 8: 2 * 8
        .shadow(radius: 4)  // Half of 8
        .sheet(isPresented: $showDetails) {
            ChallengeDetailView(
                challenge: challenge,
                isPresented: $showDetails,
                onConfirm: onStart
            )
        }
    }
}
