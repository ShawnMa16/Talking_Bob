//
//  ViewController.swift
//  Talking_Bob
//
//  Created by Shawn Ma on 12/03/18.
//  Copyright © 2018 Shawn Ma. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SnapKit
import ApiAI
import AVFoundation
import Speech

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    let sceneView: ARSCNView = {
        let view = ARSCNView()
        return view
    }()
    
    var referenceObjectToTest: ARReferenceObject?
    
    let resetButton: RoundedButton = {
        let button = RoundedButton()
        button.setTitle("Reset", for: .normal)
        return button
    }()
    
    var allPosts = [PostView]()
    
    var player: AVAudioPlayer?
    
    var talkyView: InputView!
    
    let recordButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "recordDefault"), for: .normal)
        button.clipsToBounds = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var speechResult = SFSpeechRecognitionResult()
    
    let voiceInputView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        textView.layer.cornerRadius = 6.0
        textView.textAlignment = .center
        textView.font = UIFont.systemFont(ofSize: 30)
        textView.isUserInteractionEnabled = false
        textView.isHidden = true
        textView.sizeToFit()
        textView.isScrollEnabled = false
        return textView
    }()
    
    let targetObject: String = "bob"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(sceneView)
        view.addSubview(resetButton)
        view.bringSubviewToFront(resetButton)
        
        view.addSubview(recordButton)
        view.bringSubviewToFront(recordButton)
        
        view.addSubview(voiceInputView)
        
        talkyView = InputView(frame: .zero)
        talkyView.isHidden = true
        
        view.addSubview(talkyView)
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        setupSubViews()
        
        addGestureToScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // The callback may not be called on the main thread. Add an
            // operation to the main queue to update the record button's state.
            OperationQueue.main.addOperation {
                var alertTitle = ""
                var alertMsg = ""
                
                switch authStatus {
                case .authorized: break
                    
                case .denied:
                    alertTitle = "Speech recognizer not allowed"
                    alertMsg = "You enable the recgnizer in Settings"
                    
                case .restricted, .notDetermined:
                    alertTitle = "Could not start the speech recognizer"
                    alertMsg = "Check your internect connection and try again"
                    
                }
                if alertTitle != "" {
                    let alert = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        // Create a session configuration
        
        setupARView()
        //        setupARSession()
        
        loadModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Store the screen center location after the view's bounds did change,
        // so it can be retrieved later from outside the main thread.
    }
    
    
    func setupSubViews() {
        
        talkyView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view).offset(0)
        }
        talkyView.bobInput.delegate = self
        talkyView.dissmissButton.addTarget(self, action: #selector(dismissInputView), for: .touchUpInside)
        
        resetButton.addTarget(self, action: #selector(reloadARObject), for: .touchUpInside)
        
        recordButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(72)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-75)
        }
        
        
        recordButton.addTarget(self, action: #selector(recordTouchDown), for: .touchDown)
        
        recordButton.addTarget(self, action: #selector(recordTouchUpInside), for: .touchUpInside)
        
        recordButton.addTarget(self, action: #selector(recordTouchDragExit), for: .touchDragExit)
        
        
        voiceInputView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(200)
            make.right.equalToSuperview().offset(-30)
        }
        
    }
    
    func setupARView() {
        sceneView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().offset(0)
        }
    }
    
    func setupARSession() {
        let configuration = ARObjectScanningConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: .resetTracking)
    }
    
    
    func loadModel() {
        let configuration = ARWorldTrackingConfiguration()
        guard let refObjects = ARReferenceObject.referenceObjects(inGroupNamed:"ARObjects",bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        self.referenceObjectToTest = refObjects.first(where:  { $0.name == self.targetObject })
        
        configuration.detectionObjects = refObjects
        
        sceneView.session.run(configuration)
    }
    
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    func speechAndText(text: String) {
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            
            try audioSession.setCategory(.playback, mode: .default, options: [])
            
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.pitchMultiplier = 0.001
        speechUtterance.rate = 0.5
        
        if let player = player {
            player.stop()
        }
        
        speechSynthesizer.speak(speechUtterance)
        
        let newPost = PostView(text: text)
        
        self.allPosts.append(newPost)
        
        reloadARObject()
    }
    
    private func talkToBob(text: String?) {
        print(text)
        let request = ApiAI.shared().textRequest()
        
        if let _text = text, _text != "" {
            request?.query = _text
            let post = PostView(text: _text)
//            let alpha = CGFloat( 1 - abs(self.allPosts.count / 5))
//            post.setBackground(isBob: false, alpha: alpha)
            
            self.allPosts.append(post)
            
            self.reloadARObject()
        } else {return}
        
        dismissInputView()
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            if let textResponse = response.result.fulfillment.messages {
                let textRespoArray = textResponse[0] as NSDictionary
                print(textResponse)
                
                let speech = textRespoArray.value(forKey: "speech") as! String
                self.speechAndText(text: speech)
                
                if speech == "Banana..." {
                    self.playSound()
                }
            }
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
    }
    
    func playSound() {
        
        guard let url = Bundle.main.url(forResource: "BananaSong", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.volume = 2.0
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    private func startRecording() throws {
        if !audioEngine.isRunning {
            let timer = Timer(timeInterval: 10.0, target: self, selector: #selector(timerEnded), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .spokenAudio, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            let inputNode = audioEngine.inputNode
            
            guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create the recognition request") }
            
            // Configure request so that results are returned before audio recording is finished
            recognitionRequest.shouldReportPartialResults = true
            
            // A recognition task is used for speech recognition sessions
            // A reference for the task is saved so it can be cancelled
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                var isFinal = false
                
                if let result = result {
                    print("result: \(result.isFinal)")
                    isFinal = result.isFinal
                    
                    self.speechResult = result
                    
                    self.voiceInputView.text = result.bestTranscription.formattedString
                    
                    // live changing input text
                    print(result.bestTranscription.formattedString)
                }
                
                // send message to dialogFlow when successful
                
                if error != nil || isFinal {
                    
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    self.talkToBob(text: self.speechResult.bestTranscription.formattedString)
                    
                    self.voiceInputView.text = ""
                }
                
//                self.addNote.isEnabled = self.recordedTextLabel.text != ""
//                self.addReminder.isEnabled = self.recordedTextLabel.text != ""
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
                self.recognitionRequest?.append(buffer)
            }
            
            print("Begin recording")
            audioEngine.prepare()
            try audioEngine.start()
            
        }
        
    }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    
        // Cancel the previous task if it's running
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        self.voiceInputView.text = ""
        
        //        if self.speechResult.isFinal {
//        talkToBob(text: self.speechResult.bestTranscription.formattedString)
//        print(self.speechResult.bestTranscription.formattedString)
//        }
    }
    
    @objc
    func timerEnded() {
        // If the audio recording engine is running stop it and remove the SFSpeechRecognitionTask
        if audioEngine.isRunning {
            stopRecording()
//            checkForActionPhrases()
        }
    }
    
    private func addGestureToScreen() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(reloadARObject))
        sceneView.addGestureRecognizer(gesture)
    }
    
    private func showVoiceInput() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
                self.voiceInputView.isHidden = false
            }, completion: nil)
        }
    }
    
    private func hideVoiceInput() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
                self.voiceInputView.isHidden = true
            }, completion: nil)
        }
    }
    
    private func addNodesToView(to node: SCNNode, at object: ARObjectAnchor) {
        
        for (index, post) in allPosts.enumerated() {
            let reversedIndex = allPosts.count - index
            let isBob = index % 2 == 0
            
            let alpha = (CGFloat( 11 - reversedIndex) / 10.00)
            print("alpha is: \(alpha)")
            
            post.setBackground(isBob: isBob, alpha: alpha)
            
            let offset = isBob ? -0.015 : 0.015
            
            let pos =  SCNVector3Make(object.referenceObject.center.x + Float(offset),
                                      object.referenceObject.center.y
                                        + 0.06 * Float(reversedIndex + 1) + 0.05,
                                      object.referenceObject.center.z)
            
            post.planeNode.position = pos
            
            node.addChildNode(post)
        }
    }
    
    @objc
    func reloadARObject() {
        let anchors = self.sceneView.session.currentFrame?.anchors
        
        for anchor in anchors! {
            if let objectAnchor = anchor as? ARObjectAnchor  {
                self.sceneView.session.remove(anchor: objectAnchor)
            }
        }
    }
    
    @objc
    func dismissInputView() {
        self.talkyView.endEditing(true)
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCrossDissolve, animations: {
            self.talkyView.isHidden = true
        }, completion: nil)
    }
    
    @objc
    func handleSceneTap(_ sender: UITapGestureRecognizer) {
        
        // Hit test to find a place for a virtual object.
        guard let hitTestResult = sceneView
            .hitTest(sender.location(in: sceneView), types: [.featurePoint])
            .first
            else { return }
        
        let objectResults = sceneView
            .hitTest(sender.location(in: sceneView), options: [SCNHitTestOption.boundingBoxOnly : true])
        
        print(hitTestResult, objectResults)
        
        for result in objectResults.filter(( { $0.node.name != nil }) ) {
            if result.node.name == "oreo" {
                // show InputView here
//                showVoiceInput()
                print("hit on the oreo")
                return
            }
        }
        
    }
    
    @objc
    func recordTouchDown() {
        print("Start recording")
        showVoiceInput()
        
        recordButton.setImage(UIImage(named: "recordPressed"), for: .normal)
        do {
            try startRecording()
        } catch {
            fatalError("failed to record")
        }
        
    }
    
    @objc
    func recordTouchUpInside() {
        print("Stop recording")
        hideVoiceInput()
        
        recordButton.setImage(UIImage(named: "recordDefault"), for: .normal)
        stopRecording()
        
    }
    
    @objc
    func recordTouchDragExit() {
        print("Stop recording")
        hideVoiceInput()
        
        recordButton.setImage(UIImage(named: "recordDefault"), for: .normal)
        stopRecording()
        
    }
    
    
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let objectAnchor = anchor as? ARObjectAnchor {
            
            
            if allPosts.count == 0 {
                self.speechAndText(text: "Hello! I'm Bob, let's chat!")
            }
            
            addNodesToView(to: node, at: objectAnchor)
            
        }
        return node
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.talkyView.bobInput {
            dismissInputView()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == self.talkyView.bobInput {
            talkToBob(text: textField.text)
            textField.text = ""
        }
    }
    
}
extension ViewController: SFSpeechRecognitionTaskDelegate {
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        print("the result is: " + recognitionResult.bestTranscription.formattedString)
    }
}
