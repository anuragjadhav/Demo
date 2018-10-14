//
//  ViewController.swift
//  Demo Project
//
//  Created by DHEERAJ BHAVSAR on 26/09/18.
//  Copyright © 2018 Test Organization. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIDocumentPickerDelegate, RecordingViewDelegate, AVAudioRecorderDelegate {
    
    let filesDataContoller = FilesDataController()
    var backgroundView = UIView()
    var recordingView: RecordingView?
    var isAllowedRecording = false
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var filesTableView: UITableView!
    @IBOutlet weak var addImageButton: BadgeButton!
    @IBOutlet weak var addVideoButton: BadgeButton!
    @IBOutlet weak var addDocumentButton: BadgeButton!
    @IBOutlet weak var addAudioButton: BadgeButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBackgroundView()
        prepareForAudioRecording()
    }
    
    //UITableView DataSource and Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesDataContoller.files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileTableViewCell") as! FileTableViewCell
        cell.configureCell(with: filesDataContoller.files[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFile = filesDataContoller.files[indexPath.row]
        if let selectedFileURL = selectedFile.fileURL {
            let viewFileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewFileViewController") as! ViewFileViewController
            viewFileVC.fileURL = selectedFileURL
            navigationController?.pushViewController(viewFileVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deletedFile = filesDataContoller.files.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            switch deletedFile.fileType! {
            case FileTypes.image:
                self.addImageButton.decreaseBadgeNumber()
            case FileTypes.video:
                self.addVideoButton.decreaseBadgeNumber()
            case FileTypes.document:
                self.addDocumentButton.decreaseBadgeNumber()
            case FileTypes.audio:
                self.addAudioButton.decreaseBadgeNumber()
            default:
                break
            }
        }
    }
    
    
    
    func addImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.image"]
        
        let imageSelectionActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //Camera Action
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }
        cameraAction.setValue(UIImage(named: "camera.png"), forKey: "image")
        imageSelectionActionSheet.addAction(cameraAction)
        
        //Gallery Action
        let galleryAction = UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        })
        galleryAction.setValue(UIImage(named: "photos.png"), forKey: "image")
        imageSelectionActionSheet.addAction(galleryAction)
        
        //Cancel Action
        imageSelectionActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(imageSelectionActionSheet, animated: true, completion: nil)
    }
    
    //MARK: Add Video
    func addVideo() {
        let videoPickerController = UIImagePickerController()
        videoPickerController.delegate = self
        videoPickerController.mediaTypes = ["public.movie"]
        videoPickerController.videoMaximumDuration = VideoRecordingConstants.maximumDuration    //1 min maximum
        
        let videoSelectionActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //Camera Action
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                videoPickerController.sourceType = .camera
                self.present(videoPickerController, animated: true, completion: nil)
            } else {
                NSLog("Camera not available")
            }
        }
        cameraAction.setValue(UIImage(named: "camera.png"), forKey: "image")
        videoSelectionActionSheet.addAction(cameraAction)
        
        //Gallery Action
        let galleryAction = UIAlertAction(title: "Video Library", style: .default, handler: { (action) in
            videoPickerController.sourceType = .photoLibrary
            self.present(videoPickerController, animated: true, completion: nil)
        })
        galleryAction.setValue(UIImage(named: "video-library"), forKey: "image")
        videoSelectionActionSheet.addAction(galleryAction)
        
        //Cancel Action
        videoSelectionActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(videoSelectionActionSheet, animated: true, completion: nil)
    }
    
    //MARK: Add Document
    func addDocument() {
        let documentPickerController = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypeText)], in: .import)
        documentPickerController.delegate = self
        documentPickerController.modalPresentationStyle = .formSheet
        
        let documentSelectionActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        //Document Action
        let documentAction = UIAlertAction(title: "Documents", style: .default) { (action) in
            self.present(documentPickerController, animated: true, completion: nil)
        }
        documentAction.setValue(UIImage(named: "documents.png"), forKey: "image")
        documentSelectionActionSheet.addAction(documentAction)

        //Cancel Action
        documentSelectionActionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(documentSelectionActionSheet, animated: true, completion: nil)
    }
    
    //MARK: Add Audio
    func addAudio() {
        if self.isAllowedRecording {
            self.createRecorder()
        }
    }
    
    //MARK: Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        var fileName: String?
        var fileType: String?
        var fileExtension: String?
        var fileData: Data? = nil
        var fileThumbnail: Data?
        var fileURL: URL? = nil
        
        if picker.mediaTypes == ["public.image"] {
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            fileData = image.jpegData(compressionQuality: ImageConstants.compressionQuality)
            fileThumbnail = getThumbnailForImage(image: image)
            if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                fileName = ("\(imageURL)" as NSString).lastPathComponent
                fileExtension = imageURL.pathExtension
                fileURL = imageURL
            } else {
                if let imageURL = getImageURL(for: fileData) {
                    fileName = ("\(imageURL)" as NSString).lastPathComponent
                    fileExtension = imageURL.pathExtension
                    fileURL = imageURL
                }
            }
            fileType = FileTypes.image
            let imageFile = File(fileName: fileName!, fileData: fileData!, fileType: fileType!, fileExtension: fileExtension, fileThumbnail: fileThumbnail!, fileURL: fileURL)
            self.filesDataContoller.addFile(file: imageFile, isSuccess: { (success) in
                if !success {
                    self.showAlert()
                } else {
                    self.addImageButton.increaseBadgeNumber()
                }
            })
        } else if picker.mediaTypes == ["public.movie"] {
            if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                fileThumbnail = getThumbnailForVideo(path: url)
                UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path)
                do {
                    fileData = try Data(contentsOf: url)
                } catch {
                    print("Error: \(error)")
                }
                if picker.sourceType == .camera {
                    fileName = getCurrentDateAndTime() + ".mov"
                    fileExtension = "mov"
                } else if picker.sourceType == .photoLibrary {
                    fileName = ("\(url)" as NSString).lastPathComponent
                    fileExtension = url.pathExtension
                }
                fileType = FileTypes.video
                let videoFile = File(fileName: fileName!, fileData: fileData!, fileType: fileType!, fileExtension: fileExtension,  fileThumbnail: fileThumbnail!, fileURL: url)
                self.filesDataContoller.addFile(file: videoFile) { (success) in
                    if !success {
                        self.showAlert()
                    } else {
                        self.addVideoButton.increaseBadgeNumber()
                    }
                }
            }
        }
        self.filesTableView.reloadData()
    }
    
    func getImageURL(for imageData: Data?) -> URL? {
        if let data = imageData {
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(getCurrentDateAndTime()).jpeg")
            try? data.write(to: fileURL)
            return fileURL
        }
        return nil
    }
    
    //Document Picker Delegate Methods
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.allowsMultipleSelection = false
        let fileURL = urls[0]
        controller.dismiss(animated: true, completion: nil)
        let fileName = ("\(fileURL)" as NSString).lastPathComponent
        let fileExtension = fileURL.pathExtension
        let fileType = FileTypes.document
        var fileData: Data? = nil
        let fileThumbnail = UIImage(named: "document.png")?.jpegData(compressionQuality: 1)
        do {
            fileData = try Data(contentsOf: fileURL)
        } catch {
            print("Error: \(error)")
        }
        let documentFile = File(fileName: fileName, fileData: fileData!, fileType: fileType, fileExtension: fileExtension, fileThumbnail: fileThumbnail,   fileURL: fileURL)
        self.filesDataContoller.addFile(file: documentFile, isSuccess: { (success) in
            if !success {
                self.showAlert()
            } else {
                self.addDocumentButton.increaseBadgeNumber()
            }
        })
        self.filesTableView.reloadData()
    }
    
    func getThumbnailForVideo(path: URL) -> Data? {
        
        do {
            
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            let thumbnailData = thumbnail.jpegData(compressionQuality: ImageConstants.thumbnailCompressionQuality)
            return thumbnailData
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    //MARK: Audio Recorder Methods
    func prepareForAudioRecording() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.isAllowedRecording = true
                    } else {
                        self.isAllowedRecording = false
                    }
                }
            }
        } catch {
            self.isAllowedRecording = false
        }
    }
    
    //Start Recording
    func startRecording() {
        let audioFilename = FileManager.default.temporaryDirectory.appendingPathComponent("recording-\(getCurrentDateAndTime()).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record(forDuration: TimerConstants.timerDuration)
            //Recording started
        } catch {
            finishRecording(success: false)
        }
    }
    
    //Finish recording
    func finishRecording(success: Bool) {
        if audioRecorder != nil && audioRecorder.isRecording {
            audioRecorder.stop()
        }
        if success {
            let fileURL = audioRecorder.url
            let fileName = ("\(fileURL)" as NSString).lastPathComponent
            let fileExtension = fileURL.pathExtension
            let fileType = FileTypes.audio
            var fileData: Data? = nil
            let fileThumbnail = UIImage(named: "music-file.png")?.jpegData(compressionQuality: 1)
            do {
                fileData = try Data(contentsOf: fileURL)
                let audioFile = File(fileName: fileName, fileData: fileData!, fileType: fileType, fileExtension: fileExtension,  fileThumbnail: fileThumbnail!, fileURL: fileURL)
                filesDataContoller.addFile(file: audioFile) { (success) in
                    if !success {
                        self.showAlert()
                    } else {
                        self.addAudioButton.increaseBadgeNumber()
                    }
                }
            } catch {
                print("Error: \(error)")
            }
            filesTableView.reloadData()
        }
        audioRecorder = nil
    }
    
    //Any Interruption ex: phone call
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func getThumbnailForImage(image: UIImage) -> Data? {
        if let compressedImageData = image.jpegData(compressionQuality: ImageConstants.thumbnailCompressionQuality) {
            return compressedImageData
        }
        return nil
    }
    
    func didTapCancelRecordingButton() {
        if recordingView != nil {
            backgroundView.isHidden = true
            recordingView?.removeFromSuperview()
            finishRecording(success: false)
            //Stop and cancel recording
        }
    }
    
    func didTapAttachRecordingButton() {
        if recordingView != nil {
            finishRecording(success: true)
            backgroundView.isHidden = true
            recordingView?.removeFromSuperview()
        }
    }
    
    func didTapStartRecordingButton() {
        if audioRecorder == nil {
            startRecording()
        }
    }
    
    func didTapPauseRecordingButton() {
        audioRecorder.pause()
    }
    
    func didTapResumeRecordingButton() {
        audioRecorder.record()
    }
    
    func createBackgroundView() {
        if let window = UIApplication.shared.keyWindow {
            backgroundView.frame = window.frame
            backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            backgroundView.isHidden = true
        }
    }
    
    func createRecorder() {
        recordingView = RecordingView(frame: CGRect(x: (self.view.frame.width / 2) - (RecordingViewFrameConstants.width / 2), y: (self.view.frame.height / 2) - (RecordingViewFrameConstants.height / 2), width: RecordingViewFrameConstants.width, height: RecordingViewFrameConstants.height))
        recordingView?.delegate = self
        backgroundView.isHidden = false
        backgroundView.addSubview(recordingView!)
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(backgroundView)
        }
    }
    
    //MARK: IBActions
    @IBAction func addImageButtonPressed(_ sender: BadgeButton) {
        addImage()
    }
    
    @IBAction func addVideoButtonPressed(_ sender: BadgeButton) {
        addVideo()
    }
    
    @IBAction func addDocumentButtonPressed(_ sender: BadgeButton) {
        addDocument()
    }
    
    @IBAction func addAudioButtonPressed(_ sender: BadgeButton) {
        addAudio()
    }
    
    @IBAction func submitButtonTapped(_ sender: UIBarButtonItem) {
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(filesDataContoller.files)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print(jsonString ?? "No data")
        } catch {
            print("Error: \(error)")
        }
    }
    
    //MARK: Get current date and time
    func getCurrentDateAndTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy-HH-mm-ss"
        return formatter.string(from: date)
    }
    
    //MARK: File limit exceeded
    func showAlert() {
        let alert = UIAlertController(title: "Limit Exceeded", message: "Cannot add more than 5 files", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
