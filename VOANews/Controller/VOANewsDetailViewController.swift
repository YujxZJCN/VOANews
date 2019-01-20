//
//  VOANewsDetailViewController.swift
//  VOANews
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

class VOANewsDetailViewController: UIViewController {
    var VOANewsItemName = ""
    var VOANewsItemURL = ""
    var VOANewsDetails = [String]() {
        didSet {
            VOANewsDetailTableView.reloadData()
        }
    }
    
    var audioPlayer = AVAudioPlayer()
    var musicPath = URL.init(string: "") {
        didSet {
            activityIndicator.stopAnimating()
            dismissButton.isEnabled = true
            processSlider.isEnabled = true
            volumeSlider.isEnabled = true
            speedSlider.isEnabled = true
            playButton.isEnabled = true
            if musicPath != URL.init(string: "") {
                setMusic()
            }
            VOANewsDetailTableView.reloadData()
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
    var playTime = 0.0
    
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
    @IBOutlet var VOANewsDetailTableView: UITableView!
    
    var activityIndicator: NVActivityIndicatorView!
    var timer = Timer()
    var loadDataTimes = 0 {
        didSet {
            if loadDataTimes > 20 {
                self.activityIndicator.stopAnimating()
                timer.invalidate()
                
                let alertController = UIAlertController(title: "请检查网络连接", message: "", preferredStyle: .alert)
                self.present(alertController, animated: true, completion: nil)
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.presentedViewController?.dismiss(animated: true, completion: nil)
                }
                
                loadDataTimes = 0
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        createNowPlayingAnimation()
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onSpeedLabelTapped))
        doubleTap.numberOfTapsRequired = 2
        speedLabel.addGestureRecognizer(doubleTap)
        nameLabel.text = VOANewsItemName
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .ballRotateChase, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.lightGray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
    }
    
    @objc func loadData() {
        Alamofire.request((VOANewsItemURL), method: .get).responseData { response in
            let enc: String.Encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0632))
//            let str = NSString(data: response.data!, encoding: enc.rawValue) ?? "nodata"
            
            if let html = response.result.value, let doc = try? HTML(html: html, encoding: enc) {
                for content in doc.css(".mp3player") {
                    if let innerHtml = content.innerHTML {
                        let components = innerHtml.components(separatedBy: "\"")
                        let url = NSURL(string: components[components.count - 4])
                        self.downloadFileFromURL(url: url!)
                        self.timer.invalidate()
                    }
                }
                
                for content in doc.css("p") {
                    if let innerHtml = content.innerHTML {
                        let components = innerHtml.components(separatedBy: "<br>")
                        for component in components {
                            self.VOANewsDetails.append(component)
                        }
                    }
                }
                let replaceString1 = "<a href=\"http://wwW.hxen.com/englishvideo/\" target=\"_blank\" class=\"infotextkey\">视频</a>"
                let replaceString2 = "<a href=\"http://www.hxen.com/englishnews/\" target=\"_blank\" class=\"infotextkey\">新闻</a>"
                let replaceString3 = "<a href=\"http://www.hxen.com\" target=\"_blank\" class=\"infotextkey\">英语</a>"
                let replaceString4 = " <a href=" + "\"http://www.hxen.com/englishlistening/\" target=\"_blank\"" + " class=\"infotextkey\">voice</a>"
                let replaceString5 = "<a href=\"http://www.hxen.com/englishlistening/voaenglish/\" target=\"_blank\" class=\"infotextkey\">VOA</a>"
                for index in 0 ..< self.VOANewsDetails.count {
                    if self.VOANewsDetails[index].contains("\n") {
                        self.VOANewsDetails[index] = self.VOANewsDetails[index].replacingOccurrences(of: "\n", with: "")
                    }
                    if self.VOANewsDetails[index].contains(replaceString1) {
                        self.VOANewsDetails[index] = self.VOANewsDetails[index].replacingOccurrences(of: replaceString1, with: "视频")
                    }
                    if self.VOANewsDetails[index].contains(replaceString2) {
                        self.VOANewsDetails[index] = self.VOANewsDetails[index].replacingOccurrences(of: replaceString2, with: "新闻")
                    }
                    if self.VOANewsDetails[index].contains(replaceString3) {
                        self.VOANewsDetails[index] = self.VOANewsDetails[index].replacingOccurrences(of: replaceString3, with: "英语")
                    }
                    if self.VOANewsDetails[index].contains(replaceString4) {
                        self.VOANewsDetails[index] = self.VOANewsDetails[index].replacingOccurrences(of: replaceString4, with: "voice")
                    }
                    if self.VOANewsDetails[index].contains(replaceString5) {
                        self.VOANewsDetails[index] = self.VOANewsDetails[index].replacingOccurrences(of: replaceString5, with: "VOA")
                    }
                }
                
            }
            
        }
    }
    
    @objc func onSpeedLabelTapped() {
        if speedSlider.value == 1.0 { return }
        let status = audioPlayer.isPlaying
        if status {
            audioPlayer.stop()
        }
        audioPlayer.enableRate = true
        audioPlayer.rate = 1.0
        speedSlider.value = 1.0
        speedLabel.text = String(format: "%.2f倍", speedSlider.value)
        if status {
            audioPlayer.play()
        }
    }
    
    func setMusic() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicPath!)
        } catch {
            print("Error")
        }
        audioPlayer.prepareToPlay()
        setStatusBar()
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        audioPlayer.play()
        nowPlayingImageView.startAnimating()
    }
    
    func setStatusBar() {
        let imageForThumb = UIImage(named: "img_circle")
        let imageForVolume = UIImage(named: "img_volume")
        let imageForSpeed = UIImage(named: "img_volume")
        processSlider.setThumbImage(imageForThumb, for: .normal)
        processSlider.minimumTrackTintColor = UIColor.orange
        processSlider.maximumTrackTintColor = UIColor.gray
        processSlider.maximumValue = Float(audioPlayer.duration)
        volumeSlider.setThumbImage(imageForVolume, for: .normal)
        volumeSlider.minimumTrackTintColor = UIColor.gray
        speedSlider.setThumbImage(imageForSpeed, for: .normal)
        speedSlider.minimumTrackTintColor = UIColor.gray
    }

    @IBAction func playTapped(_ sender: UIButton) {
        if playStatus {
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
            playTime = audioPlayer.currentTime
            playButton.setImage(playImage, for: .normal)
            playStatus = false
        } else {
            if processSlider.value >= processSlider.maximumValue - 0.15 {
                audioPlayer.currentTime = 0
            }
            if !audioPlayer.isPlaying {
                audioPlayer.play()
            }
            playButton.setImage(pauseImage, for: .normal)
            playStatus = true
        }
    }
    
    @objc func updateSlider() {
        processSlider.value = Float(audioPlayer.currentTime)
        currentTime.text = getFormatPlayTime(secounds: audioPlayer.currentTime)
        if processSlider.value >= processSlider.maximumValue - 0.15 {
//            playingNumber += 1
//            setMusic()
            audioPlayer.stop()
            playButton.setImage(playImage, for: .normal)
            playStatus = false
        }
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
        audioPlayer.currentTime = TimeInterval(processSlider.value)
    }
    
    @IBAction func volumeController(_ sender: UISlider) {
        audioPlayer.volume = volumeSlider.value * 5

    }
    
    @IBAction func speedController(_ sender: UISlider) {
        let status = audioPlayer.isPlaying
        audioPlayer.stop()
        audioPlayer.enableRate = true
        audioPlayer.rate = speedSlider.value
        speedLabel.text = String(format: "%.2f倍", speedSlider.value)
        if status {
            audioPlayer.play()
        }
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        }
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

extension VOANewsDetailViewController: URLSessionDelegate {
    func downloadFileFromURL(url: NSURL){
        let req = NSMutableURLRequest(url:url as URL)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        let task: URLSessionDownloadTask = session.downloadTask(with: req as URLRequest) { (URL, response, error) in
            self.musicPath = URL
        }
        task.resume()
    }
    
//    func play(url:NSURL) {
//        print("playing \(url)")
//        do {
//            self.audioPlayer = try AVAudioPlayer(contentsOf: url as URL)
//            audioPlayer.prepareToPlay()
//            audioPlayer.volume = 1.0
//            audioPlayer.play()
//        } catch let error as NSError {
//            //self.player = nil
//            print(error.localizedDescription)
//        } catch {
//            print("AVAudioPlayer init failed")
//        }
//    }
}

extension VOANewsDetailViewController {
    override func remoteControlReceived(with event: UIEvent?) {
        switch event!.subtype {
        case .remoteControlPlay:  // play按钮
            audioPlayer.play()
            playStatus = true
        case .remoteControlPause:  // pause按钮
            audioPlayer.pause()
            playStatus = false
        case .remoteControlNextTrack:  // next
            //
            break
        case .remoteControlPreviousTrack:  // previous
            //
            break
        default:
            break
        }
    }
    
    func setLockView(){
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: VOANewsItemName,
            MPMediaItemPropertyArtist: "VOANews",
            MPNowPlayingInfoPropertyPlaybackRate:1.0,
        ]
    }
}

extension VOANewsDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VOANewsDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "VOANewsDetailTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! VOANewsDetailTableViewCell
        
        cell.detailLabel.text = VOANewsDetails[indexPath.row]
        
        return cell
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let identifier = "VOANewsDetailTableViewCell"
        let hsCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? VOANewsDetailTableViewCell
        var tempCell: VOANewsDetailTableViewCell
        hsCell != nil ? (tempCell = hsCell!) : (tempCell = VOANewsDetailTableViewCell())
        tempCell.detailLabel.text = VOANewsDetails[indexPath.row]
        tempCell.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
        tempCell.layoutIfNeeded()
        return tempCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
