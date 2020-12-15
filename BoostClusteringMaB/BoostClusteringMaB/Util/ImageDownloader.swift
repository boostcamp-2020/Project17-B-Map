//
//  ImageDownloader.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/12/03.
//

import UIKit

enum ImageDownloadError: Error {
    case statusCodeInvalid(URLResponse?)
    case dataIsNil
    case dataIsInvalid
    case invalidURL
}

class ImageDownloader {
    static let shared = ImageDownloader()
    private init() {}
    private let imageCache = NSCache<NSString, UIImage>()
    
    func fetch(imageURL urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) -> URLSessionTask? {
        guard let url = URL(string: urlString) else {
            completion(.failure(ImageDownloadError.invalidURL))
            return nil
        }
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            completion(.success(cachedImage))
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    completion(.failure(ImageDownloadError.statusCodeInvalid(response)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(ImageDownloadError.dataIsNil))
                    return
                }
                
                if let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: urlString as NSString)
                    completion(.success(image))
                } else {
                    completion(.failure(ImageDownloadError.dataIsInvalid))
                }
            }
        }
        
        task.resume()
        return task
    }
}
