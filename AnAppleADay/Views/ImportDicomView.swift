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
                    .frame(width: 113, height: 113)
                Image("intrart").resizable()
                    .frame(width: 294, height: 67)
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
    
    /// Handles the result of the file import operation from the file picker.
    ///
    /// This function is triggered when the user selects a folder using the `.fileImporter` modifier.
    /// It attempts to create a `DicomDataSet` from the selected directory and transitions
    /// the app into the `.generate` mode by calling the injected `setMode` environment function.
    ///
    /// If an error occurs during dataset creation, it is stored in the `error` state variable
    /// and displayed through an alert in the UI.
    ///
    /// - Parameter result: The result of the file import, containing either a list of URLs or an error.
    func handleFileImport(_ result: Result<[URL], any Error>) {
        
        guard let urls = try? result.get(),
              let directoryURL = urls.first else { return }
        
        do {
            let dataSet = try DicomDataSet.createNew(originURL: directoryURL)
            
            Task { @MainActor in
                await setMode(.generate, dataSet)
            }
            
        } catch { self.error = error }
    }
}
