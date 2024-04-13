//
//  FacialAnalysisViewController.swift
//  ai 11
//
//  Created by 조윤경 on 3/31/24.
//

import UIKit
import Vision
import AVFoundation

class FacialAnalysisViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let emotionsDic = [
        "Sad" : "슬픔",
        "Fear" : "두려움",
        "Happy" : "기쁨",
        "Angry" : "분노",
        "Neutral" : "중립",
        "Surprise" : "놀람",
        "Disgust" : "혐오감"
    ]
    
    let genderDic = [
        "Male" : "남성",
        "Female" : "여성"
    ]
    
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var faceScrollView: UIScrollView!
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderIdentifierLabel: UILabel!
    @IBOutlet weak var genderConfidenceLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ageIdentifierLabel: UILabel!
    @IBOutlet weak var ageConfidenceLabel: UILabel!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var emotionIdentifierLabel: UILabel!
    @IBOutlet weak var emotionConfidenceLabel: UILabel!
    
    var faceImageViews = [UIImageView]()
    var requests = [VNRequest]()
    var selectedFace: UIImage? {
        didSet{
            if let selectedFace = self.selectedFace {
                DispatchQueue.global(qos: .userInitiated).async{
                    self.performFaceAnalysis(on: selectedFace)
                }
            }
        }
    }
    var selectedImage: UIImage? { // image container for processing ml
        didSet{ //property observer
            
            // set ImageViewImage when selectedImage is set
            self.blurredImageView.image = selectedImage
            self.selectedImageView.image = selectedImage
        }
    }
    
    var selectedCIImage: CIImage? {
        get{
            if let selectedImage =  self.selectedImage {
                return CIImage(image: selectedImage)
            } else {
                return nil
            }
        }
    }
    
    override func viewDidLoad() { // 최초 로딩시 단 한번 생성
        super.viewDidLoad()
        self.hideAllLabels()
        
        do {
            let genderModel = try VNCoreMLModel(for: GenderNet(configuration: .init()).model)
            self.requests.append(VNCoreMLRequest(model: genderModel, completionHandler: handleGenderClassification))
            let ageModel = try VNCoreMLModel(for: AgeNet(configuration: .init()).model)
            self.requests.append(VNCoreMLRequest(model: ageModel, completionHandler: handleAgeClassification))
            let emotionModel = try VNCoreMLModel(for: CNNEmotions(configuration: .init()).model)
            self.requests.append(VNCoreMLRequest(model: emotionModel, completionHandler: handleEmotionClassification))
        } catch {
            print(error)
        }
        
        // Do any additional setup after loading the view.
    }
    @IBAction func addPhoto(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let importFromAlbum = UIAlertAction(title: "앨범에서 가져오기", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .savedPhotosAlbum
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        let takePhoto = UIAlertAction(title: "카메라로 찍기", style: .default) { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: "취소", style: .default)
        
        actionSheet.addAction(importFromAlbum)
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(cancel)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let uiImage = info[.editedImage] as? UIImage {
            picker.dismiss(animated: true)
            self.selectedImage = uiImage
            self.removeRectangles()
            self.removeFaceImageViews()
            self.hideAllLabels()
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.detectFaces()
            }
        }
    }
    // ML operating function
    func detectFaces() {
        if let ciImage = self.selectedCIImage {
            let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler:self.handleFaces)
            #if targetEnvironment(simulator)
                detectFaceRequest.usesCPUOnly = true
            #endif
            let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do{
                try requestHandler.perform([detectFaceRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func handleFaces(request: VNRequest, error: Error?) {
        if let faces = request.results as? [VNFaceObservation] {
            DispatchQueue.main.async{
                self.displayUI(for: faces)
            }
        }
    }
    
    func displayUI(for faces:[VNFaceObservation]){
        if let faceImage = self.selectedImage {
            let imageRect = AVMakeRect(aspectRatio: faceImage.size, insideRect: self.selectedImageView.bounds)
            
            for (index, face) in faces.enumerated() {
                let w = face.boundingBox.size.width * imageRect.width
                let h = face.boundingBox.size.height * imageRect.height
                let x = face.boundingBox.origin.x * imageRect.width
                let y = imageRect.maxY - (face.boundingBox.origin.y * imageRect.height) - h
                
                let layer = CAShapeLayer()
                layer.frame = CGRect(x: x, y: y, width: w, height: h)
                layer.borderColor = UIColor.red.cgColor
                layer.borderWidth = 1
                self.selectedImageView.layer.addSublayer(layer)
                
                let w2 = face.boundingBox.size.width * faceImage.size.width
                let h2 = face.boundingBox.size.height * faceImage.size.height
                let x2 = face.boundingBox.origin.x * faceImage.size.width
                let y2 = (1 - face.boundingBox.origin.y) * faceImage.size.height - h2
                let cropRect = CGRect(x: x2 * faceImage.scale, y: y2 * faceImage.scale, width: w2 * faceImage.scale, height: h2 * faceImage.scale)
                
                if let faceCgImage = faceImage.cgImage?.cropping(to: cropRect) {
                    let faceUIImage = UIImage(cgImage: faceCgImage, scale: faceImage.scale, orientation: .up)
                    let faceImageView = UIImageView(frame: CGRect(x: 90 * index, y: 0, width: 80, height: 80))
                    faceImageView.image = faceUIImage
                    faceImageView.isUserInteractionEnabled = true
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(FacialAnalysisViewController.handleFaceImageViewTap(_:)))
                    faceImageView.addGestureRecognizer(tap)
                    
                    self.faceImageViews.append(faceImageView)
                    self.faceScrollView.addSubview(faceImageView)
                }
            }
            
            self.faceScrollView.contentSize = CGSize(width: 90 * faces.count-10, height: 80)
        }
    }
    
    func removeRectangles(){
        if let sublayers = self.selectedImageView.layer.sublayers{
            for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    func removeFaceImageViews(){
        for faceImageView in faceImageViews {
            faceImageView.removeFromSuperview()
        }
        
        self.faceImageViews.removeAll()
    }
    
    @objc func handleFaceImageViewTap(_ sender:UITapGestureRecognizer){
        if let tappedImageView = sender.view as? UIImageView{
            
            for faceImageView in faceImageViews {
                faceImageView.layer.borderWidth = 0
                faceImageView.layer.borderColor = UIColor.clear.cgColor
            }
            
            tappedImageView.layer.borderWidth = 3
            tappedImageView.layer.borderColor = UIColor.blue.cgColor
            
            self.selectedFace = tappedImageView.image
        }
    }
    
    func performFaceAnalysis(on image: UIImage){
        do {
            for request in self.requests {
                let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
                try handler.perform([request])
            }
        } catch {
            print(error)
        }
    }
    
    func handleGenderClassification(request:VNRequest, error:Error?){
        if let genderObservation = request.results?.first as?
            VNClassificationObservation {
            DispatchQueue.main.async {
                self.showGenderLabel(identifier:self.genderDic[genderObservation.identifier]!,confidence:genderObservation.confidence)
            }
        }
    }
    func handleAgeClassification(request:VNRequest, error:Error?){
        if let ageObservation = request.results?.first as? VNClassificationObservation {
            DispatchQueue.main.async {
                self.showAgeLabel(identifier:ageObservation.identifier,confidence:ageObservation.confidence)
            }
        }
    }
    func handleEmotionClassification(request:VNRequest, error:Error?){
        if let emotionObservation = request.results?.first as? VNClassificationObservation {
            DispatchQueue.main.async {
                self.showEmotionLabel(identifier:self.emotionsDic[emotionObservation.identifier]!,confidence:emotionObservation.confidence)
            }
        }
    }
    
    func hideGenderLabel(){
        self.genderLabel.isHidden = true
        self.genderConfidenceLabel.isHidden = true
        self.genderIdentifierLabel.isHidden = true
    }
    
    func showGenderLabel(identifier: String, confidence: Float){
        self.genderIdentifierLabel.text = identifier
        self.genderConfidenceLabel.text = "\(String(format:"%.1f",confidence * 100))%"
        self.genderLabel.isHidden = false
        self.genderConfidenceLabel.isHidden = false
        self.genderIdentifierLabel.isHidden = false
    }
    func hideAgeLabel(){
        self.ageLabel.isHidden = true
        self.ageConfidenceLabel.isHidden = true
        self.ageIdentifierLabel.isHidden = true
    }
    
    func showAgeLabel(identifier: String, confidence: Float){
        self.ageIdentifierLabel.text = identifier
        self.ageConfidenceLabel.text = "\(String(format:"%.1f",confidence * 100))%"
        self.ageLabel.isHidden = false
        self.ageConfidenceLabel.isHidden = false
        self.ageIdentifierLabel.isHidden = false
    }
    func hideEmotionLabel(){
        self.emotionLabel.isHidden = true
        self.emotionConfidenceLabel.isHidden = true
        self.emotionIdentifierLabel.isHidden = true
    }
    
    func showEmotionLabel(identifier: String, confidence: Float){
        self.emotionIdentifierLabel.text = identifier
        self.emotionConfidenceLabel.text = "\(String(format:"%.1f",confidence * 100))%"
        self.emotionLabel.isHidden = false
        self.emotionConfidenceLabel.isHidden = false
        self.emotionIdentifierLabel.isHidden = false
    }
    
    func hideAllLabels(){
        self.hideGenderLabel()
        self.hideAgeLabel()
        self.hideEmotionLabel()
    }
    
}

