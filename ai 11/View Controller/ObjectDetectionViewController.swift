//
//  ObjectDetectionViewController.swift
//  ai 11
//
//  Created by 조윤경 on 3/31/24.
//

import UIKit

class ObjectDetectionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var selectedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
            self.selectedImageView.image = uiImage
        }
    }
}
