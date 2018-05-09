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

class BufferSampleViewController: BaseViewController {


    let audioName = "pizza-veg-8k";
    
    var audioPath : String?    
    var inputStream : InputStream?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.title = "Buffer Audio Source"
        
        self.audioPath = Bundle.main.path(forResource: audioName, ofType: "wav");
        audioSource = CPqDASRBufferAudioSource();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioSource?.close();
    }
    
    @IBAction func recognize(_ sender: UIButton) {
        if audioPath == nil {
            self.stateLabel.text = "Invalid audio file";
            return
        }
        recognizer?.recognize(audioSource, languageModel: languageModelList, recogConfig: config)
    }
    
    func openStream() {
        
        guard let bufferAudioSource = self.audioSource as? CPqDASRBufferAudioSource else {
            return
        }
        
        let queue = DispatchQueue(label: "com.cpqd.readqueue");
        
        queue.async {
            self.inputStream = InputStream(fileAtPath: self.audioPath!);
            self.inputStream?.open()
            
            while (true) {
                if (self.inputStream!.hasBytesAvailable) {
                    let length = 1024
                    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: length);
                    let bufferSizeRead = self.inputStream?.read(buffer, maxLength: length)
                    if (bufferSizeRead != nil && bufferSizeRead! < 0) {
                        break;
                    } else {
                        let dt = Data(bytes: buffer, count: bufferSizeRead!)
                        bufferAudioSource.write(dt);
                        //delay sending the next segment to simulate real-time audio capture
                        Thread.sleep(forTimeInterval: 0.123)
                    }
                    buffer.deallocate()
                } else {
                    break;
                }
            }
            self.close()
        }
        
        self.resultTextView.text = ""
        
    }
    func close() {
        DispatchQueue.global().async {
            self.inputStream?.close();
            self.inputStream = nil;
            self.audioSource?.close()
        }
    }
}

extension BufferSampleViewController {
    override func cpqdASRDidStartListening() {
        super.cpqdASRDidStartListening()
        self.openStream();
    }
}


