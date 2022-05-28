//
//  RepoViewController.swift
//  SearchRepo
//
//  Created by Sumit Joshi on 2022/05/26.
//

import Foundation
import UIKit
import WebKit

class RepoViewController: UIViewController {
    
    @IBOutlet private weak var repoWebView: WKWebView!
    
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = url else { return }
        self.repoWebView.load(URLRequest(url: url))
    }
}
