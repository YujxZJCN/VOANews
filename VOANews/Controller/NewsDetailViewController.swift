//
//  NewsDetailViewController.swift
//  News
//
//  Created by 俞佳兴 on 2019/1/20.
//  Copyright © 2019 Albert. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import Kanna
import AVFoundation
import MediaPlayer

class NewsDetailViewController: UIViewController, AVAudioPlayerDelegate {
    var newsItems = [News]()
    var indexOfnews = 0
    var newsType = ""
    var newsItemName = ""
    var newsItemURL = ""
    var downloadUrl = NSURL(string: "")
    var downloadTask: URLSessionDownloadTask? = nil
    var newsDetails = [String]() {
        didSet {
            newsDetailTableView.reloadData()
        }
    }
    
    var audioPlayer = AVAudioPlayer() {
        didSet {
            audioPlayer.prepareToPlay()
        }
    }
    var musicPath = URL.init(string: "") {
        didSet {
            if musicPath != URL.init(string: "") {
                setMusic()
            }
        }
    }
    
    var playStatus: Bool = true {
        didSet {
            startNowPlayingAnimation(playStatus)
            if playStatus {
                playButton.setImage(pauseImage, for: .normal)
            }else {
                playButton.setImage(playImage, for: .normal)
            }
        }
    }
    
    var loadedFlag = false
    
    let playImage = UIImage(named: "play_btn")
    let pauseImage = UIImage(named: "pause_btn")
    
    @IBOutlet var processSlider: UISlider!
    @IBOutlet var volumeSlider: UISlider!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var currentTime: UILabel!
    @IBOutlet var dismissButton: UIButton!
    @IBOutlet var nowPlayingImageView: UIImageView!
    @IBOutlet var speedSlider: UISlider!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var newsDetailTableView: UITableView!
    @IBOutlet var rewindButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    
    var activityIndicator: NVActivityIndicatorView!
    
    var timerOfLoadData = Timer()
    
    var loadDataTimes = 0 {
        didSet {
            if loadDataTimes > 20 {
                self.activityIndicator.stopAnimating()
                timerOfLoadData.invalidate()
                dismissButton.isEnabled = true
                let alertController = UIAlertController(title: "请检查网络连接", message: "", preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.presentedViewController?.dismiss(animated: true, completion: nil)
                }
                
                loadDataTimes = 0
            }
        }
    }
    
    @objc func applicationWillResignActive(){
        downloadTask?.cancel()
    }
    
    @objc func applicationDidBecomeActive(){
        if downloadUrl != NSURL(string: ""), loadedFlag == false {
            downloadTask?.cancel()
            downloadFileFromURL(url: downloadUrl!)
        }
    }
    
    @objc func applicationWillTerminate(){
        //监听是否进入后台或被kill
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //监听是否触发home键挂起程序.
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        ///监听是否重新进入程序程序.
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        ///监听是否被kill
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error at remote")
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        self.setLockView()

//        // Do any additional setup after loading the view.
//        let blurEffect = UIBlurEffect(style: .prominent)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = view.bounds
//        view.insertSubview(blurEffectView, at: 0)
        dismissButton.isEnabled = false
        processSlider.isEnabled = false
        volumeSlider.isEnabled = false
        speedSlider.isEnabled = false
        playButton.isEnabled = false
        rewindButton.isEnabled = false
        forwardButton.isEnabled = false
        createNowPlayingAnimation()
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onSpeedLabelTapped))
        doubleTap.numberOfTapsRequired = 2
        speedLabel.addGestureRecognizer(doubleTap)
        nameLabel.text = newsItemName
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .ballRotateChase, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.lightGray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        loadData()
        timerOfLoadData = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
    }
    
    @objc func loadData() {
        var nextPageFlag = false
        newsDetails.removeAll()
        newsDetailTableView.reloadData()
        Alamofire.request((newsItemURL), method: .get).responseData { response in
            let enc: String.Encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0632))
            
            if let html = response.result.value, let doc = try? HTML(html: html, encoding: enc) {
                if let content = doc.content {
                    if content.contains("下一页") {
                        nextPageFlag = true
                    }
                }
                
                for content in doc.css(".mp3player") {
                    if let innerHtml = content.innerHTML {
                        let components = innerHtml.components(separatedBy: "\"")
                        self.downloadUrl = NSURL(string: components[components.count - 4])!
                        if components.count > 40 {
                            self.downloadUrl = NSURL(string: components[components.count - 12])!
                        }
                        self.downloadFileFromURL(url: self.downloadUrl!)
                        self.timerOfLoadData.invalidate()
                    }
                }
                var newsOriginalDetails = [String]()
                for content in doc.css("p") {
                    if let innerHtml = content.innerHTML {
                        let components = innerHtml.components(separatedBy: "<br>")
                        for component in components {
                            newsOriginalDetails.append(component)
                        }
                    }
                }
                self.newsDetails = newsOriginalDetails
                
                let replaceString1 = "<a href=\"http://wwW.hxen.com/englishvideo/\" target=\"_blank\" class=\"infotextkey\">视频</a>"
                let replaceString2 = "<a href=\"http://www.hxen.com/englishnews/\" target=\"_blank\" class=\"infotextkey\">新闻</a>"
                let replaceString3 = "<a href=\"http://www.hxen.com\" target=\"_blank\" class=\"infotextkey\">英语</a>"
                let replaceString4 = " <a href=" + "\"http://www.hxen.com/englishlistening/\" target=\"_blank\"" + " class=\"infotextkey\">voice</a>"
                let replaceString5 = "<a href=\"http://www.hxen.com/englishlistening/voaenglish/\" target=\"_blank\" class=\"infotextkey\">VOA</a>"
                let replaceString6 = "<a href=\"http://www.hxen.com/englisharticle/\" target=\"_blank\" class=\"infotextkey\">阅读</a>"
                let replaceString7 = "<a href=\"http://www.hxen.com\" target=\"_blank\" class=\"infotextkey\">study</a>"
                let replaceString8 = "<a href=\"http://www.hxen.com/englishlistening/npr/\" target=\"_blank\" class=\"infotextkey\">NPR</a>"
                let replaceString9 = "<a href=\"http://www.hxen.com\">www.hxen.com</a> ."
                let replaceString10 = " <a href=\"http://www.hxen.com/\">www.hxen.com</a> "
                let replaceString11 = "<a href=\"http://www.hxen.com\" target=\"_blank\" class=\"infotextkey\">cnn</a>"
                let replaceString12 = "&amp;"
                var countOfImage = [Int]()
                
                var numberOfNewsDetailsToBeDeleted = [Int]()
                for index in 0 ..< self.newsDetails.count {
                    if self.newsDetails[index] == " " {
                        numberOfNewsDetailsToBeDeleted.append(index)
                    }
                }
                
                if numberOfNewsDetailsToBeDeleted.count >= 0 {
                    for index in numberOfNewsDetailsToBeDeleted {
                        self.newsDetails.remove(at: index)
                    }
                }
                
                for index in 0 ..< self.newsDetails.count {
                    if self.newsDetails[index].first == "\r\n" {
                        let replacedString = self.newsDetails[index].replacingCharacters(in: ...self.newsDetails[index].startIndex, with: "")
                        self.newsDetails[index] = replacedString
                    }
                    if self.newsDetails[index].contains("\n") {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: "\n", with: "")
                    }
                    if self.newsDetails[index].contains(replaceString1) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString1, with: "视频")
                    }
                    if self.newsDetails[index].contains(replaceString2) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString2, with: "新闻")
                    }
                    if self.newsDetails[index].contains(replaceString3) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString3, with: "英语")
                    }
                    if self.newsDetails[index].contains(replaceString4) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString4, with: "voice")
                    }
                    if self.newsDetails[index].contains(replaceString5) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString5, with: "VOA")
                    }
                    if self.newsDetails[index].contains(replaceString6) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString6, with: "阅读")
                    }
                    if self.newsDetails[index].contains(replaceString7) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString7, with: "study")
                    }
                    if self.newsDetails[index].contains(replaceString8) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString8, with: "NPR")
                    }
                    if self.newsDetails[index].contains(replaceString9) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString9, with: "us.")
                    }
                    if self.newsDetails[index].contains(replaceString10) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString10, with: "")
                    }
                    if self.newsDetails[index].contains(replaceString11) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString11, with: "CNN")
                    }
                    if self.newsDetails[index].contains(replaceString12) {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: replaceString12, with: "&")
                    }
                    if self.newsDetails[index].contains("<img") {
                        countOfImage.append(index)
                    }
                    if self.newsDetails[index].contains("<strong>") {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: "<strong>", with: "")
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: "</strong>", with: "")
                    }
                    if self.newsDetails[index].contains("<em>") {
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: "<em>", with: "")
                        self.newsDetails[index] = self.newsDetails[index].replacingOccurrences(of: "</em>", with: "")
                    }
                }
                
                if countOfImage.count > 0 {
                    for index in countOfImage {
                        self.newsDetails.remove(at: index)
                    }
                }
                
            }
            if nextPageFlag {
                let index = self.newsItemURL.index(self.newsItemURL.endIndex, offsetBy: -6)
                var nextPageUrl = self.newsItemURL[self.newsItemURL.startIndex ... index]
                nextPageUrl += "_2.html"
                self.loadNextPage(url: String(nextPageUrl))
            }
        }
        loadDataTimes += 1
        
    }
    
    func loadNextPage(url: String) {
        if url.contains("bbc") {
            newsDetails.removeAll()
            newsDetailTableView.reloadData()
        }
        Alamofire.request((url), method: .get).responseData { response in
            let enc: String.Encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0632))
            if let html = response.result.value, let doc = try? HTML(html: html, encoding: enc) {
                var count = 0
                for content in doc.css(".center") {
                    count += 1
                    if count == 1 {
                        continue
                    }else if count > 2 {
                        break
                    }
                    if let secondContent = content.content {
                        let components = secondContent.components(separatedBy: "音频下载[点击右键另存为]\r\n")
                        var thirdContent = components[1]
                        thirdContent = thirdContent.components(separatedBy: "2/2")[0]
                        let thirdContentComponents = thirdContent.components(separatedBy: "\r\n")
                        for thirdContentComponent in thirdContentComponents {
                            self.newsDetails.append(thirdContentComponent)
                        }
                    }
                }
            }
        }
    }
    
    @objc func onSpeedLabelTapped() {
        if speedSlider.value == 1.0 { return }
        if !loadedFlag {
            return
        }
        let status = audioPlayer.isPlaying
        if status, loadedFlag {
            audioPlayer.stop()
        }
        audioPlayer.enableRate = true
        audioPlayer.rate = 1.0
        speedSlider.value = 1.0
        speedLabel.text = String(format: "%.2f倍", speedSlider.value)
        if status, loadedFlag {
            audioPlayer.play()
        }
    }
    
    func setMusic() {
        var flag = true
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicPath!)
        } catch {
            print("Error at setMusic()")
            flag = false
            playButton.isEnabled = false
            startNowPlayingAnimation(false)
        }
//        audioPlayer.prepareToPlay()
        newsDetailTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        if flag {
            setStatusBar()
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
            audioPlayer.volume = volumeSlider.value * 10
            audioPlayer.enableRate = true
            audioPlayer.rate = speedSlider.value
            audioPlayer.delegate = self
            activityIndicator.stopAnimating()
            dismissButton.isEnabled = true
            processSlider.isEnabled = true
            volumeSlider.isEnabled = true
            speedSlider.isEnabled = true
            playButton.isEnabled = true
            rewindButton.isEnabled = true
            forwardButton.isEnabled = true
            audioPlayer.play()
            playStatus = true
            loadedFlag = true
        }else {
            playStatus = false
            loadedFlag = false
        }
        loadDataTimes = 0
        if flag {
            nowPlayingImageView.startAnimating()
        }
    }
    
    func setStatusBar() {
        let imageForThumb = UIImage(named: "img_circle")
        let imageForVolume = UIImage(named: "img_volume")
        let imageForSpeed = UIImage(named: "img_volume")
        processSlider.setThumbImage(imageForThumb, for: .normal)
        processSlider.minimumTrackTintColor = UIColor(red: 231, green: 76, blue: 60)
        processSlider.maximumTrackTintColor = UIColor.gray
        processSlider.maximumValue = Float(audioPlayer.duration)
        volumeSlider.setThumbImage(imageForVolume, for: .normal)
        volumeSlider.minimumTrackTintColor = UIColor.gray
        speedSlider.setThumbImage(imageForSpeed, for: .normal)
        speedSlider.minimumTrackTintColor = UIColor.gray
    }

    @IBAction func playTapped(_ sender: UIButton) {
        playButton.alpha = 1.0
        if playStatus {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
            if loadedFlag {
                if audioPlayer.isPlaying {
                   audioPlayer.pause()
                }
            }
            playButton.setImage(playImage, for: .normal)
            playStatus = false
        } else {
            if processSlider.value >= processSlider.maximumValue - 0.15 {
                audioPlayer.currentTime = 0
            }
            if loadedFlag {
                if !audioPlayer.isPlaying {
                    audioPlayer.play()
                }
            }
            playButton.setImage(pauseImage, for: .normal)
            playStatus = true
        }
    }
    
    @IBAction func rewindTapped(_ sender: UIButton) {
        loadDataTimes = 0
        rewindButton.alpha = 1.0
        if loadedFlag {
            audioPlayer.stop()
        }
        playStatus = false
        loadedFlag = false
        activityIndicator.startAnimating()
        dismissButton.isEnabled = false
        processSlider.isEnabled = false
        volumeSlider.isEnabled = false
        speedSlider.isEnabled = false
        playButton.isEnabled = false
        rewindButton.isEnabled = false
        forwardButton.isEnabled = false
        playButton.setImage(pauseImage, for: .normal)
        if indexOfnews == 0 {
            indexOfnews = newsItems.count - 1
        }else {
            indexOfnews -= 1
        }
        newsItemName = newsItems[indexOfnews].name
        newsItemURL = newsItems[indexOfnews].url
        nameLabel.text = newsItemName
        newsDetails.removeAll()
        newsDetailTableView.reloadData()
        timerOfLoadData = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
        setLockView()
    }
    
    @IBAction func forwardTapped(_ sender: UIButton) {
        loadDataTimes = 0
        forwardButton.alpha = 1.0
        if loadedFlag {
            audioPlayer.stop()
        }
        playStatus = false
        loadedFlag = false
        activityIndicator.startAnimating()
        dismissButton.isEnabled = false
        processSlider.isEnabled = false
        volumeSlider.isEnabled = false
        speedSlider.isEnabled = false
        playButton.isEnabled = false
        rewindButton.isEnabled = false
        forwardButton.isEnabled = false
        playButton.setImage(pauseImage, for: .normal)
        if indexOfnews == newsItems.count - 1 {
            indexOfnews = 0
        }else {
            indexOfnews += 1
        }
        newsItemName = newsItems[indexOfnews].name
        newsItemURL = newsItems[indexOfnews].url
        newsDetails.removeAll()
        newsDetailTableView.reloadData()
        nameLabel.text = newsItemName
        timerOfLoadData = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
        setLockView()
    }
    
    @IBAction func onPlayTouchDown(_ sender: UIButton) {
        playButton.alpha = 0.5
    }
    
    @IBAction func onRewindTouchDown(_ sender: UIButton) {
        rewindButton.alpha = 0.5
    }
    @IBAction func onForwardTouchDown(_ sender: UIButton) {
        forwardButton.alpha = 0.5
    }
    
    @IBAction func onPlayTouchUpOutside(_ sender: UIButton) {
        playButton.alpha = 1.0
    }
    
    @IBAction func onRewindTouchUpOutside(_ sender: UIButton) {
        rewindButton.alpha = 1.0
    }
    
    @IBAction func onForwardTouchUpOutside(_ sender: UIButton) {
        forwardButton.alpha = 1.0
    }
    
    @objc func updateSlider() {
        if loadedFlag {
            processSlider.value = Float(audioPlayer.currentTime)
        }else {
            return
        }
        currentTime.text = getFormatPlayTime(secounds: audioPlayer.currentTime)
        if processSlider.value >= processSlider.maximumValue - 0.15 {
            audioPlayer.stop()
            playButton.setImage(playImage, for: .normal)
            playStatus = false
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer.stop()
        playStatus = false
        processSlider.value = processSlider.maximumValue
    }
    
    func getFormatPlayTime(secounds:TimeInterval) -> String {
        if secounds.isNaN{
            return "00:00"
        }
        var Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        var Hour = 0
        if Min >= 60 {
            Hour = Int(Min / 60)
            Min = Min - Hour*60
            return String(format: "%02d:%02d", Min, Sec)
        }
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    func createNowPlayingAnimation() {
        
        // Create Animation
        nowPlayingImageView.animationImages = AnimationFrames.createFrames()
        nowPlayingImageView.animationDuration = 0.7
    }
    
    func startNowPlayingAnimation(_ animate: Bool) {
        if animate {
            nowPlayingImageView.startAnimating()
        }else {
            nowPlayingImageView.stopAnimating()
        }
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        if loadedFlag {
            audioPlayer.currentTime = TimeInterval(processSlider.value)
        }
    }
    
    @IBAction func volumeController(_ sender: UISlider) {
        if loadedFlag {
            audioPlayer.volume = volumeSlider.value * 10
        }
    }
    
    @IBAction func speedController(_ sender: UISlider) {
        speedLabel.text = String(format: "%.2f倍", speedSlider.value)
        var status = false
        if loadedFlag {
            status = audioPlayer.isPlaying
        }
        if loadedFlag {
            audioPlayer.stop()
        }else {
            return
        }
        audioPlayer.enableRate = true
        audioPlayer.rate = speedSlider.value
        if status, loadedFlag {
            audioPlayer.play()
        }
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        if loadedFlag {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
        if downloadTask != nil {
            downloadTask?.cancel()
            downloadTask = nil
        }
        downloadUrl = NSURL(string: "")
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension NewsDetailViewController: URLSessionDelegate {
    func downloadFileFromURL(url: NSURL){
        dismissButton.isEnabled = true
        let req = NSMutableURLRequest(url:url as URL)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        downloadTask = session.downloadTask(with: req as URLRequest) { (URL, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.musicPath = URL
        }
        downloadTask!.resume()
    }
}

extension NewsDetailViewController {
    override func remoteControlReceived(with event: UIEvent?) {
        switch event!.subtype {
        case .remoteControlPlay:  // play按钮
            audioPlayer.play()
            playStatus = true
        case .remoteControlPause:  // pause按钮
            audioPlayer.pause()
            playStatus = false
        case .remoteControlNextTrack:  // next
            loadDataTimes = 0
            audioPlayer.stop()
            playStatus = false
            activityIndicator.startAnimating()
            dismissButton.isEnabled = false
            processSlider.isEnabled = false
            volumeSlider.isEnabled = false
            speedSlider.isEnabled = false
            playButton.isEnabled = false
            rewindButton.isEnabled = false
            forwardButton.isEnabled = false
            playButton.setImage(pauseImage, for: .normal)
            if indexOfnews == newsItems.count - 1 {
                indexOfnews = 0
            }else {
                indexOfnews += 1
            }
            newsItemName = newsItems[indexOfnews].name
            newsItemURL = newsItems[indexOfnews].url
            nameLabel.text = newsItemName
            newsDetails.removeAll()
            newsDetailTableView.reloadData()
            timerOfLoadData = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
            setLockView()
            break
        case .remoteControlPreviousTrack:  // previous
            loadDataTimes = 0
            audioPlayer.stop()
            playStatus = false
            activityIndicator.startAnimating()
            dismissButton.isEnabled = false
            processSlider.isEnabled = false
            volumeSlider.isEnabled = false
            speedSlider.isEnabled = false
            playButton.isEnabled = false
            rewindButton.isEnabled = false
            forwardButton.isEnabled = false
            playButton.setImage(pauseImage, for: .normal)
            if indexOfnews == 0 {
                indexOfnews = newsItems.count - 1
            }else {
                indexOfnews -= 1
            }
            newsItemName = newsItems[indexOfnews].name
            newsItemURL = newsItems[indexOfnews].url
            nameLabel.text = newsItemName
            newsDetails.removeAll()
            newsDetailTableView.reloadData()
            timerOfLoadData = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
            setLockView()
            break
        default:
            break
        }
    }
    
    func setLockView(){
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: newsItemName,
            MPMediaItemPropertyArtist: newsType,
            MPNowPlayingInfoPropertyPlaybackRate:1.0,
        ]
    }
}

extension NewsDetailViewController: UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    func heightForTextView(textView: UITextView, fixedWidth: CGFloat) -> CGFloat {
        let size = CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        let constraint = textView.sizeThatFits(size)
        return constraint.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "NewsDetailTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NewsDetailTableViewCell
        cell.detailTextView.delegate = self
        cell.detailTextView.isEditable = false
        cell.detailTextView.isScrollEnabled = false
        if newsItemURL.contains("cnn") {
            if indexPath.row % 2 == 0 {
                cell.detailTextView.text = newsDetails[indexPath.row / 2]
            }else {
                cell.detailTextView.text = newsDetails[(indexPath.row - 1) / 2 + newsDetails.count / 2]
            }
        }else {
            cell.detailTextView.text = newsDetails[indexPath.row]
        }
        cell.detailTextView.frame = CGRect(x: cell.detailTextView.frame.origin.x, y: cell.detailTextView.frame.origin.y, width: cell.detailTextView.frame.width, height: heightForTextView(textView: cell.detailTextView, fixedWidth: cell.detailTextView.frame.width))
        return cell
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let identifier = "NewsDetailTableViewCell"
        let hsCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? NewsDetailTableViewCell
        var tempCell: NewsDetailTableViewCell
        hsCell != nil ? (tempCell = hsCell!) : (tempCell = NewsDetailTableViewCell())
        tempCell.detailTextView.text = newsDetails[indexPath.row]
        tempCell.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
        tempCell.layoutIfNeeded()
        return tempCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
