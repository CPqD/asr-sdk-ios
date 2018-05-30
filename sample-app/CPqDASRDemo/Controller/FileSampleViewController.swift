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

class FileSampleViewController: BaseViewController {
    
    let audioName = "hetero_segments_8k";
    
    var audioPath : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "File Audio Source"
        audioPath = Bundle.main.path(forResource: audioName, ofType: "wav");
        if audioPath != nil {
            audioSource = CPqDASRFileAudioSource(filePath: audioPath!)
        }        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recognize(_ sender: UIButton) {
        if audioPath == nil {
            self.stateLabel.text = "Invalid audio file";
            return
        }
        recognizer?.recognize(audioSource, languageModel: languageModelList, recogConfig: config)
    }
    
    
}
