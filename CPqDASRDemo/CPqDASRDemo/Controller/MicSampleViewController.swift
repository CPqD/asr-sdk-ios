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

class MicSampleViewController: BaseViewController {

    let captureSampleRate : CPqDASRSampleRate = .rate8K;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Microphone Audio Source"
        
        audioSource = CPqDASRMicAudioSource(delegate: self, andSampleRate: captureSampleRate);
        
        if let ad = audioSource as? CPqDASRMicAudioSource {
            ad.setDetectEndOfSpeech(false)
        }
    }
    
    
    func recognize() {        
        self.resultTextView.text = ""
        recognizer?.recognize(audioSource, languageModel: languageModelList, recogConfig: config)
    }
    
    @IBAction func tryToConnect(_ sender: UIButton) {
        self.recognize()
    }
    
}

extension MicSampleViewController : CPqDASRMicAudioSourceDelegate {
    func didFailWithError(_ error: Error!) {
        self.stateLabel.text = "ERROR \(error.localizedDescription)"
        debugPrint("CPqDASRMicAudioSourceDelegate fail with error \(error.localizedDescription)")
        //If there is an error with microphone configuration, cancel current recognition.
        self.recognizer?.cancelRecognition();
    }
}
