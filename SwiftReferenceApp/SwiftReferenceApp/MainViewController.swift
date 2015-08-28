//
//  ViewController.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.


import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController 
{
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var userStatusLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var purchaseButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dispose = disposeBag.addDisposable 
        
        // saveButton triggers app <- .Save
        saveButton.rx_tap 
            >- subscribeNext { app <- .Save } 
            >- disposeBag.addDisposable
       
        // disable saveButton while appState = .Saving
        app.appState 
            >- map { $0.isSaving() == false }
            >- saveButton.rx_subscribeEnabledTo >- dispose    
                      
        // purchaseButton triggers app <- .Purchase
        purchaseButton.rx_tap 
            >- subscribeNext { app <- .Purchase } >- dispose
      
        // Set statusLabel.text to transition's description
        app.transition >- subscribeNext { self.statusLabel.text = $0.description }
        
        // Set userStateLabel.text to "userState"
        app.userState 
            >- subscribeNext { userState in self.userStatusLabel.text = "\(userState.DOTLabel)" } >- dispose    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

