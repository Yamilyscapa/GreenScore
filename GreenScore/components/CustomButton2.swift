//
//  CustomButton2.swift
//  GreenScore
//
//  Created by Andre Garcia on 03/04/25.
//

import SwiftUI

struct CustomButton2: View {
    let label: String
    let icon: String
    let color: Color
    let habits: [String]
    @Binding var userAction: String

    var body: some View {
        Menu {
            ForEach(habits, id: \.self) { habit in
                Button(action: {
                    // Al seleccionar un hábito, se asigna al campo de texto
                    userAction = habit
                }) {
                    Text(habit)
                }
            }
        } label: {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 90, height: 90)
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
                Text(label)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )
        }
    }
}

struct CustomButton2_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton2(
            label: "Water",
            icon: "drop.fill",
            color: .blue,
            habits: ["Drank water", "Took a shower", "Washed dishes"],
            userAction: .constant("")
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
