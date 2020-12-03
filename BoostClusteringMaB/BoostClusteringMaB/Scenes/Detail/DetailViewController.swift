//
//  DetailViewController.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/12/03.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    var fullViewYPosition: CGFloat = 44
    var partialViewYPosition: CGFloat { UIScreen.main.bounds.height - 200 }
    var minimumViewYPosition: CGFloat { UIScreen.main.bounds.height - searchBar.frame.height - 44 }
    
    private enum State {
        case minimum // 서치바만
        case partial // 기본
        case full
        
        var next: State {
            switch self {
            case .minimum:
                return .partial
            case .partial:
                return .full
            case .full:
                return .full
            }
        }
        
        var prev: State {
            switch self {
            case .minimum:
                return .minimum
            case .partial:
                return .minimum
            case .full:
                return .partial
            }
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var dragBar: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var fetchedResultsController: NSFetchedResultsController<ManagedPOI>?
    private var currentState: State = .minimum
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = 10
        dragBar.layer.cornerRadius = 3
        initializeFetchedResultsController()
        configureGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.6) {
            self.moveView(state: .minimum)
        }
    }
    
    private func configureGesture() {
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(gesture)
    }
    
    private func moveView(state: State) {
        let yPosition: CGFloat
        switch state {
        case .minimum:
            yPosition = minimumViewYPosition
        case .partial:
            yPosition = partialViewYPosition
        case .full:
            yPosition = fullViewYPosition
        }
        view.frame = CGRect(x: 0, y: yPosition, width: view.frame.width, height: view.frame.height)
        currentState = state
    }
    
    private func moveView(panGestureRecognizer recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let minY = view.frame.minY
        if (minY + translation.y >= fullViewYPosition) && (minY + translation.y <= minimumViewYPosition) {
            view.frame = CGRect(x: 0, y: minY + translation.y, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: view)
        }
    }
    
    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        moveView(panGestureRecognizer: recognizer)
        if recognizer.state == .ended {
            UIView.animate(withDuration: 1, delay: 0, options: [.allowUserInteraction]) {
                let nextState: State = recognizer.velocity(in: self.view).y >= 0 ? self.currentState.prev : self.currentState.next
                self.moveView(state: nextState)
            }
        }
    }
    
    func initializeFetchedResultsController() {
        let coreDataLayer = CoreDataLayer()
        
        fetchedResultsController = coreDataLayer.makeFetchResultsController(
            southWest: LatLng(lat: 30, lng: 120),
            northEast: LatLng(lat: 45, lng: 135)
        )
        
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
}

extension DetailViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            collectionView.insertSections(IndexSet(integer: sectionIndex))
        case .delete:
            collectionView.deleteSections(IndexSet(integer: sectionIndex))
        case .move:
            break
        case .update:
            break
        @unknown default:
            fatalError()
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath ?? .init()])
        case .delete:
            collectionView.deleteItems(at: [indexPath ?? .init()])
        case .update:
            collectionView.reloadItems(at: [indexPath ?? .init()])
        case .move:
            collectionView.moveItem(at: indexPath ?? .init(), to: newIndexPath ?? .init())
        @unknown default:
            fatalError()
        }
    }
}

extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let fetchedResultsController = fetchedResultsController,
              let sections = fetchedResultsController.sections
        else { return 0 }
        
        return sections[section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                            for: indexPath)
                as? DetailCollectionViewCell,
              let object = fetchedResultsController?.object(at: indexPath)
        else {
            return UICollectionViewCell()
        }
        cell.configure(poi: object)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "header",
                                                                           for: indexPath)
                as? DetailCollectionReusableView
        else { return UICollectionReusableView() }
       // header.poiNumberLabel.text = "\(displayedData.count)개"
        //나중에 dataSource.count로 표기
        return header
    }
}

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width - 20, height: 110)
    }
}
