//
//  DetailCollectionViewCell.swift
//  BoostClusteringMaB
//
//  Created by 조정래 on 2020/12/01.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    // TODO : activity indicator 추가
    var imageURL: String?
    
    override func prepareForReuse() {
        storeImageView.image = UIImage(named: "icon")
    }

    func configure(poi: ManagedPOI) {
        nameLabel.text = poi.name
        categoryLabel.text = poi.category
        addressLabel.text = poi.address
        
        guard let imageURL = poi.imageURL else {
            return
        }
        
        ImageDownloader.shared.fetch(imageURL: imageURL) { result in
            guard let image = try? result.get() else {
                return
            }
            
            if imageURL == poi.imageURL {
                self.storeImageView.image = image
            }
        }
    }
}
