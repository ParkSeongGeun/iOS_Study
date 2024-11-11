//
//  ViewController.swift
//  VoiceToTextApp
//
//  Created by 박성근 on 11/11/24.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController {
  
  @IBOutlet weak var timeText: UILabel!
  @IBOutlet weak var btnStartOrStop: UIButton!
  @IBOutlet weak var btnRefresh: UIButton!
  @IBOutlet weak var btnMoveToNext: UIButton!
  
  // 음성 인식을 위한 SFSpeechRecognizer
  let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ko-KR"))
  
  var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
  var recognitionTask: SFSpeechRecognitionTask?
  var audioRecorder: AVAudioRecorder?
  
  private let audioEngine = AVAudioEngine()
  private var recognizedText: String = ""
  
  // 타이머
  private var timer: Timer?
  private var minuteAndSeconds: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    
    Task {
      await setupSpeech()
    }
  }
}

// MARK: - About Settings
private extension ViewController {
  private func setupUI() {
    btnStartOrStop.setTitle("Start", for: .normal)
    btnMoveToNext.isEnabled = false
    timeText.text = "00:00"
    minuteAndSeconds = 0
  }
  
  @MainActor
  private func setupSpeech() async {
    btnStartOrStop.isEnabled = false
    speechRecognizer?.delegate = self
    
    // 클로저 기반 API를 async/await로 래핑
    let authStatus = await withCheckedContinuation { continuation in
      SFSpeechRecognizer.requestAuthorization { status in
        continuation.resume(returning: status)
      }
    }
    
    switch authStatus {
    case .authorized:
      btnStartOrStop.isEnabled = true
    case .denied, .restricted, .notDetermined:
      btnStartOrStop.isEnabled = false
      print("Failed to access Speech recognition")
    @unknown default:
      fatalError()
    }
  }
}

// MARK: - Action Mehotds
extension ViewController {
  @IBAction func btnMoveToNextDidTap(_ sender: Any) {
    // 다음 화면 넘어가기 -> print로 우선 출력
    print(recognizedText)
    audioRecorder?.stop()  // 여기서 실제 파일 저장
    resetAll()
  }
  
  @IBAction func btnStartOrStopDidTap(_ sender: Any) {
    if audioEngine.isRunning {
      stopRecording()
    } else {
      startRecording()
    }
  }
  
  @IBAction func btnRefreshDidTap(_ sender: Any) {
    resetAll()
  }
}

// MARK: - Recording Start / Stop
private extension ViewController {
  func stopRecording() {
    // 1. 오디오 엔진 일시 정지
    audioEngine.pause()
    
    // 2. 타이머 일시 정지
    timer?.invalidate()
    timer = nil
    
    // 3. UI 업데이트
    btnStartOrStop.setTitle("Start", for: .normal)
    btnMoveToNext.isEnabled = true
  }
  
  func startRecording() {
    if recognitionRequest == nil {
      // 최초 녹음 시작
      setupNewRecording()
    } else {
      // 일시정지된 녹음 재개
      do {
        try audioEngine.start()
        
        // 타이머 재시작
        timer = Timer.scheduledTimer(
          withTimeInterval: 1.0,
          repeats: true
        ) { [weak self] _ in
          guard let self = self else { return }
          self.minuteAndSeconds += 1
          self.updateTimeLabel()
        }
        
        btnStartOrStop.setTitle("Stop", for: .normal)
        btnMoveToNext.isEnabled = false
      } catch {
        print("Failed to restart audioEngine")
      }
    }
  }
  
  // 새로운 녹음 설정을 위한 함수
  private func setupNewRecording() {
    btnStartOrStop.setTitle("Stop", for: .normal)
    btnMoveToNext.isEnabled = false
    minuteAndSeconds = 0
    updateTimeLabel()
    
    // Start Timer
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      guard let self = self else { return }
      self.minuteAndSeconds += 1
      self.updateTimeLabel()
    }
    
    // 오디오 세션 설정
    let audioSession = AVAudioSession.sharedInstance()
    do {
      try audioSession.setCategory(.record, mode: .measurement)
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      print("audioSession properties weren't set because of an error.")
      return
    }
    
    // 오디오 레코더 설정
    setupAudioRecorder()
    audioRecorder?.record()
    
    // 음성 인식 요청 설정
    recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    
    guard let recognitionRequest = recognitionRequest else {
      fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
    }
    
    recognitionRequest.shouldReportPartialResults = true
    
    // 오디오 엔진 설정
    let inputNode = audioEngine.inputNode
    let recordingFormat = inputNode.outputFormat(forBus: 0)
    
    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
      self.recognitionRequest?.append(buffer)
    }
    
    audioEngine.prepare()
    
    do {
      try audioEngine.start()
    } catch {
      print("AudioEngine Error")
      return
    }
    
    // 음성 인식 작업 시작
    recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
      guard let self = self else { return }
      
      if let result = result {
        self.recognizedText = result.bestTranscription.formattedString
      }
      
      if error != nil {
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        self.recognitionRequest = nil
        self.recognitionTask = nil
        self.btnStartOrStop.isEnabled = true
      }
    }
  }
  
  func resetAll() {
    audioEngine.stop()
    
    audioEngine.inputNode.removeTap(onBus: 0)
    
    recognitionRequest?.endAudio()
    recognitionRequest = nil
    
    recognitionTask?.cancel()
    recognitionTask = nil
    
    timer?.invalidate()
    timer = nil
    minuteAndSeconds = 0
    updateTimeLabel()
    
    btnStartOrStop.setTitle("Start", for: .normal)
    btnStartOrStop.isEnabled = true
    btnMoveToNext.isEnabled = false
    recognizedText = ""
    
    audioRecorder?.stop()
  }
  
  func updateTimeLabel() {
    let minutes = minuteAndSeconds / 60
    let seconds = minuteAndSeconds % 60
    timeText.text = String(format: "%02d:%02d", minutes, seconds)
  }
  
  func getAudioFileURL() -> URL {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    return documentsPath.appendingPathComponent("recording.m4a")
  }
  
  func setupAudioRecorder() {
    let audioFileName = getAudioFileURL()
    
    let settings: [String: Any] = [
      AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
      AVSampleRateKey: 12000,
      AVNumberOfChannelsKey: 1,
      AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ]
    
    do {
      audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
      audioRecorder?.prepareToRecord()
    } catch {
      print("Audio Recorder Settings error")
    }
  }
}

extension ViewController: SFSpeechRecognizerDelegate {
  // 서비스의 사용 가능 여부를 모니터링해주는 delegate 메서드
  func speechRecognizer(
    _ speechRecognizer: SFSpeechRecognizer,
    availabilityDidChange available: Bool
  ) {
    // Alert 창을 보여줘도 괜찮을듯
    btnStartOrStop.isEnabled = available
  }
}
