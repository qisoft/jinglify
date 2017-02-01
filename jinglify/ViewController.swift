//
//  ViewController.swift
//  jinglify
//
//  Created by Innokentiy Shushpanov on 01/02/2017.
//  Copyright © 2017 Innokentiy Shushpanov. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import AVKit

class ViewController: UIViewController, MPMediaPickerControllerDelegate {

    @IBOutlet weak var chooseButton: UIButton!
    var song : MPMediaItem?
    var player : MPMusicPlayerController?
    var beepPlayer : AVAudioPlayer?
    var shortBeepPlayer : AVAudioPlayer?
    var matchTime = 5 as Double;
    var matchTimeLeft: Double = 0.0
    var totalMatchTime: Double = 0.0
    var beepTime = 0
    var isGameStarted = false
    var initialVolume : Float = 0.0
    var masterVolumeSlider  : MPVolumeView?
    @IBOutlet weak var matchTimeLabel: UILabel!
    @IBOutlet weak var gameView: UIView!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = MPMusicPlayerController.applicationMusicPlayer()
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        }
        catch{
            
        }
        if let url = Bundle.main.url(forResource: "beep-01a", withExtension: "wav"){
            do {
                try beepPlayer = AVAudioPlayer(contentsOf: url)
            }
            catch {
                
            }
        }
        if let url = Bundle.main.url(forResource: "beep-02", withExtension: "wav"){
            do {
                try shortBeepPlayer = AVAudioPlayer(contentsOf: url)
            }
            catch {
                
            }
        }
        gameView.isHidden = true
        startButton.isEnabled = false
        masterVolumeSlider = MPVolumeView()
        masterVolumeSlider!.alpha = 0.01
        self.view.addSubview(masterVolumeSlider!)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func onThrowTap(_ sender: Any) {
        player?.pause()
        Timer.scheduledTimer(withTimeInterval: TimeInterval(getRandomBeepTime()), repeats: false) { (timer) in
            self.beepPlayer?.play()
            self.player?.play()
        }
    }
    
    
    @IBAction func onStopGameTap(_ sender: Any) {
        stopGame()
    }

    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true)
        if(mediaItemCollection.count > 0)
        {
            song = mediaItemCollection.items[0]
            player!.setQueue(with: mediaItemCollection)
            player!.nowPlayingItem = song
            player!.prepareToPlay()
            startButton.isEnabled = true
            startButton.backgroundColor = UIColor.init(red: 52 / 255, green: 94 / 255, blue: 242 / 255, alpha: 1.0)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true)
    }
    
    
    @IBAction func onChooseButtonTap(_ sender: Any) {
        let controller = MPMediaPickerController(mediaTypes: MPMediaType.music)
        controller.delegate = self
        controller.allowsPickingMultipleItems = false
        self.present(controller, animated: true)
    }

    @IBAction func matchTimeChanged(_ sender: Any) {
        matchTime = (sender as! UIStepper).value
        matchTimeLabel.text = "\(Int(matchTime)) min"
    }
    
    func getRandomBeepTime() -> Int {
        let random = arc4random_uniform(2) + 3
        return Int(random)
    }
    
    @IBAction func onStartTap(_ sender: Any) {
        startGame()
    }
    
    func update(timeLeft: Double, timeSpent: Double){
        print("time spent: \(timeSpent), time left: \(timeLeft)")
        if(timeSpent == 0){
            player!.play()
        }
        
        if(timeSpent == 25)
        {
            fadeOutAndStopPlayer()
        }
        
        if(timeSpent == 30+Double(beepTime)){
            beepPlayer?.play()
        }
        
        if(timeLeft < matchTime * 60 && timeLeft > 0 && timeLeft.truncatingRemainder(dividingBy: 60.0) == 0 ){
            beep(times: Int(timeLeft.divided(by: 60)))
        }
        
        if(timeLeft == 30){
            player!.play()
        }
        
        if(timeLeft == 7){
            fadeOutAndStopPlayer()
        }
        
        if(timeLeft == 0){
            beepPlayer?.play()
            stopGame()
        }
        
        if(timeLeft <= matchTime * 60){
            timeLeftLabel.text = stringFromTimeInterval(interval: timeLeft)
        }
        else if (timeSpent <= 30){
            timeLeftLabel.text = "Warm-up!"
        }
        else{
            timeLeftLabel.text = "Get Ready!"
        }
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func fadeOutAndStopPlayer(){
        if let view = self.masterVolumeSlider?.subviews.last as? UISlider{
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in
                if(self.initialVolume == 0){
                    self.initialVolume = view.value
                }
                view.value = view.value - self.initialVolume.divided(by: 10)
                print(view.value)
                view.sendActions(for: UIControlEvents.touchUpInside)
                if(view.value == 0){
                    self.player?.stop()
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
                        view.value = self.initialVolume
                        self.initialVolume = 0
                    })
                    timer.invalidate()
                }
            })
        }

    }
    
    func startGame(){
        gameView.isHidden = false
        beepTime = getRandomBeepTime()
        totalMatchTime = matchTime * 60 + 30 + Double(beepTime)
        matchTimeLeft = totalMatchTime
        isGameStarted = true
        self.update(timeLeft: totalMatchTime, timeSpent: 0)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if(!self.isGameStarted){
                timer.invalidate()
                return
            }
            self.matchTimeLeft = self.matchTimeLeft - 1
            self.update(timeLeft: self.matchTimeLeft, timeSpent: self.totalMatchTime - self.matchTimeLeft)
        }

    }
    
    func beep(times: Int){
        var beepsLeft = times
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { (timer) in
            beepsLeft = beepsLeft - 1
            self.shortBeepPlayer?.play()
            if(beepsLeft == 0){
                timer.invalidate()
            }
        }
    }
    
    func stopGame(){
        gameView.isHidden = true
        isGameStarted = false
        player?.stop()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

