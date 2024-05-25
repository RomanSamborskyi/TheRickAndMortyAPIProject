//
//  ImageDownloader.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import UIKit

@MainActor
final class ImageDownloader: ObservableObject {
    
    @Published var poster: UIImage? = nil
    @Published var isLoading: Bool = false
    
    let cache: CacheManager = CacheManager.instance
    let imageURL: String?
    let imageID: String?
    
    init(imageURL: String?, imageID: String?) {
        self.imageURL = imageURL
        self.imageID = imageID
        getImage()
    }
    
    func getImage() {
        Task {
            if let image = cache.getImageFromCahe(with: imageID ?? "no id") {
                    self.poster = image
            } else {
                try await downloadImage()
            }
        }
    }
    
    private func downloadImage() async throws {
        
        guard let url = URL(string: imageURL!) else {
            throw URLError(.badURL)
        }
        
        do {
            self.isLoading = true
            let (data, response) = try await URLSession.shared.data(from: url)
            if let data = try sessionHandler(data: data, response: response) {
                guard let image = UIImage(data: data) else { throw URLError(.cannotDecodeRawData) }
                    self.poster = image
                    self.isLoading = false
                    self.cache.addToCache(image, with: imageID ?? "NO ID")
            }
        } catch {
            throw URLError(.timedOut)
        }
    }
    
    private func sessionHandler(data: Data?, response: URLResponse?) throws -> Data? {
        guard let data = data,
              let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
