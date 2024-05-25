//
//  ErrorHandling.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import UIKit



enum AppError: Error, LocalizedError {
    case noInternet, badURL, badResponse(status:Int), errorOfDecoding(Error)
    
    var errorDescription: String? {
        switch self {
        case .noInternet:
            "No internet connection"
        case .badURL:
            "Bad url"
        case .badResponse(_):
            "Bad response"
        case .errorOfDecoding(let error):
            "Error of decoding data: \(error)"
        }
    }
    
    var messageText: String? {
        switch self {
        case .noInternet:
            "Please check your internet connection and try again"
        case .badURL:
            nil
        case .badResponse(let status):
            "Status code: \(status)"
        case .errorOfDecoding:
            nil
        }
    }
}
