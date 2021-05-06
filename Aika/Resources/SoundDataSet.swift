import UIKit

/**
  A dataset is a list of all training or testing images and their true labels.
 */
class SoundDataset {
  enum Split {
    case train
    case test

    var folderName: String {
      self == .train ? "train" : "test"
    }
  }

  let split: Split

  // When adding new images, we'll resize them so their smallest side
  // is this number of pixels.
  let smallestSide = 256

  private let baseURL: URL
  private var examples: [(String, String)] = []   // (filename, label)

  init(split: Split) {
    self.split = split
    baseURL = applicationDocumentsDirectory.appendingPathComponent(split.folderName)
    createDatasetFolder()
    scanAllSoundFiles()
    createBuiltinLabelFolders()
  }

  /**
    Creates the folder for this dataset, if it doesn't exist yet.
  */
  private func createDatasetFolder() {
    print("Path for \(split): \(baseURL)")
    createDirectory(at: baseURL)
  }

  /**
    Creates a subfolder for a label, if it doesn't exist yet.
   */
  func createFolder(for label: String) {
    createDirectory(at: labelURL(for: label))
  }

  /**
    Reads the names of all the image files in the label's subfolder.
   */
  private func scanSoundFiles(for label: String) {
    let url = labelURL(for: label)
    let filenames = fileURLs(at: url).map { $0.lastPathComponent }
    let labels = [String](repeating: label, count: filenames.count)
    examples.append(contentsOf: zip(filenames, labels))
  }

  /**
    Reads the names of all the image files in all the label subfolders.
   */
  private func scanAllSoundFiles() {
    examples = []
    for label in labels.labelNames {
      scanSoundFiles(for: label)
    }
  }

  private func createBuiltinLabelFolders() {
    for label in labels.builtinLabelNames {
      createFolder(for: label)
    }
  }

  /**
    Returns a list of all the JPG and PNG images in the specified folder.
   */
  private func fileURLs(at url: URL) -> [URL] {
    contentsOfDirectory(at: url) { url in
      url.pathExtension == "m4a"
    }
  }

  private func labelURL(for label: String) -> URL {
    baseURL.appendingPathComponent(label)
  }

  private func imageURL(for label: String, filename: String) -> URL {
    labelURL(for: label).appendingPathComponent(filename)
  }

  private func imageURL(for example: (String, String)) -> URL {
    imageURL(for: example.1, filename: example.0)
  }

  /** Returns the local file URL for the specified example's image. */
  func imageURL(at index: Int) -> URL {
    imageURL(for: examples[index])
  }

  /** Returns the label name for the specified example. */
  func label(at index: Int) -> String { examples[index].1 }

  /** The number of examples in this dataset. */
  var count: Int { examples.count }

  /**
    Returns the indices of the images having a certain label.
   */
  func images(withLabel label: String) -> [Int] {
    examples.indices.filter { self.label(at: $0) == label }
  }
}

// MARK: - UI stuff

extension SoundDataset {
  /**
    Returns the UISound for the specified example. This is only for displaying
    inside the UI, not for training or evaluation.
  */
  func image(at index: Int) -> URL? {
    imageURL(at: index)
  }
}

// MARK: - Mutating the dataset

extension SoundDataset {
    
    func addImage(_ fileName: String, for label: String) {
        examples.append((fileName, label))
    }
    
    func generateFileUrl(fileName: String,spesification: String) -> URL {
        let path = baseURL.appendingPathComponent(spesification).appendingPathComponent(fileName)
        return path as URL
    }
    
    func removeSound(at index: Int) {
        removeIfExists(at: imageURL(at: index))
        examples.remove(at: index)
    }
}
