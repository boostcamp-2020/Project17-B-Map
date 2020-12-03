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
    
    func fetch(imageURL urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(ImageDownloadError.invalidURL))
            return
        }
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            completion(.success(cachedImage))
            return
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
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
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    completion(.success(image))
                } else {
                    completion(.failure(ImageDownloadError.dataIsInvalid))
                }
            }
        }).resume()
    }
}
