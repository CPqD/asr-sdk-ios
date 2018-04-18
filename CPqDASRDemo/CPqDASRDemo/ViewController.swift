//
//  ViewController.swift
//  CPqDASRDemo
//
//  Created by cpqd on 05/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

import UIKit
import CPqDASR

class ViewController: UIViewController {
    
    var recognizer : CPqDASRSpeechRecognizer?
    var audioSource: CPqDASRMicAudioSource?
    let wsURL = "ws://vmh123.cpqd.com.br:8025/asr-server/asr"
    
    let audioName = "hetero_segments_8k";
    let config = CPqDASRRecognitionConfig();
    
    
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var stateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.stateLabel.text = "Idle";
        
        config.continuousMode = NSNumber(value: false);
        config.maxSentences = NSNumber(value: 3);
        
        let builder = CPqDASRSpeechRecognizerBuilder()
                    .serverUrl(wsURL)
                    .autoClose(true)
                    .connect(onRecognize: true)
                    .recognitionDelegate(self)
        
        recognizer = builder?.build()
        audioSource = CPqDASRMicAudioSource(delegate: self, andSampleRate: .rate8K);
        audioSource?.setDetectEndOfSpeech(true)
        
    }
    
    func recognize() {
        self.resultTextView.text = ""
        
        let languageModelList = CPqDASRLanguageModelList();
        languageModelList.addURI("builtin:slm/general")
        
        recognizer?.recognize(audioSource, languageModel: languageModelList, recogConfig: config)
    }
    
    func recognizeFromFile() {
        
        if let audioPath = Bundle.main.path(forResource: audioName, ofType: "wav") {
            let aSource = CPqDASRFileAudioSource(filePath: audioPath);
            
            let languageModelList = CPqDASRLanguageModelList();
            languageModelList.addURI("builtin:slm/general")
            
            recognizer?.recognize(aSource, languageModel: languageModelList);
            
        }
        
    }
    
    @IBAction func tryToConnect(_ sender: UIButton) {
        self.recognize()
    }
    
    @IBAction func recogFromFile(_ sender: Any) {
        self.recognizeFromFile()
    }
    
}

extension ViewController : CPqDASRMicAudioSourceDelegate {
    func didFailWithError(_ error: Error!) {
        self.stateLabel.text = "ERROR \(error.localizedDescription)"
        debugPrint("CPqDASRMicAudioSourceDelegate fail with error \(error.localizedDescription)")
        
        //If there is an error with microphone configuration, cancel current recognition.
        
        self.recognizer?.cancelRecognition();
    }
}


extension ViewController : CPqDASRRecognitionDelegate {
    func cpqdASRDidStartListening() {
        self.stateLabel.text = "Listening"
        debugPrint("cpqdASRDidStartListening called")
    }
    
    func cpqdASRDidStartSpeech(_ time: TimeInterval) {
        self.stateLabel.text = "Start of speech"
        debugPrint("cpqdASRDidStartSpeech called")
    }
    
    func cpqdASRDidStopSpeech(_ time: TimeInterval) {
        self.stateLabel.text = "Speech stopped"
        debugPrint("cpqdASRDidStopSpeech called")
    }
    
    func cpqdASRDidReturnPartialResult(_ result: CPqDASRRecognitionResult!) {
        self.stateLabel.text = "Partial result"
        debugPrint("cpqdASRDidReturnPartialResult called")
    }
    
    func cpqdASRDidReturnFinalResult(_ result: CPqDASRRecognitionResult!) {
        switch result.status {
        case .recognized:
            debugPrint("Recognized")
            self.stateLabel.text = "Final result"
            if result.alternatives.count > 0 {
                let alternative = result.alternatives.first!
                print("alternative text: \(alternative.text) score: \(alternative.score)");
                self.resultTextView.text = alternative.text!
                if alternative.words.count > 0 {
                    let word = alternative.words.first!
                    debugPrint("\n words: \(word.text)")
                }
            }
        case .canceled:
            debugPrint("Recognition cancelled")
            self.stateLabel.text = "Recognition cancelled"
            
        case .earlySpeech:
            debugPrint("Early speech")
            self.stateLabel.text = "Early speech"
        case .failure:
            debugPrint("Failure")
            self.stateLabel.text = "Failure"
        case .maxSpeech:
            debugPrint("Max speech")
            self.stateLabel.text = "Max speech"
        case .noInputTimeout:
            debugPrint("No input timeout");
            self.stateLabel.text = "No input timeout"
        case .noMatch:
            debugPrint("No match")
            self.stateLabel.text = "No match"
        case .noSpeech:
            debugPrint("No speech")
            self.stateLabel.text = "No speech"
        case .processing:
            debugPrint("Processing")
            self.stateLabel.text = "Processing"
        case .recognitionTimeout:
            debugPrint("Recognition timeout")
            self.stateLabel.text = "Recognition timeout"
        }
    }
    
    func cpqdASRDidFailWithError(_ error: CPqDASRRecognitionError!) {
        debugPrint("cpqdASRDidFailWithError fail with error \(error.message)")
        self.stateLabel.text = "Closed"
    }
    

}
