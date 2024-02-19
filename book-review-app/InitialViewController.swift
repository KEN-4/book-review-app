//
//  ViewController.swift
//  book-review-app
//
//  Created by 内藤広貴 on 2024/02/18.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //少し縮小するアニメーション
        UIView.animate(withDuration: 0.3,
                                   delay: 1.0,
                                   options: UIView.AnimationOptions.curveEaseOut,
                                   animations: { () in
            self.logoImage.transform = CGAffineTransformMakeScale(0.9, 0.9)
        }, completion: { (Bool) in
            
        })
        //拡大させて、消えるアニメーション
        UIView.animate(withDuration: 0.2,
                                   delay: 1.3,
                                   options: UIView.AnimationOptions.curveEaseOut,
                                   animations: { () in
                self.logoImage.transform = CGAffineTransformMakeScale(1.2, 1.2)
                self.logoImage.alpha = 0
            }, completion: { (Bool) in
                self.logoImage.removeFromSuperview()
        })
    }
}

