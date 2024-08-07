//
//  APIManager.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import Foundation


final actor APIManager: ObservableObject {
    
    func download<T>(with url: URL, type: T.Type) async throws -> T? where T: Codable {
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 40
            
            let (data, respone) = try await URLSession.shared.data(for: request)
            let dataResponse = try sessionHandler(data: data, response: respone)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: dataResponse)
        } catch {
            throw AppError.errorOfDecoding(error)
        }
    }
    
    private func sessionHandler(data: Data?, response: URLResponse?) throws -> Data {
        guard let data = data,
              let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300 else {
            throw AppError.badResponse(status: response!)
        }
        return data
    }
}

