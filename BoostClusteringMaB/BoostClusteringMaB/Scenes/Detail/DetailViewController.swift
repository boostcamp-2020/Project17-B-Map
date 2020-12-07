//
//  DetailViewController.swift
//  BoostClusteringMaB
//
//  Created by 강민석 on 2020/12/03.
//

import UIKit
import CoreData

protocol DetailViewControllerDelegate: class {
    func didCellSelected(lat: Double, lng: Double, isClicked: Bool)
}

final class DetailViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet { searchBar.delegate = self }
    }
    @IBOutlet weak var dragBar: UIView!
    
    weak var delegate: DetailViewControllerDelegate?
    
    var fetchedResultsController: NSFetchedResultsController<ManagedPOI>? {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }
    private var currentState: State = .minimum
    private var prevClickedCell: DetailCollectionViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.6) {
            self.moveView(state: .minimum)
        }
        reloadPOI(southWest: LatLng(lat: 30, lng: 120), northEast: LatLng(lat: 45, lng: 135))
    }
    
    private func configureView() {
        view.clipsToBounds = true
        collectionView.isHidden = true
        view.layer.cornerRadius = 10
        dragBar.layer.cornerRadius = 3
    }
    
    func reloadPOI(southWest: LatLng, northEast: LatLng) {
        let coreDataLayer = CoreDataLayer()

        fetchedResultsController = coreDataLayer.makeFetchResultsController(
            southWest: southWest,
            northEast: northEast
        )

        do {
            try fetchedResultsController?.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        collectionView.reloadData()
    }
}

// MARK: Pan Gesture
extension DetailViewController {
    var fullViewYPosition: CGFloat { 44 }
    var partialViewYPosition: CGFloat { UIScreen.main.bounds.height - 200 }
    var minimumViewYPosition: CGFloat { UIScreen.main.bounds.height - searchBar.frame.height - 44 }
    
    private enum State {
        case minimum
        case partial
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
    
    private func configureGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
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
    
    private func moveView(panGestureRecognizer recognizer: UIPanGestureRecognizer) -> State {
        let translation = recognizer.translation(in: view)
        let minY = view.frame.minY
        let endedY = minY + translation.y
        let fullAndPartialBound = (fullViewYPosition + (partialViewYPosition - fullViewYPosition) / 2)
        let partialAndMinimumBound = (partialViewYPosition + (minimumViewYPosition - partialViewYPosition) / 2)
        
        if (endedY >= fullViewYPosition) && (endedY <= minimumViewYPosition) {
            view.frame = CGRect(x: 0, y: endedY, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: view)
        }
        
        switch endedY {
        case ...fullAndPartialBound:
            collectionView.isHidden = false
            return .full
        case ...partialAndMinimumBound:
            collectionView.isHidden = false
            return .partial
        default:
            collectionView.isHidden = true
            return .minimum
        }
    }
    
    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        var nextState = moveView(panGestureRecognizer: recognizer)
        if recognizer.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction]) {
                if nextState == self.currentState {
                    nextState = recognizer.velocity(in: self.view).y >= 0
                        ? self.currentState.prev : self.currentState.next
                }
                self.moveView(state: nextState)
            }
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
//        cell.transform = .init(scaleX: 0, y: 0)
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
//            cell.transform = .init(scaleX: 1.1, y: 1.1)
//        }, completion: { _ in
//            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
//                cell.transform = .identity
//            })
//        })
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: "header",
                                                                           for: indexPath)
                as? DetailCollectionReusableView,
              let poisCount = self.fetchedResultsController?.fetchedObjects?.count
        else { return UICollectionReusableView() }

        header.poiNumberLabel.text = "\(poisCount)개"
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
        return CGSize(width: self.view.bounds.width - 40, height: 110)
    }
}

extension DetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? DetailCollectionViewCell else { return }
        guard let lat = cell.latLng?.lat,
              let lng = cell.latLng?.lng else {
            return
        }
        delegate?.didCellSelected(lat: lat, lng: lng, isClicked: cell.isClicked)
        cell.isClicked = true
        prevClickedCell?.isClicked = false
        prevClickedCell = cell
    }
}

extension DetailViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.5) {
            self.currentState = .full
            self.collectionView.isHidden = false
            self.moveView(state: self.currentState)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.5) {
            self.currentState = .partial
            self.collectionView.isHidden = false
            self.moveView(state: self.currentState)
            self.view.endEditing(true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarTextDidEndEditing(searchBar)
    }
}
