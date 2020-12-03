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
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: storeImageView.frame)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        indicator.style = .large
        contentView.addSubview(indicator)
        return indicator
    }()
    
    private weak var task: URLSessionTask?
    
    override func prepareForReuse() {
        storeImageView.image = UIImage(named: "icon")
        activityIndicator.startAnimating()
        task?.cancel()
    }

    func configure(poi: ManagedPOI) {
        nameLabel.text = poi.name
        categoryLabel.text = poi.category
        addressLabel.text = poi.address
        
        guard let imageURL = poi.imageURL else {
            self.activityIndicator.stopAnimating()
            return
        }
        
        task = ImageDownloader.shared.fetch(imageURL: imageURL) { result in
            self.activityIndicator.stopAnimating()
            guard let image = try? result.get() else {
                return
            }
            
            self.storeImageView.image = image
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCell()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }
    
    func configureCell() {
        layer.borderWidth = 1
        layer.cornerRadius = 10
    }
}
