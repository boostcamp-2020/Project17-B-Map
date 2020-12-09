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

    enum Section {
        case main
    }

    var diffableDataSource: UICollectionViewDiffableDataSource<Section, ManagedPOI>?

    weak var delegate: DetailViewControllerDelegate?
    
    var fetchedResultsController: NSFetchedResultsController<ManagedPOI>? = {
        let coreDataLayer = CoreDataLayer()
        let controller = coreDataLayer.makeFetchResultsController()
        return controller
    }()

    private var currentState: State = .minimum {
        didSet {
            if currentState == .minimum {
                collectionView.isHidden = true
            } else {
                collectionView.isHidden = false
            }
        }
    }
    private var prevClickedCell: DetailCollectionViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureGesture()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.6) {
            self.moveView(state: .minimum)
        }
    }
    
    private func configureView() {
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        dragBar.layer.cornerRadius = 3
    }

    private func configureDataSource() {
        let diffableDataSource = UICollectionViewDiffableDataSource<Section, ManagedPOI>(
            collectionView: collectionView
        ) { (collectionView, indexPath, _) -> UICollectionViewCell? in

            guard let object = self.fetchedResultsController?.object(at: indexPath) else { return .init() }

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                                for: indexPath)
                    as? DetailCollectionViewCell else { return .init()}

            cell.configure(poi: object)
            return cell
        }

        self.diffableDataSource = diffableDataSource
        collectionView.dataSource = diffableDataSource
    }

    private var southWest: LatLng = .zero
    private var northEast: LatLng = .zero

    func reloadPOI(southWest: LatLng = .zero, northEast: LatLng = .zero, _ searchText: String = "") {
        let subpredicates = makeSubPredicates(southWest: southWest, northEast: northEast, searchText)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: subpredicates)

        fetchedResultsController?.fetchRequest.predicate = predicate
        try? fetchedResultsController?.performFetch()
        updateSnapshot()
    }

    func makeSubPredicates(southWest: LatLng,
                           northEast: LatLng,
                           _ searchText: String) -> [NSPredicate] {
        if southWest != .zero && northEast != .zero {
            self.southWest = southWest
            self.northEast = northEast
            searchBar.text = ""
        }

        var subPredicates = [NSPredicate]()

        let latitudePredicate = NSPredicate(format: "latitude BETWEEN {%@, %@}",
                                            argumentArray: [self.southWest.lat, self.northEast.lat])

        let longitudePredicate = NSPredicate(format: "longitude BETWEEN {%@, %@}",
                                             argumentArray: [self.southWest.lng, self.northEast.lng])

        subPredicates.append(contentsOf: [latitudePredicate, longitudePredicate])

        if !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "name CONTAINS[c] %@", searchText)
            subPredicates.append(searchPredicate)
        }
        return subPredicates
    }

    func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ManagedPOI>()
        snapshot.appendSections([.main])
        snapshot.appendItems(fetchedResultsController?.fetchedObjects ?? [], toSection: .main)
        diffableDataSource?.apply(snapshot)
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
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        delegate?.didCellSelected(lat: lat, lng: lng, isClicked: cell.isClicked)
        cell.isClicked = true
        prevClickedCell?.isClicked = false
        prevClickedCell = cell
        searchViewEditing(true)
    }
}

extension DetailViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadPOI(searchText)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchViewEditing(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchViewEditing(false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarTextDidEndEditing(searchBar)
        reloadPOI()
    }

    func searchViewEditing(_ isEditing: Bool) {
        UIView.animate(withDuration: 0.5) {
            if isEditing {
                self.currentState = .full
            } else {
                self.currentState = .partial
                self.view.endEditing(isEditing)
            }
            self.moveView(state: self.currentState)
        }
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

    private func moveView(panGestureRecognizer recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let endedY = view.frame.minY + translation.y
        
        if (endedY >= fullViewYPosition) && (endedY <= minimumViewYPosition) {
            view.frame = CGRect(x: 0, y: endedY, width: view.frame.width, height: view.frame.height)
            recognizer.setTranslation(CGPoint.zero, in: view)
        }
    }

    private func nextState(_ recognizer: UIPanGestureRecognizer) -> State {
        let endedY = view.frame.minY + recognizer.translation(in: view).y
        let velocity = recognizer.velocity(in: view).y
        
        switch endedY {
        case ...partialViewYPosition:
            if velocity >= 0 {
                return .partial
            } else {
                return .full
            }
        default:
            if velocity >= 0 {
                return .minimum
            } else {
                return .partial
            }
        }
    }
    
    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        moveView(panGestureRecognizer: recognizer)
        if recognizer.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction]) {
                self.moveView(state: self.nextState(recognizer))
            }
            
            self.view.endEditing(true)
        }
    }
}
