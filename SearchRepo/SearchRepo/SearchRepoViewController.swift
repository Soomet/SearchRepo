//
//  SearchRepoViewController.swift
//  SearchRepo
//
//  Created by Sumit Joshi on 2022/05/26.
//

import UIKit

class SearchRepoViewController: UIViewController {
    
    @IBOutlet weak var repoSearchBar: UISearchBar!
    @IBOutlet weak var repoTableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var repositories: [Repository] = [] {
        didSet {
            self.repoTableView.reloadData()
        }
    }
    var timer: Timer?
    
    // Set the request throttle to 0.5 seconds
    let throttleTime = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.indicator.isHidden = true
    }
}

extension SearchRepoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "repoInfoCell")
        cell.textLabel?.text = repositories[indexPath.row].fullName
        if let language = repositories[indexPath.row].language {
            cell.detailTextLabel?.text = language
        }
        return cell
    }
}

extension SearchRepoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected!")
        tableView.deselectRow(at: indexPath, animated: true)
        guard let storyBoard = self.storyboard else { return }
        let vc = storyBoard.instantiateViewController(withIdentifier: "RepoViewController") as! RepoViewController
        vc.url = repositories[indexPath.row].htmlUrl
        vc.title = repositories[indexPath.row].fullName
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchRepoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: throttleTime, target: self, selector: #selector(self.startSearch), userInfo: nil, repeats: false)
    }
    
    @objc func startSearch() {
        self.repositories.removeAll()
        guard let query = self.repoSearchBar.text else { return }
        var spaceFreeQuery = query
        spaceFreeQuery = query.replacingOccurrences(of: " ", with: "")
        if spaceFreeQuery == "" { return }
        self.indicator.startAnimating()
        
        SearchRepo(query: spaceFreeQuery).request { (result) in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.repositories.append(contentsOf: response.items)
                    self.indicator.stopAnimating()
                }
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                self.present(alert, animated: true)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

