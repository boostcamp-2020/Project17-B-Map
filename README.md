# Project17-B-Map

<div align="center">

<img src="https://user-images.githubusercontent.com/16751025/100414316-c90d2980-30bc-11eb-9e05-82c324c4136e.png" alt="icon" width="250"/>

[Wiki Documentation](https://github.com/boostcamp-2020/Project17-B-Map/wiki)&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;[Issue](https://github.com/boostcamp-2020/Project17-B-Map/issues)

[![Swift](https://img.shields.io/badge/swift-v5.3-orange?logo=swift)](https://developer.apple.com/kr/swift/)
[![Xcode](https://img.shields.io/badge/xcode-v12.2-blue?logo=xcode)](https://developer.apple.com/kr/xcode/)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-v1.10.0-blue?logo=CocoaPods)](https://developer.apple.com/kr/xcode/)

[![GitHub Open Issues](https://img.shields.io/github/issues-raw/boostcamp-2020/Project17-B-Map?color=green)](https://github.com/boostcamp-2020/Project17-B-Map/issues)
[![GitHub Closed Issues](https://img.shields.io/github/issues-closed-raw/boostcamp-2020/Project17-B-Map?color=red)](https://github.com/boostcamp-2020/Project17-B-Map/issues?q=is%3Aissue+is%3Aclosed)
[![GitHub Open PR](https://img.shields.io/github/issues-pr-raw/boostcamp-2020/Project17-B-Map?color=green)](https://github.com/boostcamp-2020/Project17-B-Map/pulls)
[![GitHub Closed PR](https://img.shields.io/github/issues-pr-closed-raw/boostcamp-2020/Project17-B-Map?color=red)](https://github.com/boostcamp-2020/Project17-B-Map/pulls?q=is%3Apr+is%3Aclosed)

[![Contributions welcome](https://img.shields.io/badge/contributions-welcome-orange.svg)](https://github.com/boostcamp-2020/Project17-B-Map)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

</div>

## 디렉토리 구조
<details>
  <summary>파일 구조 :file_cabinet: </summary>
    <div markdown=“1”>
      <pre>
Mab_Project
├── AppDelegate.swift
│   ├── Contents.json
│   ├── LaunchScreen
│   │   ├── Contents.json
│   │   ├── Loading_Background.imageset
│   │   │   ├── Contents.json
│   │   │   └── Loading_Background.png
│   │   ├── Loading_Background2.imageset
│   │   │   ├── Contents.json
│   │   │   └── Loading_Background2.png
│   │   ├── Loading_MaB.imageset
│   │   │   ├── Contents.json
│   │   │   └── Loading_MaB.png
│   │   ├── Loading_Marker1.imageset
│   │   │   ├── Contents.json
│   │   │   └── Loading_Marker1.png
│   │   ├── Loading_Marker2.imageset
│   │   │   ├── Contents.json
│   │   │   └── Loading_Marker2.png
│   │   └── Loading_Title.imageset
│   │       ├── Contents.json
│   │       └── Loading_Title.png
│   ├── NaverColor.colorset
│   │   └── Contents.json
│   └── icon.imageset
│       ├── Contents.json
│       └── icon.png
├── BoostClusteringMaB.xcdatamodeld
│   └── BoostClusteringMaB.xcdatamodel
│       └── contents
├── Clustering
│   ├── Cluster.swift
│   ├── Clustering.swift
│   ├── ClusteringProtocol.swift
│   ├── ConvexHull.swift
│   └── KMeans.swift
├── CoreData
│   ├── CoreDataContainer.swift
│   ├── CoreDataLayer.swift
│   └── Models
│       ├── ManagedPOI+CoreDataClass.swift
│       ├── ManagedPOI+CoreDataProperties.swift
│       └── POI.swift
├── Extension
│   ├── CGPoint+Distance.swift
│   ├── CGPoint+isValid.swift
│   ├── NMFCameraUpdate+.swift
│   ├── NMFMarker+.swift
│   ├── NMFMarker+Animation.swift
│   ├── NMFPolygonOverlay+.swift
│   ├── String+Bundle.swift
│   ├── String+Localize.swift
│   └── UIColor+.swift
├── Info.plist
├── MainAnimationController.swift
├── Models
│   ├── Geocoding.swift
│   ├── LatLng.swift
│   ├── LinkedList.swift
│   └── POIModel.swift
├── Resources
│   ├── Fonts
│   │   ├── BMEuljiro10yearslaterOTF.otf
│   │   ├── NanumSquareRoundOTFEB.otf
│   │   └── NanumSquareRoundOTFR.otf
│   └── POIRawData
│       ├── csv
│       │   └── poi.csv
│       └── json
│           ├── gangnam_8000.json
│           └── restaurant.json
├── SceneDelegate.swift
├── Scenes
│   ├── Detail
│   │   ├── DetailViewController.swift
│   │   └── View
│   │       └── DetailCollectionViewCell.swift
│   ├── Loading
│   │   └── LoadViewController.swift
│   ├── MainView
│   │   ├── AlertType.swift
│   │   ├── Animations
│   │   │   └── MarkerAnimateController.swift
│   │   ├── MainInteractor.swift
│   │   ├── MainPresenter.swift
│   │   └── MainViewController.swift
│   └── Views
│       ├── Base.lproj
│       │   ├── LaunchScreen.storyboard
│       │   └── Main.storyboard
│       ├── Detail.storyboard
│       ├── Loading.storyboard
│       └── MarkerImageView.swift
├── Util
│   ├── AddressAPI.swift
│   ├── CSVParser.swift
│   ├── DataParser.swift
│   ├── ImageDownloader.swift
│   └── JsonParser.swift
└── en.lproj
    └── Localizable.strings
         </pre>
    </div>
</details>

# Map App 
[![Releases](https://img.shields.io/github/v/release/boostcamp-2020/Project17-B-Map)](https://github.com/boostcamp-2020/Project17-B-Map/releases)
[![build](https://github.com/boostcamp-2020/Project17-B-Map/workflows/iOS%20CI/badge.svg)](https://github.com/boostcamp-2020/Project17-B-Map/actions)

배조주소🎯: [https://kr.object.ncloudstorage.com/mab/project/download.html](https://kr.object.ncloudstorage.com/mab/project/download.html)

## Author

| <img src="https://avatars1.githubusercontent.com/u/19145853?s=400&v=4" width="150"> | <img src="https://avatars1.githubusercontent.com/u/45285737?s=400&u=f4cdb2b4602081bc3665ecc100f2d249fa42dafe&v=4" width="150"> | <img src="https://avatars3.githubusercontent.com/u/46857148?s=400&u=e0b8c5ad6bcffb03f70594ed53df88e2124f523c&v=4" width="150"> | <img src="https://avatars2.githubusercontent.com/u/23518265?s=400&u=6c665122d3ce7ab26433218d845c9f0170157d0f&v=4" width="150"> | <img src="https://avatars2.githubusercontent.com/u/16751025?s=400&v=4" width="150"> |
| ----------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
|  **[S001] 강민석** <br>[@kati-kms](https://github.com/kati-kms)   |  **[S009] 김석호** [@SeokBA](https://github.com/seokBA)   |  **[S018] 박재현** [@wogus3602](https://github.com/wogus3602)     |  **[S057] 조정래** [@chojl1125](https://github.com/chojl1125)     |  **[S063] 현기엽** [@KYHyeon](https://github.com/KYHyeon)     |

## 프로젝트 목표

### Clustering
- Kmeans 클러스터 계산 시간 1초 이내
- Davies-Bouldin index 1.0 이내의 k값 설정하기

### Animation
- 사용자 입장에서 자연스러운 애니메이션 구현 (60fps기준)
- 마커가 병합/분할 된 뒤, 바운스되는 애니메이션 구현

### Interaction
- POI Data 8000개 기준 클러스터 터치 최대 7번 내로 목표 지점 도달
- 카테고리 별 검색 기능 구현

### Unit Test
- 기능을 개발했으면 단위테스트 작성해서 익숙해지기

## Requirements
 - iOS 14.0+
 - Xcode 12.2+
 - Swift 5.3+
 
## Cocoapods

```ruby
target 'BoostClusteringMaB' do
  use_frameworks!

  pod 'SwiftLint'
  pod 'NMapsMap'


  target 'BoostClusteringMaBTests' do
    pod 'NMapsMap'
  end
end
```

## Swift Package Manager


## Installation
1. 대용량 파일을 받기 위해 [git-lfs](https://git-lfs.github.com/)를 설치해야합니다.
```
brew install git-lfs
```

2. 프로젝트 폴더에서 git-lfs 초기화를 해줘야 합니다.
```
git-lfs install
```

3. SDK를 최신 버전으로 업데이트 합니다.
```
$ pod install --repo-update
```

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE). 
