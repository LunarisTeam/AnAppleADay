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
    @State private var showInfo = false
    
    let plus = Text("+").font(.title)

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("An Apple")
                Text("A Day")
            }
            .font(.extraLargeTitle)
            .fontWidth(.expanded)
            
            Spacer()
            
            HStack(spacing: 15) {
                Button {
                    showingFilePicker = true
                } label: {
                    Text("\(plus) Import DICOM")
                        .frame(height: 55)
                }
                .buttonBorderShape(.capsule)
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
                
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info")
                }
                .buttonBorderShape(.circle)
                
                //The position will depend on the content that will later be defined
                .popover(isPresented: $showInfo, attachmentAnchor: .point(.init(x: 4.8, y: 4.8))) {
                    Text("Lorem ipsum dolor sit amet, UAGLIU! YOU SHOW THE LIGHT THAT STOP ME TURN TO STOOONE, YOU SHINE IT WHEN I'M ALONE. WOHOOOOOOOOOOOO")
                        .font(.body)
                        .fontWeight(.medium)
                        .padding()
                        .frame(width: 350)
                        .multilineTextAlignment(.center)
                }
            }
            
            Spacer()
            
            if let fileURL = fileURL {
                Text("Your selection: \(fileURL.lastPathComponent)")
                    .padding()
            }
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ImportDicomViews()
}
