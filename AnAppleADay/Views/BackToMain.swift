//
//  BackToMain.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 01/04/25.
//

import SwiftUI

struct BackToMain: View {
    
    @Environment(\.setMode) private var setMode
    var body: some View {
        Button {
            Task { await setMode(.importDicoms, nil) }
        } label: {
            Image(systemName: "chevron.left")
                .background(Color("backgroundColor"))
        }
        .buttonBorderShape(.circle)
    }
}

#Preview {
    BackToMain()
}
