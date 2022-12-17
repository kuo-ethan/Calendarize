//
//  HabitsVC.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import Foundation
import UIKit

class HabitsVC: UIViewController {
    
    var commitmentGroups: [HeaderItem] = []
    
    var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<Section, ListItem>!
    
    enum Section {
        case main
    }
    
    enum ListItem: Hashable {
        case header(HeaderItem)
        case instance(InstanceItem)
    }
    
    // Header cell data type
    struct HeaderItem: Hashable {
        let title: String
        let instances: [InstanceItem]
    }
    
    // Symbol cell data type
    struct InstanceItem: Hashable, Identifiable {
        
        let id = UUID() // Just to enable same instance descriptions
        
        let text: String
        let image: UIImage
        
        init(text: String, sfSymbolName: String) {
            self.text = text
            self.image = UIImage(systemName: sfSymbolName)!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        title = "Habits"
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(didTapBackButton))
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didTapAddButton))
        // backButton.tintColor = .primary
        // addButton.tintColor = .primary
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = addButton
        
        // Set layout to collection view
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        layoutConfig.backgroundColor = .white
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        // collectionView.tintColor = .primary
        view.addSubview(collectionView)
        
        // Make collection view take up the entire view
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 0.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
        ])
        
        let headerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, HeaderItem> {
            (cell, indexPath, headerItem) in
            
            // Set headerItem's data to cell
            var content = cell.defaultContentConfiguration()
            content.text = headerItem.title
            cell.contentConfiguration = content
            
            // Add outline disclosure accessory
            // With this accessory, the header cell's children will expand / collapse when the header cell is tapped.
            let headerDisclosureOption = UICellAccessory.OutlineDisclosureOptions(style: .header)
            cell.accessories = [.outlineDisclosure(options:headerDisclosureOption)]
        }
        
        let instanceCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, InstanceItem> {
            (cell, indexPath, symbolItem) in
            
            // Set symbolItem's data to cell
            var content = cell.defaultContentConfiguration()
            content.image = symbolItem.image
            content.text = symbolItem.text
            cell.contentConfiguration = content
            // cell.tintColor = .primary
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, ListItem>(collectionView: collectionView) {
            (collectionView, indexPath, listItem) -> UICollectionViewCell? in
            
            switch listItem {
            case .header(let headerItem):
                // Get header cell
                let cell = collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: headerItem)
                return cell
                
            case .instance(let instanceItem):
                // Get symbol cell
                let cell = collectionView.dequeueConfiguredReusableCell(using: instanceCellRegistration, for: indexPath, item: instanceItem)
                return cell
            }
        }
        
        reloadExpandableCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Coming back from adding commitments
        var headerItems: [HeaderItem] = []
        
        // Authentication current user should be fully updated via listener
        // However, at sign up launch, currentUser might be nil but will soon be linked.
        guard let currentUser = Authentication.shared.currentUser else { return }
        
        for commitmentType in currentUser.habits {
            let currentType = commitmentType.type
            var instanceItems: [InstanceItem] = []
            func sortPredicate(_ a: HabitInstance, _ b: HabitInstance) -> Bool {
                return a.dayOfWeek.rawValue < b.dayOfWeek.rawValue
            }
            let instancesSortedByDay = commitmentType.instances.sorted(by: sortPredicate)
            
            for instance in instancesSortedByDay {
                // For each instance, need 1) morning, afternoon, evening 2) Day of week and duration
                // MARK: Decided to omit duration for simplicity
                let dayOfWeek = INDEX_TO_DAY[instance.dayOfWeek.rawValue]
                let duration = Utility.durationInSecondsToStringifiedHoursAndMinutes(instance.duration)
                let startHour = instance.dayInterval.startTime.hour
                var sfSymbolName: String!
                if startHour < 12 {
                    // Morning is from 12:00 AM to 11:59 AM
                    sfSymbolName = "sun.and.horizon"
                } else if startHour < 17 {
                    // Afternoon is from 12:00 PM to 4:59 PM
                    sfSymbolName = "sun.max"
                } else {
                    // Evening is from 5:00 PM to 11:59 PM
                    sfSymbolName = "moon"
                }
                
                instanceItems.append(InstanceItem(text: dayOfWeek + " " + duration, sfSymbolName: sfSymbolName))
            }
            
            headerItems.append(HeaderItem(title: currentType, instances: instanceItems))
        }
        
        commitmentGroups = headerItems
        
        reloadExpandableCollectionView()
    }
    
    private func reloadExpandableCollectionView() {
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ListItem>()

        // Create a section in the data source snapshot
        dataSourceSnapshot.appendSections([.main])
        dataSource.apply(dataSourceSnapshot)

        // Create a section snapshot for main section
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()

        for headerItem in commitmentGroups {
           
            // Create a header ListItem & append as parent
            let headerListItem = ListItem.header(headerItem)
            sectionSnapshot.append([headerListItem])
            
            // Create an array of symbol ListItem & append as children of headerListItem
            let instanceListItemArray = headerItem.instances.map { ListItem.instance($0) }
            sectionSnapshot.append(instanceListItemArray, to: headerListItem)
            
            // Expand this section by default
            sectionSnapshot.expand([headerListItem])
        }
        
        // Apply section snapshot to main section
        dataSource.apply(sectionSnapshot, to: .main, animatingDifferences: false)
    }
    
    @objc func didTapAddButton() {
        navigationController?.pushViewController(HabitEditorVC(), animated: true)
    }
    
    @objc func didTapBackButton() {
        // add habits array into firestore for the current user
        
        navigationController?.popViewController(animated: true)
    }
}
