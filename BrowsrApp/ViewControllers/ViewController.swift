//
//  ViewController.swift
//  BrowsrApp
//
//  Created by Leonardo Soares on 15/02/23.
//

import UIKit
import BrowsrLib

class ViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var showFavoritesButton: UIButton!
    fileprivate var currentIndex = 10
    fileprivate var isShowingFavorites = false
    
    fileprivate var viewModel: ViewModel?
    lazy var repository = LoaderRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        viewModel = ViewModel(repository: repository)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "OrganizationTableViewCell", bundle: nil), forCellReuseIdentifier: "OrganizationTableViewCell")
        searchTextField.delegate = self
        loadData()
        setUpSearchBar()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setUpSearchBar() {
        searchTextField.layer.cornerRadius = 9
        searchTextField.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        searchTextField.font = UIFont.systemFont(ofSize: 18)
        searchTextField.textColor = .white
        searchTextField.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.07)
        searchTextField.clipsToBounds = true
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search for Organization",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
    }
    
    
    func loadData() {
        viewModel?.loadData(pageIndex: currentIndex) { [weak self] responseError in
            if let error = responseError {
                self?.showError(error: error)
            } else {
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func showError(error: Error) {
        let alert = UIAlertController(title: "An error has occurred", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func toggleFavorites(_ sender: UIButton) {
        isShowingFavorites = !isShowingFavorites
        viewModel?.showFavorites(isShowing: isShowingFavorites) { [weak self] in
            self?.showFavoritesButton.setTitle(self?.isShowingFavorites ?? false
                                               ? "Hide Favorites" : "Favorites", for: .normal)
            self?.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let itensCount = viewModel?.items?.count,
           let isLoading = viewModel?.isLoading,
           itensCount > 5,
           indexPath.row == itensCount - 2,
           !isLoading {
            currentIndex += 10
            loadData()
        }
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizationTableViewCell") as? OrganizationTableViewCell {
            if let organization = viewModel?.items?[indexPath.row] {
                cell.viewModel = OrganizationTableViewCellModel(organization: organization, repository: repository)
                cell.delegate = self
                return cell
            } else {
                return UITableViewCell()
            }
        }
        
        return UITableViewCell()
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            viewModel?.search(for: text) { [weak self] responseError in
                if let error = responseError {
                    self?.showError(error: error)
                } else {
                    DispatchQueue.main.async {
                        self?.currentIndex = 0
                        self?.tableView.reloadData()
                    }
                }
            }
        } else {
            self.loadData()
        }
        return true
    }
}

extension ViewController: FavoriteButtonProtocol {
    func setFavorite(isFav: Bool, organization: String) {
        viewModel?.setFavorite(isFav: isFav, organization: organization)
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}
