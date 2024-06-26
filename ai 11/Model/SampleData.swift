//
//  SampleData.swift
//  ai 11
//
//  Created by 조윤경 on 3/31/24.
//

import Foundation

struct Sample{
    let title:String
    let description:String
    let image:String
}

struct SampleData{
    let samples = [
        Sample(title: "Photo Object Detection", description: "불러온 이미지에 있는 사물 인식", image: "ic_photo"),
        Sample(title: "Real Time Object Detection", description: "실시간으로 카메라에 보이는 사물 인식", image: "ic_camera"),
        Sample(title: "Facial Analysis", description: "사람 얼굴로부터 나이, 성별, 감정 추측", image: "ic_emotion")
    ]
}
