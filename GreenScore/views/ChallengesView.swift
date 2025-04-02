import SwiftUI

// Challenge model structure
struct Challenge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    var progress: Double
    let points: Int
    var isCompleted: Bool
    var isActive: Bool
    let impactDescription: String
    let duration: String
}

// Detail view for a challenge with confirmation button
struct ChallengeDetailView: View {
    var challenge: Challenge
    @Binding var isPresented: Bool
    var onConfirm: () -> Void

    @State private var dragOffset = CGSize.zero
    @State private var showConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 4)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                isPresented = false
            }

            Text(challenge.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(challenge.description)
                .font(.body)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(Color("MainColor"))
                        .frame(width: 24)
                    Text("Potential impact: \(challenge.impactDescription)")
                }

                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text("Duration: \(challenge.duration)")
                }

                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                        .frame(width: 24)
                    Text("Reward: \(challenge.points) points")
                }
            }
            .padding(.bottom, 24)

            // Confirmation button
            if showConfirmation {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("MainColor"))
                    Text("Challenge accepted!")
                        .foregroundColor(Color("MainColor"))
                        .fontWeight(.medium)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(Color("MainColor").opacity(0.1))
                .cornerRadius(8)
                .onAppear {
                    // Auto-dismiss after showing confirmation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isPresented = false
                    }
                }
            } else {
                CustomButton(buttonText: "Start challenge" , handler: {
                    // Call the onConfirm callback first
                    onConfirm()

                    // Show confirmation message
                    withAnimation {
                        showConfirmation = true
                    }

                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                })
            }

            Spacer()
        }
        .padding(16)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Only track downward drags
                    if gesture.translation.height > 0 {
                        self.dragOffset = gesture.translation
                    }
                }
                .onEnded { gesture in
                    // If dragged more than 96 points down, dismiss
                    if gesture.translation.height > 96 {
                        isPresented = false
                    }
                    self.dragOffset = .zero
                }
        )
        // Apply a small offset during drag for visual feedback
        .offset(y: min(dragOffset.height * 0.3, 96))
        // Add animation for smooth effect
        .animation(.spring(), value: dragOffset)
    }
}

// Container view for multiple challenges
struct ChallengesView: View {
    // Challenge data
    @State private var challenges = [
        Challenge(
            title: "Energy saving challenge",
            description:
                "Reduce the time you left your light bulbs on when you are not using them",
            progress: 0.3,
            points: 200,
            isCompleted: false,
            isActive: false,
            impactDescription: "Reduce energy consumption by 15%",
            duration: "7 days"
        ),
        Challenge(
            title: "Water conservation",
            description:
                "Reduce water usage by taking shorter showers this week",
            progress: 0.6,
            points: 150,
            isCompleted: false,
            isActive: false,
            impactDescription: "Save up to 500 gallons of water",
            duration: "5 days"
        ),
    ]

    // Total score
    @State private var totalScore: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {  // Base 8: 2 * 8
                // Header with title and score
                HStack {
                    Text("Challenges")
                        .font(.title)
                        .fontWeight(.bold)

                    Spacer()

                    HStack(spacing: 4) {
                        Text("\(totalScore)")
                            .font(.headline)
                            .foregroundColor(Color("MainColor"))
                            .fontWeight(.bold)

                        Text("points")
                            .font(.subheadline)
                            .foregroundColor(Color("MainColor"))
                    }
                }
                .padding(.horizontal, 16)  // Base 8: 2 * 8

                // Challenge cards
                ForEach(0..<challenges.count, id: \.self) { index in
                    ChallengeCard(
                        challenge: challenges[index],
                        onStart: {
                            // Mark as active
                            challenges[index].isActive = true

                            // In a real app, you'd track progress over time
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 2.0
                            ) {
                                withAnimation {
                                    challenges[index].progress = 1.0
                                    challenges[index].isCompleted = true
                                    totalScore += challenges[index].points
                                }
                            }
                        }
                    )
                }
            }
            .padding(16)  // Base 8: 2 * 8
        }
        .tabItem {
            Image(systemName: "trophy.fill")
            Text("Challenges")
        }
    }
}

#Preview {
    ChallengesView()
}
