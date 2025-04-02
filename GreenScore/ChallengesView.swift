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

// Single challenge component
struct ChallengeCardView: View {
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

// Detail view for a challenge with confirmation button
struct ChallengeDetailView: View {
    var challenge: Challenge
    @Binding var isPresented: Bool
    var onConfirm: () -> Void

    @State private var dragOffset = CGSize.zero
    @State private var showConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {  // Base 8: 2 * 8
            // Drag indicator
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 4)
                Spacer()
            }
            .padding(.top, 8)  // Base 8
            .padding(.bottom, 8)  // Base 8
            .contentShape(Rectangle())
            .onTapGesture {
                isPresented = false
            }

            Text(challenge.title)
                .font(.title2)
                .fontWeight(.bold)

            Text(challenge.description)
                .font(.body)
                .padding(.bottom, 8)  // Base 8

            // Challenge details content
            VStack(alignment: .leading, spacing: 16) {  // Base 8: 2 * 8
                HStack {
                    Image(systemName: "leaf.fill")
                        .foregroundColor(.green)
                        .frame(width: 24)  // Base 8: 3 * 8
                    Text("Potential impact: \(challenge.impactDescription)")
                }

                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)  // Base 8: 3 * 8
                    Text("Duration: \(challenge.duration)")
                }

                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.yellow)
                        .frame(width: 24)  // Base 8: 3 * 8
                    Text("Reward: \(challenge.points) points")
                }
            }
            .padding(.bottom, 24)  // Base 8: 3 * 8

            // Confirmation button
            if showConfirmation {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Challenge accepted!")
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
                .padding(16)  // Base 8: 2 * 8
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)  // Base 8
                .onAppear {
                    // Auto-dismiss after showing confirmation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isPresented = false
                    }
                }
            } else {
                Button(action: {
                    // Call the onConfirm callback first
                    onConfirm()

                    // Show confirmation message
                    withAnimation {
                        showConfirmation = true
                    }

                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                }) {
                    Text("Start challenge")
                        .foregroundColor(.white)
                        .padding(.vertical, 16)  // Base 8: 2 * 8
                        .frame(maxWidth: .infinity)
                        .background(Color("MainColor"))
                        .cornerRadius(24)  // Base 8: 3 * 8
                        .shadow(
                            color: Color.green.opacity(0.3), radius: 4, x: 0,
                            y: 2)
                }
            }

            Spacer()
        }
        .padding(16)  // Base 8: 2 * 8
        .background(Color(UIColor.systemBackground))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // Only track downward drags
                    if gesture.translation.height > 0 {
                        self.dragOffset = gesture.translation
                    }
                }
                .onEnded { gesture in
                    // If dragged more than 96 points down, dismiss (Base 8: 12 * 8)
                    if gesture.translation.height > 96 {
                        isPresented = false
                    }
                    self.dragOffset = .zero
                }
        )
        // Apply a small offset during drag for visual feedback
        .offset(y: min(dragOffset.height * 0.3, 96))  // Base 8: 12 * 8
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
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal, 16)  // Base 8: 2 * 8

                // Challenge cards
                ForEach(0..<challenges.count, id: \.self) { index in
                    ChallengeCardView(
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
        .background(Color(UIColor.systemGroupedBackground))
        .tabItem {
            Image(systemName: "trophy.fill")
            Text("Challenges")
        }
    }
}

#Preview {
    ChallengesView()
}
