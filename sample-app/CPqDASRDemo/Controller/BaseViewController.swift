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

class BaseViewController: UIViewController {
    
    var recognizer : CPqDASRSpeechRecognizer?
    let wsURL = "wss://speech.cpqd.com.br/asr/ws/estevan/recognize/8k"    
    let username = "estevan";
    let password = "Thect195";
    let languageModelList = CPqDASRLanguageModelList();
    let beginRecordingSoundId = 1115
    let endRecordingSoundId = 1116
    var audioSource : CPqDASRAudioSource?
    
    let recognizerDelegateQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive);
    
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
        config.recognitionTimeoutSeconds = 10;
        config.recognitionTimeoutEnabled = true;
        
        var builder = CPqDASRSpeechRecognizerBuilder()
            .serverUrl(wsURL)
            .autoClose(true)
            .addRecognitionDelegate(self)
            .userName(username, password: password);
        builder = builder?.recognizerDelegateDispatchQueue(recognizerDelegateQueue)
        recognizer = builder?.build()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        recognizer?.close();
        self.recognizeButton.recordingState = .Idle;
    }
    
    
    func showFinalResult(result: CPqDASRRecognitionResult) {
        DispatchQueue.main.async {
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
    }
    
    func playSound(soundId: Int) {
        if let sound = SystemSoundID.init(exactly: NSNumber(integerLiteral: soundId)) {
            AudioServicesPlaySystemSound(sound);
        }
    }
}

extension BaseViewController : CPqDASRRecognitionDelegate {
    func cpqdASRDidStartListening() {
        DispatchQueue.main.async {
            self.recognizeButton.recordingState = .Recording
            self.stateLabel.text = "Listening"
        }
    }
    
    func cpqdASRDidStartSpeech(_ time: TimeInterval) {
        DispatchQueue.main.async {
            self.stateLabel.text = "Start of speech"
        }
    }
    
    func cpqdASRDidStopSpeech(_ time: TimeInterval) {
        DispatchQueue.main.async {
            self.stateLabel.text = "Speech stopped"
        }
    }
    
    func cpqdASRDidReturnPartialResult(_ result: CPqDASRRecognitionResult!) {
        showFinalResult(result: result)
        DispatchQueue.main.async {
            self.stateLabel.text = "Partial result"
        }
    }
    
    func cpqdASRDidReturnFinalResult(_ result: CPqDASRRecognitionResult!) {
        DispatchQueue.main.async {
            switch result.status {
            case .recognized:
                self.stateLabel.text = "Final result"
                self.showFinalResult(result: result);
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
            
            self.recognizeButton.recordingState = .Idle
        }
    }
    
    func cpqdASRDidFailWithError(_ error: CPqDASRRecognitionError!) {
        debugPrint("cpqdASRDidFailWithError fail with error \(error.message)")
        DispatchQueue.main.async {
            self.stateLabel.text = "Closed"
            self.recognizeButton.recordingState = .Idle
        }
    }
}

