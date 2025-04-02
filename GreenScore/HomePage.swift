//
//  HomePage.swift
//  GreenScore
//
//  Created by Yamil Yscapa on 02/04/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home").font(.system(size: 20, weight: .bold))
            CustomButton(buttonText: "Log", isSmall: true)
            CustomButton(buttonText: "Click me")

        }
    }
}
