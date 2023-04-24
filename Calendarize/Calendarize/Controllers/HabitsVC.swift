//
//  HabitsVC.swift
//  Calendarize
//
//  Created by Ethan Kuo on 12/15/22.
//

import Foundation
import UIKit

class HabitsVC: UIViewController {
    
    var habitGroups: [HeaderItem] = []
    
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
    struct InstanceItem: Hashable {
        
        // let id = UUID() // Just to enable same instance descriptions
        
        // let text: String
        let dayOfWeek: String
        let timeWindowDescription: String
        let duration: String
        let image: UIImage
        let associatedHabitType: String
        let associatedHabitID: UUID
        
        init(dayOfWeek: String, timeWindowDescription: String, duration: String, withImage sfSymbol: UIImage, forHabitType habitType: String, associatedHabitID: UUID) {
            // self.text = text
            self.dayOfWeek = dayOfWeek
            self.timeWindowDescription = timeWindowDescription
            self.duration = duration
            self.image = sfSymbol
            self.associatedHabitType = habitType
            self.associatedHabitID = associatedHabitID
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        title = "Habits"
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(didTapBackButton))
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(didTapAddButton))
        
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = addButton
        
        // Set layout to collection view
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        layoutConfig.backgroundColor = .white
        
        // Define right-to-left swipe action
        layoutConfig.leadingSwipeActionsConfigurationProvider = { [unowned self] (indexPath) in
            
            // Configure swipe action here
            guard let item = dataSource.itemIdentifier(for: indexPath) else {
                fatalError("Failed to retrieve habit instance item for swipe action")
            }
            
            // Create action (deletion)
            let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
                
                self.handleSwipe(for: action, item: item)
                completion(true)
            }
            deleteAction.backgroundColor = .primary
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: listLayout)
        collectionView.delegate = self
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
            content.text = "\(symbolItem.dayOfWeek), \(symbolItem.duration)"
            content.secondaryText = symbolItem.timeWindowDescription
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
        super.viewWillAppear(animated)
        
        // Coming back from adding habit
        refreshCollectionView()
        
    }
    
    private func refreshCollectionView() {
        
        var headerItems: [HeaderItem] = []
        
        // Authentication current user should be fully updated via listener
        // However, at sign up launch, currentUser might be nil but will soon be linked.
        guard let currentUser = Authentication.shared.currentUser else { return }

        for habitType in currentUser.habits.keys {
            let currentType = habitType
            var instanceItems: [InstanceItem] = []
            
            let instancesSortedByDay = currentUser.habits[habitType]!.sorted { a, b in
                return a.dayOfWeek.rawValue < b.dayOfWeek.rawValue
            }
            
            for instance in instancesSortedByDay {
                // MARK: Decided to omit duration for simplicity
                let dayOfWeek = INDEX_TO_DAY[instance.dayOfWeek.rawValue]
                let duration = Utility.minutesToStringifiedHoursAndMinutes(instance.minutes)
                let startHour = instance.dayInterval.startTime.hour
                var sfSymbolName: String!
                if startHour < 12 {
                    // Morning is from 12:01 AM to 11:59 AM
                    sfSymbolName = "sun.and.horizon"
                } else if startHour < 17 {
                    // Afternoon is from 12:00 PM to 4:59 PM
                    sfSymbolName = "sun.max"
                } else {
                    // Evening is from 5:00 PM to 12:00 AM
                    sfSymbolName = "moon"
                }
                let timeInterval = "\(instance.dayInterval.startTime.toString()) - \(instance.dayInterval.endTime.toString())"
                instanceItems.append(InstanceItem(dayOfWeek: dayOfWeek, timeWindowDescription: timeInterval, duration: duration, withImage: UIImage(systemName: sfSymbolName)!, forHabitType: habitType, associatedHabitID: instance.id))
            }
            
            headerItems.append(HeaderItem(title: currentType, instances: instanceItems))
        }
        
        habitGroups = headerItems
        
        reloadExpandableCollectionView()
    }
    
    private func reloadExpandableCollectionView() {
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ListItem>()

        // Create a section in the data source snapshot
        dataSourceSnapshot.appendSections([.main])
        dataSource.apply(dataSourceSnapshot)

        // Create a section snapshot for main section
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()

        for headerItem in habitGroups {
           
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

extension HabitsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// For swipe deletion
private extension HabitsVC {
    
    func handleSwipe(for action: UIContextualAction, item: ListItem) {
        // MARK: To-do
        // When deleting a habit instance, need to remote it from currentUser.
        // This means that each ListItem must contain a reference to their corresponding object
        // HeaderItem -> Habit
        // InstanceItem -> HabitInstance
        // Then remove item.reference from currentUser, and reload the collection view.
        // May abstract out the reloading code from viewWillAppear and call that method
        let currentUser = Authentication.shared.currentUser!
        print("CURRENT ITEM: ", item)
        switch item {
        case .header(let headerItem):
            // Remove an entire habit group
            for habitType in currentUser.habits.keys {
                if headerItem.title == habitType {
                    // Remove all habits under habit type
                    print("Removing a habit group")
                    currentUser.habits.removeValue(forKey: habitType)
                    Database.shared.updateUser(currentUser, nil)
                }
            }
        case .instance(let instanceItem):
            // Remove a single habit instance
            let habitType = instanceItem.associatedHabitType
            let indexOfHabitToDelete = currentUser.habits[habitType]!.firstIndex { habit in
                instanceItem.associatedHabitID == habit.id
            }
            guard let indexOfHabitToDelete = indexOfHabitToDelete else {
                fatalError("Instance item does not correspond to an existing habit")
            }
            print("Removing a habit instance")
            currentUser.habits[habitType]!.remove(at: indexOfHabitToDelete)
            Database.shared.updateUser(currentUser, nil)
        }
        
        refreshCollectionView()
    }
}

