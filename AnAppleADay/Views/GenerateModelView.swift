//
//  GenerateModelView.swift
//  AnAppleADay
//
//  Created by Alessandro Ricci on 28/02/25.
//

import SwiftUI

struct GenerateModelView: View {
    
    let directoryURL: URL
    
    @State var fileCounter: Int? = nil
    @State var directoryName: String = "Loading..."
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                
                Text("3D Model Generation")
                    .font(.system(size: 45, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            
                Text("A 3D model will be generated from your imported\nDICOM dataset")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 800)
                    .padding()
                
                VStack(spacing: 4) {
                    Image("dicomIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(directoryName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                    
                    if let count = fileCounter {
                        Text("\(count) slices")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.7))
                    }

                   
                }
                .padding(.top, 12)
                
                NavigationLink(destination: ProgressModelView()) {
                    Text("Generate Model")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        
                }
                .padding(.top, 32)
            }
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }.task {
            try? loadFileURLs()
        }
    }
    
    func loadFileURLs() throws {
        
        self.directoryName = directoryURL.lastPathComponent
        
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: nil)
        
        let filteredURLs = fileURLs.filter {
            ($0.pathExtension == "dcm" ||
             $0.pathExtension.isEmpty) &&
            $0.lastPathComponent != ".DS_Store"
            
        }
        self.fileCounter = filteredURLs.count
    }
    
}


