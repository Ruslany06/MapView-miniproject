//
//  BottomSheetViewController.swift
//  MapView - miniproject
//
//  Created by Ruslan Yelguldinov on 01.08.2024.
//

import UIKit

class BottomSheetViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        setupView()
    }
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    func setupView() {
        backView.layer.cornerRadius = 20
        backView.layer.masksToBounds = true
        backView.backgroundColor = .white
        
        backView.layer.shadowColor = UIColor.clear.cgColor
        backView.layer.shadowOffset = CGSize(width: 0, height: 0)
        backView.layer.shadowOpacity = 0
        backView.layer.shadowRadius = 0
        
        view.layer.shadowColor = UIColor.clear.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0
        view.layer.shadowRadius = 0
    }
    
}

