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
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet var cancelButton: UIButton!
    
    enum Section {
        case main
    }

    weak var delegate: DetailViewControllerDelegate?
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, ManagedPOI>?

    private var southWest: LatLng = .zero
    private var northEast: LatLng = .zero
    private let performFetchQueue = DispatchQueue.init(label: "coredata")

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

    var prevClickedCell: DetailCollectionViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureGesture()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
           moveView(state: .minimum)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureButton()
    }

    @IBOutlet weak var contentView: UIView!
    private var switchButton: UIButton!

    private func configureButton() {
        switchButton = UIButton()
        switchButton.imageView?.contentMode = .scaleAspectFill
        switchButton.setImage(UIImage(named: "minimum"), for: .normal)
        switchButton.layer.cornerRadius = 5.0
        switchButton.translatesAutoresizingMaskIntoConstraints = false

        guard let superView = view.superview else { return }

        superView.addSubview(switchButton)

        NSLayoutConstraint.activate([
            switchButton.widthAnchor.constraint(equalToConstant: 20),
            switchButton.heightAnchor.constraint(equalToConstant: 30),
            switchButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            switchButton.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -20)
        ])

        switchButton.addTarget(self, action: #selector(toggle), for: .touchDown)
    }

    @objc private func toggle() {
            switch self.currentState {
            case .full:
                return
            case .minimum:
                self.moveView(state: .partial)
                return
            case .partial:
                self.moveView(state: .minimum)
                return
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

    func reloadPOI(southWest: LatLng = .zero, northEast: LatLng = .zero, _ searchText: String = "") {
        let subpredicates = makeSubPredicates(southWest: southWest, northEast: northEast, searchText)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: subpredicates)

        fetchedResultsController?.fetchRequest.predicate = predicate

        performFetchQueue.async { [weak self] in
            try? self?.fetchedResultsController?.performFetch()
            self?.updateSnapshot()
        }
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
        let pois = fetchedResultsController?.fetchedObjects ?? []
        snapshot.appendSections([.main])
        snapshot.appendItems(pois, toSection: .main)
        diffableDataSource?.apply(snapshot)
        DispatchQueue.main.async {
            self.updateResultCount(count: pois.count)
        }
    }
    
    func updateResultCount(count: Int) {
        resultLabel.text = "\(count)개"
    }
    
    @IBAction func cancelButtonTouched(_ sender: Any) {
        reloadPOI()
        searchBar.text = ""
        searchViewEditing(false)
        self.view.endEditing(true)
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
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
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
        searchViewEditing(false)
    }
}

extension DetailViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadPOI(searchText)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchViewEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        reloadPOI()
    }

    func searchViewEditing(_ isEditing: Bool) {
            if isEditing {
                self.currentState = .full
            } else {
                self.currentState = .partial
            }
            self.moveView(state: self.currentState)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: Pan Gesture
extension DetailViewController {
    var fullViewYPosition: CGFloat { 44 }
    var partialViewYPosition: CGFloat { UIScreen.main.bounds.height - 200 }
    var minimumViewYPosition: CGFloat { UIScreen.main.bounds.height - minimumHeight }
    var minimumHeight: CGFloat { searchBar.frame.height + 44  }

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
            switchButton?.isHidden = false
            switchButton?.setImage(UIImage(named: "minimum"), for: .normal)
            setCancelButtonEnable(false)
        case .partial:
            yPosition = partialViewYPosition
            switchButton?.isHidden = false
            switchButton?.setImage(UIImage(named: "partial"), for: .normal)
            setCancelButtonEnable(false)
        case .full:
            yPosition = fullViewYPosition
            switchButton?.isHidden = true
            setCancelButtonEnable(true)
        }
        UIView.transition(with: view, duration: 0.5, options: .curveEaseOut) {
            self.view.frame = CGRect(x: 0, y: yPosition, width: self.view.frame.width, height: self.view.frame.height)
            self.switchButton?.frame = self.view.bounds
        }
//
//
//        UIView.animate(withDuration: 0.5) {
//            self.view.frame = CGRect(x: 0, y: yPosition, width: self.view.frame.width, height: self.view.frame.height)
//        }
        currentState = state
    }

    private func setCancelButtonEnable(_ isEnable: Bool) {
        cancelButton.isUserInteractionEnabled = isEnable
        cancelButton.setTitleColor(isEnable ? .black : .gray, for: .normal)
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
    
    private func distance(y: CGFloat, to state: State) -> CGFloat {
        var destination: CGFloat!
        
        switch state {
        case .minimum:
            destination = minimumViewYPosition
        case .partial:
            destination = partialViewYPosition
        case .full:
            destination = fullViewYPosition
        }
        
        return destination - y
    }
    
    @objc private func panGesture(_ recognizer: UIPanGestureRecognizer) {
        moveView(panGestureRecognizer: recognizer)
        if recognizer.state == .ended {
            let nextState = self.nextState(recognizer)
            let endedY = view.frame.minY + recognizer.translation(in: view).y
            let distance = self.distance(y: endedY, to: nextState)
            var duration = abs(distance / recognizer.velocity(in: view).y)
            
            // 애니메이션이 너무 길어서 지루하게 느끼지 않도록 최대 값 설정
            duration = (duration > 1) ? 1 : duration
            
            UIView.animate(withDuration: TimeInterval(duration), delay: 0, options: [.allowUserInteraction]) {
                self.moveView(state: self.nextState(recognizer))
            }
            
            self.view.endEditing(true)
        }
    }
    
}
