//
//  PopVC.swift
//  be-in-city
//
//  Created by sHiKoOo on 2/20/19.
//  Copyright © 2019 sHiKoOo. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImage: UIImageView!
    
    var passedImaged: UIImage!
    
    func initData(forImage image: UIImage) {    // to get image from collectionView when select an item
        self.passedImaged = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImage.image = passedImaged
        doubleTap()
    }
    
    func doubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    @objc func screenDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }



}
