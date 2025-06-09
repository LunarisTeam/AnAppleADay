//
//  ImportDicomViews.swift
//  AnAppleADay
//
//  Created by Davide Castaldi on 25/02/25.
//

import SwiftUI
import UniformTypeIdentifiers

/// A SwiftUI view that allows users to import a DICOM dataset.
///
/// This view displays a logo and app title along with two main actions:
/// - Import a DICOM dataset from a folder using a file picker.
/// - Display a popover with the same content  as the initial onboarding
/// If an error occurs during import, an alert is shown.
struct ImportDicomView: View {
    
    /// The environment function used to transition between modes.
    @Environment(\.setMode) private var setMode
    
    /// State variable controlling the presentation of the file picker.
    @State private var showingFilePicker = false
    
    /// State variable controlling the presentation of the info popover.
    @State private var showInfo = false
    
    /// Stores any errors encountered during the file import process.
    @State private var error: Error? = nil
    
    var body: some View {
        VStack {
            Spacer()
            
            // MARK: Logo and Title
            VStack(spacing: 50) {
                Image("Logo")
                    .resizable()
                    .frame(width: 113, height: 113)
                Image("intrart")
                    .resizable()
                    .frame(width: 294, height: 67)
            }
            Spacer()
            
            // MARK: Buttons for Import and Info
            HStack(spacing: 15) {
                // Button to import DICOM dataset via file picker.
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
                
                // Button to display additional import information.
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info")
                }
                .buttonBorderShape(.circle)
                .popover(isPresented: $showInfo, attachmentAnchor: .point(.init(x: -2.5, y: 3))) {
                    InfoView(showInfo: $showInfo)
                        .background(Color("backgroundColor").opacity(0.3))
                }
            }
            
            Spacer()
        }
        .padding()
        .alert("Error", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error?.localizedDescription ?? "Unavailable error description")
        }
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
        } catch {
            self.error = error
        }
    }
}
