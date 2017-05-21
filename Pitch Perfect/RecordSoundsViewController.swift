//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Leo Espinal on 5/9/17.
//  Copyright © 2017 Espinal Designs, LLC. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    //IBOutlets allow for you to communication with a UI element from code
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    //Object used to manage the audio recording session
    var audioRecorder: AVAudioRecorder!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //disable the stopRecording button once the view loads
        stopRecordingButton.isEnabled = false
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
    
    // MARK: Audio Recorder Delegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("Failed to peform the segue. There was a problem with the recording.")
        }
        
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
        if isRecording {
            recordingLabel.text = "Recording in progress..."
            stopRecordingButton.isEnabled = true
            recordButton.isEnabled = false
        } else {
            recordingLabel.text = "Tap to Record"
            stopRecordingButton.isEnabled = false
            recordButton.isEnabled = true
        }
    }
    
}

