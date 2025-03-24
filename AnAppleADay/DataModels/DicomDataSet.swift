//
//  DicomDataSet.swift
//  AnAppleADay
//
//  Created by Giuseppe Rocco on 24/03/25.
//

/// A representation of a locally cached DICOM dataset.
///
/// `DicomDataSet` is used to encapsulate metadata and file references for a
/// DICOM directory copied into the app's cache. It conforms to `Identifiable`,
/// `Hashable`, and `Codable`, making it easy to store, compare, and use in SwiftUI views.
struct DicomDataSet: Identifiable, Hashable, Codable {
    
    /// The base directory where all DICOM datasets are cached.
    ///
    /// This defaults to the user's caches directory. If unavailable, it falls back to the temporary directory.
    static let cacheDirectory: URL = {
        return FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
    }()
    
    /// Creates a new `DicomDataSet` by copying the contents of a source directory to the cache.
    ///
    /// This function:
    /// - Generates a new UUID for the dataset.
    /// - Copies the contents of the provided `originURL` directory to a new folder in the cache.
    /// - Enumerates the DICOM files in the copied directory to calculate `sliceCount`.
    ///
    /// Security-scoped access is automatically managed for the origin URL.
    ///
    /// - Parameter originURL: The URL of the original directory containing DICOM files.
    /// - Throws: An error if copying the directory or reading its contents fails.
    /// - Returns: A new `DicomDataSet` instance.
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
        
        let sliceCount = enumeratedFiles.filter {
            ($0.pathExtension == "dcm" || $0.pathExtension.isEmpty) &&
            $0.lastPathComponent != ".DS_Store"
        }.count
        
        return .init(id: newUUID, name: originURL.lastPathComponent, sliceCount: sliceCount)
    }
    
    /// Unique identifier for the dataset.
    let id: UUID
    
    /// A human-readable name for the dataset, typically the folder name of the original source.
    let name: String
    
    /// The number of DICOM slices detected in the dataset.
    let sliceCount: Int
    
    /// The full URL to the cached location of the dataset.
    var url: URL {
        Self.cacheDirectory.appendingPathComponent(id.uuidString)
    }
    
    /// Initializes a new `DicomDataSet` with its core properties.
    ///
    /// This initializer is private to enforce creation via `createNew`.
    ///
    /// - Parameters:
    ///   - id: The UUID assigned to this dataset.
    ///   - name: The name of the dataset.
    ///   - sliceCount: The number of DICOM slices it contains.
    private init(id: UUID, name: String, sliceCount: Int) {
        self.id = id
        self.name = name
        self.sliceCount = sliceCount
    }
}
