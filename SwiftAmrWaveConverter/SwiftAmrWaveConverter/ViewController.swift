//
//  ViewController.swift
//  SwiftAmrWaveConverter
//
//  Created by zhenlintie on 2017/3/10.
//  Copyright © 2017年 sTeven. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, VoiceRecorderDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        VoiceRecorder.shared.settingMode = .st8khz16Bit2c
        VoiceRecorder.shared.recorderDelegate = self
    }

    var wavData : Data {
        return try! Data(contentsOf: Bundle.main.url(forResource: "example_16k16bit1channel", withExtension: ".wav")!)
    }
    
    var amrData : Data {
        return try! Data(contentsOf: Bundle.main.url(forResource: "example_amrnb", withExtension: ".amr")!)
    }
    
    var convertedAmrData : Data? {
        let documentRoot = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let path = documentRoot + "/converted_amr.amr"
        return try? Data(contentsOf: URL(fileURLWithPath: path))
    }
    
    var recordWavData : Data {
        let documentRoot = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let path = documentRoot + "/record.wav"
        return try! Data(contentsOf: URL(fileURLWithPath: path))
    }
    
    @IBAction func startRecord(_ sender: Any) {
        VoiceRecorder.shared.startRecord()
    }

    @IBAction func stopRecord(_ sender: Any) {
        VoiceRecorder.shared.stopRecord()
    }
    
    func recordDidFinished(data: Data) {
        data.save(useName: "record.wav")
    }
    
    func recordDidFailed() {
        print("recordDidFailed")
    }
    
    @IBAction func convertWaveToAmr(_ sender: Any) {
        // 16k Hz
//        if let amrData = convert16khzWaveToAmr(waveData: wavData) {
//            amrData.save(useName: "converted_amr.amr")
//        }
        
        // 8k Hz
        if let amrData = convert8khzWaveToAmr(waveData: recordWavData) {
            amrData.save(useName: "converted_amr.amr")
        }
    }
    
    @IBAction func convertAmrToWave(_ sender: Any) {
        if let wavData = convertAmrNBToWave(data: amrData) {
            wavData.save(useName: "d_amr.wav")
        }
    }
    
    @IBAction func ConvertAmrToWaveAndPlay(_ sender: Any) {
        var amr = convertedAmrData
        
//        amr = amrData
        
        // 16k Hz
//        if amr != nil, let wavData = convertAmrWBToWave(data: amr!) {
//            playAudio(data: wavData)
//        }
        
        // 8k Hz
        if amr != nil, let wavData = convertAmrNBToWave(data: amr!) {
            playAudio(data: wavData)
        }
    }
    
    @IBAction func stopPlay(_ sender: Any) {
        if player != nil, player!.isPlaying {
            player?.stop()
            player = nil
        }
    }
    
    
    fileprivate var player : AVAudioPlayer?
    
    func playAudio(data : Data) {
        
        if let audioPlayer = try? AVAudioPlayer(data: data) {
            self.player = audioPlayer
            
            player?.delegate = self
            player?.play()
        }
    }
    
    // MARK: - player delegate
    
    /* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
    }
    
    /* if an error occurs while decoding it will be reported to the delegate. */
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        self.player = nil
        print("play error : \(error)")
    }
}

extension Data {
    
    func save(useName name: String) {
        let documentRoot = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let path = documentRoot + "/\(name)"
        _ = try? write(to: URL(fileURLWithPath: path), options: .atomic)
        print("Data saved! - \(name)\n")
    }
}

