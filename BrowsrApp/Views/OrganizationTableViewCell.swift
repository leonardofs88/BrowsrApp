//
//  OrganizationTableViewCell.swift
//  BrowsrApp
//
//  Created by Leonardo Soares on 16/02/23.
//

import Foundation
import UIKit
import BrowsrLib

protocol FavoriteButtonProtocol: AnyObject {
    func setFavorite(isFav: Bool, organization: String)
}

class OrganizationTableViewCell: UITableViewCell {
    
    var viewModel: OrganizationTableViewCellModel?
    weak var delegate: FavoriteButtonProtocol?
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCell()
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
        descriptionLabel.text = nil
        avatarView.image = nil
    }
    
    func configureCell() {
        let isFav = viewModel?.getFavorite() ?? false
        titleLabel.text = viewModel?.getOrganizationName()
        descriptionLabel.text =  viewModel?.getOrganizationDescription()
        self.favoriteButton.imageView?.image = UIImage(systemName: "heart\(isFav ? ".fill" : "")")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.viewModel?.getOrganizationAvatarImage { data, error in
                if let imageData = data {
                    DispatchQueue.main.async {
                        self.avatarView.image = UIImage(data: imageData)
                    }
                } else {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func setFavorite(_ sender: UIButton) {
        guard let organization = viewModel?.getOrganizationName() else { return }
        let isFav = viewModel?.getFavorite() ?? false
        DispatchQueue.main.async { [weak self] in
            self?.favoriteButton.imageView?.image = UIImage(systemName: "heart\(isFav ? ".fill" : "")")
        }
        delegate?.setFavorite(isFav: isFav, organization: organization)
    }
}
