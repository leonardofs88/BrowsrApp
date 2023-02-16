//
//  ViewModel.swift
//  BrowsrApp
//
//  Created by Leonardo Soares on 15/02/23.
//

import Foundation
import BrowsrLib

class ViewModel {
    
    fileprivate var repository: LoaderProtocol
    fileprivate(set) var isLoading = false
    var items: [Organization]?
    var currentItens: [Organization]?
    
    init(repository: LoaderProtocol) {
        self.repository = repository
    }
    
    func loadData(pageIndex: Int? = nil, completion: @escaping (Error?) -> ()) {
        isLoading = true
        repository.loadData(pageIndex: pageIndex) { [weak self] result in
            switch result {
            case .success(let items):
                self?.items = items
                completion(nil)
            case .failure(let error):
                completion(error)
            }
            self?.isLoading = false
        }
    }
    
    func showFavorites(isShowing: Bool, completion: @escaping () -> ()) {
        let favoriteItems = items?.filter { $0.isFavorite == true }
        if isShowing {
            currentItens = items
            items = favoriteItems
        } else {
            items = currentItens
        }
        completion()
    }
    
    func search(for term: String?, completion: @escaping (Error?) -> ()) {
        isLoading = true
        repository.searchOrganization(searchTerm: term) { [weak self] result in
            switch result {
            case .success(let item):
                self?.items = item
                completion(nil)
            case .failure(let error):
                completion(error)
            }
            
            self?.isLoading = false
        }
    }
    
    func setFavorite(isFav: Bool, organization: String) {
        repository.setFavorite(isFav: isFav, organization: organization)
    }
}
