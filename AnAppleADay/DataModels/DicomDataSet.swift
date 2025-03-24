//
//  DicomDataSet.swift
//  AnAppleADay
//
//  Created by Giuseppe Rocco on 24/03/25.
//

struct DicomDataSet: Identifiable, Hashable, Codable {
    
    static let cacheDirectory: URL = {
        
        return FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
    }()
    
    static func createNew(originURL: URL) throws -> DicomDataSet {
        
        let newUUID: UUID = .init()
        let destinationURL: URL = Self.cacheDirectory.appendingPathComponent(newUUID.uuidString)
        
        var enumeratedFiles: [URL] = []
        
        try originURL.whileAccessingSecurityScopedResource {
            
            try FileManager.default.copyItem(at: originURL, to: destinationURL)
                            
            enumeratedFiles = try FileManager.default.contentsOfDirectory(
                at: destinationURL,
                includingPropertiesForKeys: nil
            )
        }
        
        let sliceCount = enumeratedFiles.filter { ($0.pathExtension == "dcm" ||
                                                   $0.pathExtension.isEmpty) &&
                                                   $0.lastPathComponent != ".DS_Store" }.count
        
        return .init(id: newUUID, name: originURL.lastPathComponent, sliceCount: sliceCount)
    }
    
    let id: UUID
    let name: String
    let sliceCount: Int
    
    var url: URL {
        Self.cacheDirectory.appendingPathComponent(id.uuidString)
    }
    
    private init(id: UUID, name: String, sliceCount: Int) {
        self.id = id
        self.name = name
        self.sliceCount = sliceCount
    }
}
