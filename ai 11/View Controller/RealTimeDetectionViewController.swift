//
//  RealTimeDetectionViewController.swift
//  ai 11
//
//  Created by 조윤경 on 3/31/24.
//

import UIKit
import Vision

class RealTimeDetectionViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    var videoCapture: VideoCapture!
    
    let visionRequestHandler = VNSequenceRequestHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spec = VideoSpec(fps: 3, size: CGSize(width: 1280, height: 720))
        self.videoCapture = VideoCapture(cameraType: .back, preferredSpec: spec, previewContainer: self.cameraView.layer)
        self.videoCapture.imageBufferHandler = { (imageBuffer, timestamp, outputBuffer) in
            // 이미지가 바뀔 때마다 불러와짐
            self.detectObject(image: imageBuffer)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let videoCapture = self.videoCapture {
            videoCapture.startCapture() // view가 화면에 보일 때 캡쳐 시작
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let videoCapture = self.videoCapture {
            videoCapture.stopCapture() // view가 화면에서 사라질 때 캡쳐 멈춤
        }
    }
    
    func detectObject(image: CVImageBuffer) {
        do {
            let vnCoreMLModel = try VNCoreMLModel(for: MobileNetV2(configuration: .init()).model)
            let request = VNCoreMLRequest(model: vnCoreMLModel, completionHandler: self.handleObjectDetection)
            request.imageCropAndScaleOption =  .centerCrop
            try self.visionRequestHandler.perform([request], on: image)
        } catch {
            print(error)
        }
    }
    
    func handleObjectDetection(request: VNRequest, error: Error?) {
        if let result = request.results?.first as? VNClassificationObservation {
//            print("\(result.identifier):\(result.confidence)")
            DispatchQueue.main.async {
                self.categoryLabel.text = result.identifier
                self.confidenceLabel.text = "\(String(format:"%.1f",result.confidence * 100))%" // confidence:Float , .1f = 소수점 한자리만 표현
            }
        }
    }
}
