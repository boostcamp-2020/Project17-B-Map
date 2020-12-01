//
//  UIImageView+URL.swift
//  BoostClusteringMaB
//
//  Created by 현기엽 on 2020/12/01.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

// https://stackoverflow.com/a/42017996
extension UIImageView {
    func loadImage(contentsOf urlString: String?, placeHolder: UIImage? = #imageLiteral(resourceName: "icon")) {
        self.image = placeHolder
        
        guard let urlString = urlString,
              let url = URL(string: urlString) else {
            return
        }

        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                debugPrint("\(urlString) data is nil!")
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                }
            }
        }).resume()
    }
}
