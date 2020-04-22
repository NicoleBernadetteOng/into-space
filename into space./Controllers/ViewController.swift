//
//  ViewController.swift
//  into space.
//
//  Created by Nicole Bernadette Ong on 21/4/20.
//  Copyright © 2020 Nicole Bernadette Ong. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var keepButton: UIButton!
    @IBOutlet weak var releaseButton: UIButton!

    public var wordsArray = UserDefaults.standard.object(forKey: "wordsArray") as? [String] ?? []
    public var releaseCount = UserDefaults.standard.object(forKey: "releaseCounter") as? Int
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    // Hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    
    
    // When the user taps on keep
    
    @IBAction func keepButtonTapped(_ sender: Any) {
        
        // if text is empty
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            // alert
            showEmptyAlert()
            
        } else {
            // Save to User Defaults
            wordsArray.append(textView.text)
            UserDefaults.standard.set(wordsArray, forKey: "wordsArray")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // if text is empty
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            // alert
            showEmptyAlert()
            
        } else {
            if segue.identifier == "goHeart" {
                print(wordsArray)
                
                let heartVC = segue.destination as! HeartViewController
                heartVC.heartList = wordsArray
            }
            
            if segue.identifier == "goSpace" {
                print("releaseCount: \(String(describing: releaseCount))")
                
                let spaceVC = segue.destination as! SpaceViewController
                spaceVC.starCount = releaseCount ?? 1
            }
        }
    }

    
    
    // When the user taps on release
    // need to count the number of times the user has released a message
    @IBAction func releaseButtonTapped(_ sender: Any) {
        let releaseCountNum = (releaseCount ?? 0) + 1
        UserDefaults.standard.set(releaseCountNum, forKey: "releaseCounter")
    }
    
    
    func showEmptyAlert() {
        let alertController = UIAlertController(title: "Oops!", message:
            "I know you're at a loss for words, I know it hurts, but gorl, let it out!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yas queen", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }

    
    // Delete all data
    @IBAction func resetButtonTapped(_ sender: Any) {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
    

}


extension UIViewController {
    
    // =============== DISMISS KEYBOARD ===============
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}


