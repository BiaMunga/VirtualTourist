//
//  AView.swift
//  SparedDebtApp
//
//  Created by Henry Mungalsingh on 25/08/2020.
//  Copyright © 2020 Spared. All rights reserved.
//

import Foundation
import UIKit

fileprivate var vSpinner: UIView?

extension UIViewController {
    
    func showSpinner(onView: UIView){
        let aView = UIView.init(frame: onView.bounds)
        aView.backgroundColor = .secondarySystemBackground
        
        
        let ai = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.startAnimating()
        
        DispatchQueue.main.async() {
        onView.addSubview(aView)
        aView.addSubview(ai)
            
                
        NSLayoutConstraint.activate([
            ai.centerXAnchor.constraint(equalTo: onView.centerXAnchor),
            ai.centerYAnchor.constraint(equalTo: onView.centerYAnchor)
        ])
        
        }
        
        vSpinner = aView
    }
    
    func removeSpinner(){
        DispatchQueue.main.async() {
        vSpinner?.removeFromSuperview()
        vSpinner = nil
        }
    }
}

