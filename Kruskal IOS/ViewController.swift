//
//  ViewController.swift
//  Kruskal IOS
//
//  Created by Potari Gabor on 2016. 12. 04..
//  Copyright © 2016. Potari Gabor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startButtonClicked(_ sender: Any) {
        let kruskalMapVC = UIStoryboard(name: "KruskalMap", bundle: nil).instantiateInitialViewController()!
        self.navigationController?.pushViewController(kruskalMapVC, animated: true)
    }

}

