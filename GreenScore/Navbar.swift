//
//  Navbar.swift
//  GreenScore
//
//  Created by Yamil Yscapa on 01/04/25.
//

import SwiftUI

struct Navbar: View {
    var body: some View {
        HStack(spacing: 55) {
            Button(action: {}) {
                Image(systemName: "trophy.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            Button(action: {}) {
                Image(systemName: "plus.app.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            Button(action: {}) {
                Image(systemName: "person.fill")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 30, height: 30)
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
        }.frame(maxWidth: .infinity)
            .padding(.top, 15).padding(.bottom, 25)
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.gray).opacity(0.25),
                    alignment: .top
                )
    }
}
