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
    @State private var error: Error? = nil
    
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
        .alert("Error", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: { Text(error?.localizedDescription ?? "Unavailable error description") }
    }
    
    func handleFileImport(_ result: Result<[URL], any Error>) {
     
        guard let urls = try? result.get() else { return }
        
        if let directoryURL = urls.first {
            
            do {
                let dataSet = try DicomDataSet.createNew(originURL: directoryURL)
                
                Task { @MainActor in
                    await setMode(.generate, dataSet)
                }
                
            } catch { self.error = error }
        }
    }
}
