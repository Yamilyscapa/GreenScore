//
//  LinearProgressBar.swift
//  GreenScore
//
//  Created by Yamil Yscapa on 02/04/25.
//

import SwiftUI

struct LinearProgressBar: View {
    var progress: Double = 0.0
    
    var body: some View {
        ProgressView(value: progress, total: 1)
            .progressViewStyle(LinearProgressViewStyle(tint: Color("MainColor")))
    }
}
