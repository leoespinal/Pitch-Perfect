//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Leo Espinal on 5/9/17.
//  Copyright © 2017 Espinal Designs, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {
    //IBOutlets allow for you to communication with a UI element from code
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    //Object used to manage the audio recording session
    var audioRecorder: AVAudioRecorder!

    override func viewDidLoad() {
        super.viewDidLoad()
        //disable the stopRecording button once the view loads
        stopRecordingButton.isEnabled = false
        //Set buttons's image view content mode to aspect fit
        recordButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        stopRecordingButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }


    //Target = The view controller
    //Action = IBAction function for the record button
    //IBActions allow for a UI element to communicate with the code
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        configureUI(isRecording: true)
        
        //Sets directory path to current application's directory
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        //File name for audio recording
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        //Joins directory path and file name to create file path for recording file
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        //Starts an AV session on hardware
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
        
        //Inits audio recorder, creates audio file, and starts the audio recording session
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        //Sets this class to be the delegate for the
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: UIButton) {
        configureUI(isRecording: false)
        
        //Stop the audio recording session
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            //Set the destination VC
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            //Set the recorded audio URL to be the URL coming in from the sender which is the performSegue function's parameter "audioRecorder.url"
            let recordedAudioURL = sender as! URL
            //Set the recordedAudioURL property in the PlaySoundsViewController. This is how the recording is being sent to the PlaySoundsVC.
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    // MARK: Configure UI
    func configureUI(isRecording: Bool) {
        let settings = isRecording ? ("Recording in progress", true, false) : ("Tap to Record", false, true)
        recordingLabel.text = settings.0
        stopRecordingButton.isEnabled = settings.1
        recordButton.isEnabled = settings.2
    }
    
}

// MARK: Audio Recorder Delegate extension
extension RecordSoundsViewController : AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            //Create alert and alert action that user can perform
            let alert = UIAlertController(title: "Segue Failure", message: "Failed to peform the segue! There was a problem with the recording!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(action)
            //Present the alert to the user
            present(alert, animated: true, completion: nil)
        }
        
    }
}

