//
//  ViewController.swift
//  Clock Timer Dayhuff
//
//  Created by Noah Dayhuff on 7/1/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    //Outlets
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startStopTimer: UIButton!
    
    var timer: Timer?
    var countdownTimer: Timer?
    var remainingTime: TimeInterval = 0
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLiveClock()
        setupDatePicker()
        timerLabel.isHidden = true
    }

    func setupLiveClock() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateLiveClock), userInfo: nil, repeats: true)
    }

    @objc func updateLiveClock() {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss"
        clockLabel.text = formatter.string(from: Date())
        updateBackgroundImage()
    }
    
    func updateBackgroundImage() {
        let hour = Calendar.current.component(.hour, from: Date())
        let isDayTime = hour >= 6 && hour < 18
        view.backgroundColor = isDayTime ? UIColor.systemYellow : UIColor.systemBlue
    }
    
    func setupDatePicker() {
        datePicker.datePickerMode = .countDownTimer
    }
    
    @IBAction func startTimerTapped(_ sender: UIButton) {
        if audioPlayer?.isPlaying == true {
            stopMusic()
        } else if countdownTimer != nil {
            resetTimer()
        } else {
            startCountdown()
        }
    }
    
    func startCountdown() {
        remainingTime = datePicker.countDownDuration
        timerLabel.isHidden = false
        updateCountdownLabel()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        startStopTimer.setTitle("Stop Timer", for: .normal)
    }
    
    @objc func updateCountdown() {
        if remainingTime > 0 {
            remainingTime -= 1
            updateCountdownLabel()
        } else {
            countdownTimer?.invalidate()
            countdownTimer = nil
            startMusic()
        }
    }
    
    func updateCountdownLabel() {
        let hours = Int(remainingTime) / 3600
        let minutes = Int(remainingTime) % 3600 / 60
        let seconds = Int(remainingTime) % 60
        timerLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func startMusic() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            startStopTimer.setTitle("Stop Music", for: .normal)
        } catch {
            print("Error playing music")
        }
    }
    
    func stopMusic() {
        if audioPlayer?.isPlaying == true {
            audioPlayer?.stop()
            audioPlayer = nil
        }
        timerLabel.isHidden = true
        startStopTimer.setTitle("Start Timer", for: .normal)
    }
    
    func resetTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        remainingTime = 0
        updateCountdownLabel()
        timerLabel.isHidden = true
        startStopTimer.setTitle("Start Timer", for: .normal)
    }
}

