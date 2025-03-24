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
                   
                    showingFilePicker = true
                } label: {
                    HStack {
                        Text("Import DICOM dataset")
                        Image(systemName: "plus")
                    }
                    .frame(height: 55)
                }
                .fileImporter(
                    isPresented: $showingFilePicker,
                    allowedContentTypes: [UTType.folder],
                    allowsMultipleSelection: false,
                    onCompletion: handleFileImport
                )
                    
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info")
                }
                .buttonBorderShape(.circle)
                .popover(isPresented: $showInfo, attachmentAnchor: .point(.init(x: -3, y: 2))) {
                    InfoView(showInfo: $showInfo)
                        .background(Color("backgroundColor").opacity(0.3))
                }
            }
            
            Spacer()
            
        }
        .padding()
    }
    
    func handleFileImport(_ result: Result<[URL], any Error>) {
     
        guard let urls = try? result.get() else { return }
        
        if let directoryURL = urls.first,
           let cacheDirectory = FileManager.default.urls(
               for: .cachesDirectory,
               in: .userDomainMask
           ).first {
            
            do {
                
                try directoryURL.whileAccessingSecurityScopedResource {
                    
                    try FileManager.default.copyItem(
                        at: directoryURL,
                        to: cacheDirectory.appendingPathComponent(directoryURL.lastPathComponent)
                    )
                }
                
                Task { @MainActor in
                    await setMode(.generate, cacheDirectory.appendingPathComponent(directoryURL.lastPathComponent))
                }
                
            } catch { print(error) }
        }
    }
}
