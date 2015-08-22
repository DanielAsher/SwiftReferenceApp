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
        
        // saveButton triggers app[.Save]
        saveButton.rx_tap 
            >- subscribeNext { app[.Save] } 
            >- disposeBag.addDisposable
       
        // disable saveButton while appState[.Saving]
        app.appState 
            >- map { $0.isSaving() == false }
            >- debug("saveButton enabled")
            >- saveButton.rx_subscribeEnabledTo
            >- disposeBag.addDisposable    
                      
        // purchaseButton triggers app[.Purchase]
        purchaseButton.rx_tap 
            >- subscribeNext { app[.Purchase] } 
            >- disposeBag.addDisposable
      
        // Set statusLabel.text to "event -> appState"
        app.hsmTransitionState 
            >- subscribeNext { event, appState, userState in 
                self.statusLabel.text = "\(event.DOTLabel) -> \(appState.DOTLabel)" }
       
        // Set userStateLabel.text to "userState"
        app.userState 
            >- subscribeNext { userState in switch userState 
                { 
                case .Trial(let count): 
                    self.userStatusLabel.text = "\(userState.DOTLabel): \(count)" 
                default:                     
                    self.userStatusLabel.text = "\(userState.DOTLabel)" 
                }
            }
            >- disposeBag.addDisposable
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

