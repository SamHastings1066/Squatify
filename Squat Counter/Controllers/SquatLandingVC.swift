//
//  SquatLandingVC.swift
//  Squat Counter
//
//  Created by sam hastings on 27/07/2023.
//

import UIKit

class SquatLandingVC: UIViewController {

    //MARK: - IBActions
    
    @IBAction func didTapStartSquatting(_ sender: UIButton) {
        self.hidesBottomBarWhenPushed = true
//        self.navigationItem.hidesBackButton = true
        performSegue(withIdentifier: "SquatSegue", sender: self)
        self.hidesBottomBarWhenPushed = false

    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    

}
