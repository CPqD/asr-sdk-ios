/*******************************************************************************
 * Copyright 2017 CPqD. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License.  You may obtain a copy
 * of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations under
 * the License.
 ******************************************************************************/

import UIKit
import CPqDASR
import AudioToolbox
import AVFoundation

class ViewController: UIViewController {
    
    var recognizer : CPqDASRSpeechRecognizer?
    var audioSource: CPqDASRMicAudioSource?
    let wsURL = "wss://speech.cpqd.com.br/asr/ws/estevan/recognize/8k"
    let username = "estevan";
    let password = "Thect195";
    let languageModelList = CPqDASRLanguageModelList();
    let beginRecordingSoundId = 1115
    let endRecordingSoundId = 1116
    
        
    @IBOutlet weak var recognizeButton: RecognizeButton!
    let config = CPqDASRRecognitionConfig();
    
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var stateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        languageModelList.addURI("builtin:slm/general")
        self.stateLabel.text = "Idle";
        
        config.continuousMode = NSNumber(value: false);
        config.maxSentences = NSNumber(value: 3);
        
        let builder = CPqDASRSpeechRecognizerBuilder()
            .serverUrl(wsURL)
            .autoClose(true)
            .connect(onRecognize: true)
            .recognitionDelegate(self)
            .userName(self.username, password: self.password)
        
        recognizer = builder?.build()
        audioSource = CPqDASRMicAudioSource(delegate: self, andSampleRate: .rate8K);
        audioSource?.setDetectEndOfSpeech(false)
    }
    
    
    func recognize() {
        
        self.resultTextView.text = ""
        recognizer?.recognize(audioSource, languageModel: languageModelList, recogConfig: config)
    }
    
    @IBAction func tryToConnect(_ sender: UIButton) {
        self.recognize()
    }
    
    func showFinalResult(result: CPqDASRRecognitionResult) {
        if result.alternatives.count > 0 {
            let alternative = result.alternatives.first!
            print("alternative text: \(alternative.text) score: \(alternative.score)");
            self.resultTextView.text = alternative.text!
            if alternative.words.count > 0 {
                let word = alternative.words.first!
                debugPrint("\n words: \(word.text)")
            }
        }
    }
    
    func playSound(soundId: Int) {
        if let sound = SystemSoundID.init(exactly: NSNumber(integerLiteral: soundId)) {
            AudioServicesPlaySystemSound(sound);
        }
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
        self.recognizeButton.recordingState = .Recording
        self.playSound(soundId: beginRecordingSoundId)
    }
    
    func cpqdASRDidStartSpeech(_ time: TimeInterval) {
        self.stateLabel.text = "Start of speech"
    }
    
    func cpqdASRDidStopSpeech(_ time: TimeInterval) {
        self.stateLabel.text = "Speech stopped"
    
    }
    
    func cpqdASRDidReturnPartialResult(_ result: CPqDASRRecognitionResult!) {
        self.stateLabel.text = "Partial result"
    }
    
    func cpqdASRDidReturnFinalResult(_ result: CPqDASRRecognitionResult!) {
        self.playSound(soundId: endRecordingSoundId)
        self.recognizeButton.recordingState = .Idle
        switch result.status {
            case .recognized:
                self.stateLabel.text = "Final result"
                showFinalResult(result: result);
            case .canceled:
                self.stateLabel.text = "Recognition cancelled"
            case .earlySpeech:
                self.stateLabel.text = "Early speech"
            case .failure:
                self.stateLabel.text = "Failure"
            case .maxSpeech:
                self.stateLabel.text = "Max speech"
            case .noInputTimeout:
                self.stateLabel.text = "No input timeout"
            case .noMatch:
                self.stateLabel.text = "No match"
            case .noSpeech:
                self.stateLabel.text = "No speech"
            case .processing:
                self.stateLabel.text = "Processing"
            case .recognitionTimeout:
                self.stateLabel.text = "Recognition timeout"
        }
    }
    
    func cpqdASRDidFailWithError(_ error: CPqDASRRecognitionError!) {
        self.recognizeButton.recordingState = .Idle
        debugPrint("cpqdASRDidFailWithError fail with error \(error.message)")
        self.stateLabel.text = "Closed"
    }
}
