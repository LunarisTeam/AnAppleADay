//
//  ImportDicomViews.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportDicomViews: View {
    
    @State private var fileURL: URL?
    @State private var showingFilePicker = false

    var body: some View {
        VStack {
            Button("Load Files") {
                showingFilePicker = true
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [UTType.data],
                allowsMultipleSelection: false
            ) { result in
                do {
                    fileURL = try result.get().first
                } catch {
                    print("Could not select the files: \(error.localizedDescription)")
                }
            }
            
            if let fileURL = fileURL {
                Text("Your selection: \(fileURL.lastPathComponent)")
                    .padding()
            }
        }
        .padding()
    }
}

#Preview {
    ImportDicomViews()
}
