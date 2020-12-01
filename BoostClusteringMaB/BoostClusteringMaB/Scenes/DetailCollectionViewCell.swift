//
//  DetailCollectionViewCell.swift
//  BoostClusteringMaB
//
//  Created by 조정래 on 2020/12/01.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var storeImageView: UIImageView!

    override func prepareForReuse() {
        storeImageView.image = UIImage(named: "icon")
    }
    
    func configure(object: ManagedPOI) {        
        nameLabel.text = object.name
        categoryLabel.text = object.category
        
        guard let imageURL = object.imageURL else { return }

        DispatchQueue.main.async {
            self.storeImageView.image = UIImage.load(imageURL: imageURL)
        }
    }
    
}
