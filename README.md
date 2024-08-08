# Machine Learning in IOS

## CoreML

### Inception V3

1. coreML에서 다운받아서 {프로젝트}에 추가해준다
2. project 추가시 셋팅 
    
    ![스크린샷 2024-03-31 오후 5.16.06.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/3a9c7cf3-8954-4f4c-9411-01e0997a8842/850d3ece-1d85-44cc-b22a-12d6194d11e6/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2024-03-31_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_5.16.06.png)
    
    - Create groups
        - finder에서 접근해서 파일을 추가해도 project에는 반영되지 않는다
        - 이 경우 그룹의 각 파일이 속해야 할 타겟을 선택할 수 있다.
    - Create folder reference
        - finder에서 접근해 파일을 추가/제거하면 project에 즉시 반영된다 : 폴더와 1:1 매칭
        - 별도의 파일이 아닌, 전체 폴더에 대해서 타겟을 지정할 수 있다.
    
    ** 대부분 create groups 사용
    

## Vision

# Object Detection

```swift
  func detectedObject() {
        if let ciImage = self.selectedCIImage {
            do {
                let vnCoreMLModel = try VNCoreMLModel(for: Inceptionv3(configuration: .init()).model)
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
        if let result = request.results?.first as? VNClassificationObservation {
            self.categoryLabel.text = result.identifier
            self.confidenceLabel.text = "\(String(format:"%.1f",result.confidence * 100))%" // confidence:Float , .1f = 소수점 한자리만 표현
        }
    }
```

[RPReplay_Final1712017832.MP4](https://prod-files-secure.s3.us-west-2.amazonaws.com/3a9c7cf3-8954-4f4c-9411-01e0997a8842/a89cf3df-dcd3-49ff-94af-a1997ede37e9/RPReplay_Final1712017832.mp4)

[RPReplay_Final1711889008.MP4](https://prod-files-secure.s3.us-west-2.amazonaws.com/3a9c7cf3-8954-4f4c-9411-01e0997a8842/faf8ee18-55ad-45f4-9d31-e990f68d559e/RPReplay_Final1711889008.mp4)

# Multi-threading

<aside>
💡 UI 관련 코드는 무조건 main thread 에서

</aside>

```swift
DispatchQueue.global(qos: .userInitiated).async { // ML 코드를 백그라운드에서 실행
                self.detectedObject()
            }
            
...

func handleObjectDetection(request: VNRequest, error: Error?) {
        if let result = request.results?.first as? VNClassificationObservation {
        
        // 하단 코드는 UI 관련 코드이기 때문에 메인 스레드에서 실행해줘야함
        // self.categoryLabel.text = result.identifier
        // self.confidenceLabel.text = "\(String(format:"%.1f",result.confidence * 100))%" // confidence:Float , .1f = 소수점 한자리만 표현
         
         DispatchQueue.main.async {
                self.categoryLabel.text = result.identifier
                self.confidenceLabel.text = "\(String(format:"%.1f",result.confidence * 100))%" // confidence:Float , .1f = 소수점 한자리만 표현
          }
        
        }
    }
```

# Face Analysis

### UIView

![스크린샷 2024-04-07 오후 5.49.32.png](https://prod-files-secure.s3.us-west-2.amazonaws.com/3a9c7cf3-8954-4f4c-9411-01e0997a8842/2f58389c-f01e-493a-aea2-22418c05b463/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2024-04-07_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_5.49.32.png)

ddd

```swift
func displayUI(for faces:[VNFaceObservation]){
        if let faceImage = self.selectedImage {
        //imageRect : image size
            let imageRect = AVMakeRect(aspectRatio: faceImage.size, insideRect: self.selectedImageView.bounds)
            
            for face in faces {
                let w = face.boundingBox.size.width * imageRect.width
                let h = face.boundingBox.size.height * imageRect.height
                let x = face.boundingBox.origin.x * imageRect.width
                let y = imageRect.maxY - (face.boundingBox.origin.y * imageRect.height)
                
                let layer = CAShapeLayer() // ImageView 안에 사각형 그리는 layer 
                layer.frame = CGRect(x: x, y: y, width: w, height: h)
                layer.borderColor = UIColor.red.cgColor
                layer.borderWidth = 1
                self.selectedImageView.layer.addSublayer(layer)
            }
        }
    }
```
