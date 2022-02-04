//
//  PanelViewController.swift
//  PortfolioStocksApp
//
//  Created by Otakenne on 26/01/2022.
//

import UIKit

class PanelViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .secondarySystemBackground

        let grabberView = UIView()
        grabberView.frame = CGRect(x: 0, y: 0, width: 100, height: 6)
        grabberView.center = CGPoint(x: view.center.x, y: 0)
        grabberView.backgroundColor = .label
        view.addSubview(grabberView)
    }
}
