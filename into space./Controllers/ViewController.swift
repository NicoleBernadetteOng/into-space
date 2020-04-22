//
//  ViewController.swift
//  into space.
//
//  Created by Nicole Bernadette Ong on 21/4/20.
//  Copyright © 2020 Nicole Bernadette Ong. All rights reserved.
//

import UIKit
import Foundation
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var keepButton: UIButton!
    @IBOutlet weak var releaseButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    public var wordsArray = UserDefaults.standard.object(forKey: "wordsArray") as? [String] ?? []
    public var releaseCount = UserDefaults.standard.object(forKey: "releaseCounter") as? [String] ?? []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        self.textView.layer.borderWidth = 3.0
        self.textView.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor

        recordButton.isEnabled = false
    
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
               
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                   
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                   
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            
            @unknown default:
                print("fatal error")
            }
               
            OperationQueue.main.addOperation() {
                self.recordButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    // Hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // Tap on record
    @IBAction func recordTapped(_ sender: Any) {
        // "record" change to "stop"
        if recordButton.titleLabel?.text == "record" {
            recordButton.setTitle("stop", for: .normal)
            
            // speech to text
            // start recording
            startRecording()
            
        } else {
            recordButton.setTitle("record", for: .normal)
            
            // stop recording
            if audioEngine.isRunning {
                audioEngine.stop()
                recognitionRequest?.endAudio()
                recordButton.isEnabled = false
                recordButton.setTitle("record", for: .normal)
            }
        }
        
    }
    
    
    // MARK: - When the user taps on keep
    @IBAction func keepButtonTapped(_ sender: Any) {
        
        // if text is empty
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            // alert
            showEmptyAlert()
            
        } else {
            // Save to User Defaults
            wordsArray.append(textView.text)
            UserDefaults.standard.set(wordsArray, forKey: "wordsArray")
            
            self.performSegue(withIdentifier: "goHeart", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if text is empty
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            // alert
            showEmptyAlert()
            
        } else {
            if segue.identifier == "goHeart" {
                let heartVC = segue.destination as! HeartViewController
                heartVC.heartList = wordsArray
                heartVC.releaseCount = releaseCount
            }
            
            if segue.identifier == "goSpace" {
                let spaceVC = segue.destination as! SpaceViewController
                spaceVC.starList = releaseCount
            }
        }
    }

    
    
    // MARK: - When the user taps on release
    @IBAction func releaseButtonTapped(_ sender: Any) {
        // if text is empty
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showEmptyAlert()
            
        } else {
            // Save to User Defaults
            // Saving the image name to the array so that it can be used to set the imageView!
            releaseCount.append("star.png")
            UserDefaults.standard.set(releaseCount, forKey: "releaseCounter")
            
            self.performSegue(withIdentifier: "goSpace", sender: self)
        }
    }
    
    
    func showEmptyAlert() {
        let alertController = UIAlertController(title: "Oops!", message:
            "I know you're at a loss for words, I know it hurts, but gorl, let it out!", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Yas queen", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }

    // Delete UserDefaults wordsArray data
    @IBAction func resetButtonTapped(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "wordsArray")
    }
    
    
    // MARK: - Functions for speech to text
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }
    
    func transcribeAudio(url: URL) {
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)

        // start recognition!
        recognizer?.recognitionTask(with: request) { [unowned self] (result, error) in
            // abort if we didn't get any transcription back
            guard let result = result else {
                print("There was an error: \(error!)")
                return
            }

            // if we got the final transcription back, print it
            if result.isFinal {
                // retrieving the best transcription...
                print(result.bestTranscription.formattedString)
            }
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Hang on, I'm facing an existential crisis too.")
        }
        
        textView.text = "Spill the tea, I'm here for you!"
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
    
    
}


extension UIViewController {
    
    // MARK: - Dismiss Keyboard
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - Adjusting View with Keyboard
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}


