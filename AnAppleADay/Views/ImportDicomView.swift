//
//  ImportDicomViews.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportDicomView: View {
    
    @Environment(\.setMode) private var setMode
    
    @State private var filesURL: [URL] = []
    @State private var showingFilePicker = false
    @State private var showInfo = false
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 50) {
                Image("Logo").resizable()
                    .frame(width: 150, height: 150)
                Image("intrart").resizable()
                    .frame(width: 394, height: 86)
            }
            Spacer()
            
            HStack(spacing: 15) {
                Button {
                    #if DEBUG
                    Task { await setMode(.generate) }
                    #else
                    showingFilePicker = true
                    #endif
                } label: {
                    HStack {
                        Text("Import DICOM dataset")
                        Image(systemName: "plus")
                    }
                    .frame(height: 55)
                }
                
                .fileImporter(
                    isPresented: $showingFilePicker,
                    allowedContentTypes: [UTType.data],
                    allowsMultipleSelection: true
                ) { result in
                    do {
                        let selectedFiles = try result.get()
                        filesURL.append(contentsOf: selectedFiles)
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
                .popover(isPresented: $showInfo, attachmentAnchor: .point(.init(x: -2.2, y: 1.45))) {
                    PopoverView(showInfo: $showInfo)
                }
            }
            
            Spacer()
            
        }
        .onChange(of: filesURL) { oldValue, newValue in
            if !newValue.isEmpty {
                Task { await setMode(.generate) }
            }
        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ImportDicomView()
}
