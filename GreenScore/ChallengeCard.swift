import SwiftUI

struct ChallengeCard: View {
    var challenge: Challenge
    var onStart: () -> Void
    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(challenge.title)
                    .font(.headline)
                    .bold()

                Spacer()

                Text("\(challenge.points) points")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color("MainColor"))
            }

            ProgressView(value: challenge.progress, total: 1)
                .progressViewStyle(LinearProgressViewStyle(tint: Color("MainColor")))

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 96)

            Text(challenge.description)
                .font(.subheadline)
                .foregroundColor(.primary)

            if challenge.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("MainColor"))
                    Text("Completed")
                        .foregroundColor(Color("MainColor"))
                        .fontWeight(.medium)
                }
            } else {
                CustomButton(buttonText: "Start challenge", handler: {
                    showDetails = true
                })
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .sheet(isPresented: $showDetails) {
            ChallengeDetailView(
                challenge: challenge,
                isPresented: $showDetails,
                onConfirm: onStart
            )
        }
    }
}
