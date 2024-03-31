//
//  ObjectDetectionViewController.swift
//  ai 11
//
//  Created by 조윤경 on 3/31/24.
//

import UIKit
import Vision

class ObjectDetectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var selectedImage: UIImage? { // image container for processing ml
        didSet{ //property observer
            
            // set ImageViewImage when selectedImage is set
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
        
        self.activityIndicatorView.hidesWhenStopped = true
        self.activityIndicatorView.stopAnimating()
        self.categoryLabel.text = ""
        self.confidenceLabel.text = ""
        
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
            self.categoryLabel.text = ""
            self.confidenceLabel.text = ""
            self.activityIndicatorView.startAnimating()
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.detectedObject()
            }
        }
    }
    // ML operating function
    func detectedObject() {
        if let ciImage = self.selectedCIImage {
            do {
                let vnCoreMLModel = try VNCoreMLModel(for: MobileNetV2(configuration: .init()).model)
                let request = VNCoreMLRequest(model: vnCoreMLModel, completionHandler: self.handleObjectDetection)
                request.imageCropAndScaleOption = .centerCrop
                let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
                try requestHandler.perform([request])
                
            } catch {
                print(error)
            }
        }
    }
    
    func handleObjectDetection(request: VNRequest, error: Error?) {
//        if let results = request.results as? [VNClassificationObservation] {
//            for result in results{
//                print("\(result.identifier):\(result.confidence)") // 결과 [id : 정확도] 출력
//            }
//        }
        if let result = request.results?.first as? VNClassificationObservation {
            
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
                self.categoryLabel.text = result.identifier
                self.confidenceLabel.text = "\(String(format:"%.1f",result.confidence * 100))%" // confidence:Float , .1f = 소수점 한자리만 표현
            }
        }
    }
}
