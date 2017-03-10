//
//  VoiceRecorder.swift
//  SwiftAmrWaveConvertor
//
//  Created by zhenlintie on 2017/3/10.
//  Copyright © 2017年 sTeven. All rights reserved.
//

import UIKit
import AVFoundation

enum RecordSettingMode {
    
    case st8khz8Bit1c // 8000 Hz, 8 bit depth, 1 channel
    case st8khz8Bit2c //  8000 Hz, 8 bit depth, 2 channel
    case st8khz16Bit1c // 8000 Hz, 16 bit depth, 1 channel
    case st8khz16Bit2c // 8000 Hz, 16 bit depth, 2 channel
    
    case st16khz8Bit1c // 16000 Hz, 8 bit depth, 1 channel
    case st16khz8Bit2c //  16000 Hz, 8 bit depth, 2 channel
    case st16khz16Bit1c // 16000 Hz, 16 bit depth, 1 channel
    case st16khz16Bit2c // 16000 Hz, 16 bit depth, 2 channel
    
    var settings : [String : AnyObject] {
        switch self {
        case .st8khz8Bit1c:
            return generateSettings(sampleRate: 8000, bitDepth: 8, channelsNum: 1)
        case .st8khz8Bit2c:
            return generateSettings(sampleRate: 8000, bitDepth: 8, channelsNum: 2)
        case .st8khz16Bit1c:
            return generateSettings(sampleRate: 8000, bitDepth: 16, channelsNum: 1)
        case .st8khz16Bit2c:
            return generateSettings(sampleRate: 8000, bitDepth: 16, channelsNum: 2)
        case .st16khz8Bit1c:
            return generateSettings(sampleRate: 16000, bitDepth: 8, channelsNum: 1)
        case .st16khz8Bit2c:
            return generateSettings(sampleRate: 16000, bitDepth: 8, channelsNum: 2)
        case .st16khz16Bit1c:
            return generateSettings(sampleRate: 16000, bitDepth: 16, channelsNum: 1)
        case .st16khz16Bit2c:
            return generateSettings(sampleRate: 16000, bitDepth: 16, channelsNum: 2)
        }
    }
    
    private func generateSettings(sampleRate : UInt, bitDepth : UInt, channelsNum : UInt) -> [String : AnyObject] {
        return [AVFormatIDKey: NSNumber(value: kAudioFormatLinearPCM as UInt32),
                AVSampleRateKey: sampleRate as AnyObject,
                AVNumberOfChannelsKey: channelsNum as AnyObject,
                AVLinearPCMBitDepthKey: bitDepth as AnyObject,
                AVLinearPCMIsNonInterleaved: false as AnyObject,
                AVLinearPCMIsFloatKey: false as AnyObject,
                AVLinearPCMIsBigEndianKey: false as AnyObject]
    }
}

class VoiceRecorder: NSObject {
    
    fileprivate var tempDataPathUrl : URL!
    
    fileprivate var recorder : AVAudioRecorder!
    
    weak var recorderDelegate : VoiceRecorderDelegate?
    
    var settingMode = RecordSettingMode.st8khz16Bit1c
    
    override init() {
        
        // temporary recorded file path
        let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let folder = cachesPath + "/records"
        let tempPath = folder + "/temp.wav"
        let fm = FileManager.default
        if fm.fileExists(atPath: tempPath) {
            _ = try? fm.removeItem(atPath: tempPath)
        }
        else {
            _ = try? fm.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
        }
        
        tempDataPathUrl = URL(fileURLWithPath: tempPath)
        
        recorder = try? AVAudioRecorder(url: tempDataPathUrl, settings: settingMode.settings)
        
        // 播音相关
        
        super.init()
        
        recorder.delegate = self
    }
}

// 录音代理
protocol VoiceRecorderDelegate : NSObjectProtocol {
    func recordDidFinished(data : Data)
    func recordDidFailed()
}

extension VoiceRecorder : AVAudioRecorderDelegate {
    // public
    
    var onRecording : Bool {
        get {
            guard let _ = recorder else{ return false }
            return recorder!.isRecording
        }
    }
    
    var canUseMicrophone : Bool {
        get {
            return AVAudioSession.sharedInstance().recordPermission() != .denied
        }
    }
    
    func startRecord() {
        
        cancelRecord()
        
        guard prepareRecord() else {
            recorderDelegate?.recordDidFailed()
            return
        }
        
        guard AVAudioSession.sharedInstance().recordPermission() != .denied else {
            recorderDelegate?.recordDidFailed()
            return;
        }
//        recorder.isMeteringEnabled = true
        recorder.record()
    }
    
    func stopRecord() {
        stopRecordingIfNeed()
    }
    
    func cancelRecord() {
        stopRecordingIfNeed()
    }
    
    // MARK: - method
    
    fileprivate func stopRecordingIfNeed() {
        if recorder.isRecording {
            recorder.stop()
        }
    }
    
    fileprivate func prepareRecord() -> Bool {
        // recorder 是否准备好
        guard recorder.prepareToRecord() else {
            // prepareToRecord failed!
            return false
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        // 是否设置好 AVAudioSession
        guard let _ = try? audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord) else {
            
            return false
        }
        
        // active 是否设置成功
        guard let _ = try? audioSession.setActive(true) else {
            
            return false
        }
        
        guard let _ = try? audioSession.overrideOutputAudioPort(.speaker) else {
            
            return false
        }
        
        return true
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if flag {
            if let data = try? Data(contentsOf: tempDataPathUrl), data.count > 4096 {
                recorderDelegate?.recordDidFinished(data : data)
            }
            else {
                recorderDelegate?.recordDidFailed()
            }
        }
        
        recorder.deleteRecording()
    }
    
    /* if an error occurs while encoding it will be reported to the delegate. */
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?){
        recorderDelegate?.recordDidFailed()
    }
}
