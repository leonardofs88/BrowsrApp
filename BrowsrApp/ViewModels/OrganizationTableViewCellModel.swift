//
//  OrganizationTableViewCellModel.swift
//  BrowsrApp
//
//  Created by Leonardo Soares on 16/02/23.
//

import Foundation
import BrowsrLib

class OrganizationTableViewCellModel {
    
    fileprivate let organization: Organization
    fileprivate weak var repository: LoaderProtocol?
    
    init(organization: Organization, repository: LoaderProtocol) {
        self.organization = organization
        self.repository = repository
    }
    
    func getOrganizationName() -> String? {
        organization.login
    }
    
    func getOrganizationDescription() -> String? {
        organization.description
    }
    
    func getFavorite() -> Bool {
        organization.isFavorite
    }
    
    func getOrganizationAvatarImage(completion: @escaping (Data?, Error?)-> ()) {
        guard let avatarUrl = organization.avatarUrl else { return }
        guard let url = URL(string: avatarUrl) else { return }
        repository?.getImage(from: url) { result in
            switch result {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
