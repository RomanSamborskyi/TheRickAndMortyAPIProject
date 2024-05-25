//
//  CacheManager.swift
//  SomePrsctice
//
//  Created by Roman Samborskyi on 21.05.2024.
//

import UIKit


class CacheManager {
    
    static let instance: CacheManager = CacheManager()
    
    private init() {  }
    
    var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100
        cache.totalCostLimit = 200
        return cache
    }()
    
    func addToCache(_ image: UIImage, with key: String) {
        imageCache.setObject(image, forKey: key as NSString)
    }
    
    func getImageFromCahe(with key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
}
