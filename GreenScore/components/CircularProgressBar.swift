//
//  CircularProgressBar.swift
//  GreenScore
//
//  Created by Yamil Yscapa on 02/04/25.
//

import SwiftData
import SwiftUI

struct CircularProgressBar: View {
    @Environment(\.modelContext) private var context
    @Query var FootprintModel: [Footprint]
    
    var progress: CGFloat

    var body: some View {

        HStack(spacing: 52) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 25)
                    .opacity(0.3)
                    .foregroundColor(.gray).opacity(0.50)

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(
                        progress < 0.6 ? Color("MainColor") : .red,
                        lineWidth: 25
                    )
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.linear(duration: 1.0), value: progress)
            }
            .frame(width: 140, height: 140)

            VStack(alignment: .leading) {
                Text("Contamination \n generated").font(
                    .system(size: 16, weight: .light)
                )
                .foregroundColor(.gray).padding(.bottom, 5)

                Text("\(Int((FootprintModel.first?.total ?? 0) * 100))%")
                    .font(.system(size: 28, weight: .bold))
            }
        }
    }
}

#Preview {
    HomeView().modelContainer(for: Footprint.self, inMemory: true)
}
