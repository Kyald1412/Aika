import UIKit

/**
 Organizes the images from an SoundDataset grouped by their labels.
 
 This is used by the "Training Data" and "Test Data" screens, as well as the
 "Train k-Nearest Neighbors" screen.
 */
class SoundsByLabel {
    let generatedFileName = UUID().uuidString + ".m4a"
    let dataset: SoundDataset
    private var groups: [String: [Int]] = [:]
    
    init(dataset: SoundDataset) {
        self.dataset = dataset
        updateGroups()
    }
    
    private func updateGroups() {
        groups = [:]
        for label in labels.labelNames {
            
            print(dataset.images(withLabel: label))
            groups[label] = dataset.images(withLabel: label)

        }
        print(groups)

    }
    
    var numberOfLabels: Int { labels.labelNames.count }
    
    func labelName(of group: Int) -> String { labels.labelNames[group] }
    
    func numberOfSounds(for label: String) -> Int {
        groups[label]!.count
    }
    
    func sound(for label: String, at index: Int) -> URL? {
        dataset.image(at: flatIndex(for: label, at: index))
    }
    
    func addSound(_ image: URL, for label: String) {
        dataset.addImage(image.lastPathComponent, for: label)
        
        // The new image is always added at the end, so we can simply append
        // the new index to the group for this label.
//        print(groups)
        groups[label]!.append(dataset.count - 1)
    }
    
    func removeSound(for label: String, at index: Int) {
        dataset.removeSound(at: flatIndex(for: label, at: index))
        
        // All the image indices following the deleted image are now off by one,
        // so recompute all the groups.
        updateGroups()
    }
    
    func flatIndex(for label: String, at index: Int) -> Int {
        groups[label]![index]
    }
}
