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

enum RecordingState {
    case Idle
    case Recording
}

class RecognizeButton: UIButton {

    public var recordingState : RecordingState {
        didSet {
            if recordingState == .Recording {
                self.isEnabled = false
                self.backgroundColor = UIColor.red
            } else {
                self.isEnabled = true
                self.backgroundColor = UIColor(red: 0, green: 150/255, blue: 136/255, alpha: 1.0);
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        recordingState = .Idle
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.frame.width / 2;
    }
    
}
