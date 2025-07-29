//
//  FileUtils.swift
//  IOSCommon
//
//  Created by Tanglei on 2024/9/6.
//

import Foundation

public enum FileSavePos: Int {
    case tmp = 0
    case doc = 1
}

public enum ImageType: String {
    case png = ".png"
    case jpg = ".jpg"
}

public enum MimeType: String {
    case text = "text"
    case image = "image"
    case video = "video"
}

public enum FileError: Error {
    case invalidName(String)
    case notFound(String)
    case createAlbum(String)
}

fileprivate let TAG = "FileUtils"

public class FileUtils: NSObject {
    
    public class func getFileSize(atPath path: String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: path)
            if let fileSize = fileAttributes[.size] as? UInt64 {
                return fileSize
            } else {
                return 0
            }
        } catch {
            LogUtil.e(tag: "FileUtils", "Error: \(error)")
            return 0
        }
    }

    
    
    // MARK: - Image IO
    
    public class func saveImage(image: UIImage, imageType: ImageType, savePos: FileSavePos, fileName: String?, compressionQuality: CGFloat = 0.8, callback: ((Bool, URL?)-> Void)?) {
        
        var data: Data?
        let ext = imageType.rawValue
        if imageType == .png {
            data = image.pngData()
        } else if imageType == .jpg {
            data = image.jpegData(compressionQuality: compressionQuality)
        }
        
        if let imageData = data {
            let fileName = fileName ?? (FileUtils.randomString(length: 24) + ext)
            
            let fileURL = ({
                if savePos == .tmp {
                    return UrlUtils.getTmpUrl().appendingPathComponent(fileName)
                } else {
                    return UrlUtils.getDocumentUrl().appendingPathComponent(fileName)
                }
            })()
            
            DispatchQueue.global().async {
                do {
                    try imageData.write(to: fileURL)
                    if let cb = callback { cb(true, fileURL) }
                } catch {
                    LogUtil.e(tag: TAG, "Error saving image: \(error)")
                    if let cb = callback { cb(false, nil) }
                }
            }
        } else {
            if let cb = callback { cb(false, nil) }
        }
    }
    
    public class func saveImageAsync(image: UIImage, imageType: ImageType, savePos: FileSavePos, fileName: String?, compressionQuality: CGFloat = 0.8) async -> URL? {
        await withCheckedContinuation { contin in
            FileUtils.saveImage(image: image, imageType: imageType, savePos: savePos, fileName: fileName) { success, url in
                contin.resume(returning: url)
            }
        }
    }
    
    public class func loadImageFromRes(relativePath: String, callback: @escaping (UIImage?)-> Void) {
        guard let resUrl = Bundle.main.resourcePath else {
            callback(nil)
            return
        }
        
        let fileAbsPath = relativePath.hasPrefix("/") ? relativePath : "/\(relativePath)"
        let absURL = URL(fileURLWithPath: resUrl + fileAbsPath)
        
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: absURL) {
                if let image = UIImage(data: imageData) {
                    // 这里可以使用 image 对象进行后续操作
                    callback(image)
                    return
                }
            } else {
                LogUtil.e(tag: "FileUtils", "invalid image url: \(absURL)")
            }
            callback(nil)
        }
    }
    
    public class func loadImageFromResAsync(relativePath: String) async -> UIImage? {
        await withCheckedContinuation { contin in
            loadImageFromRes(relativePath: relativePath, callback: {
                contin.resume(returning: $0)
            })
        }
    }
    
    private class func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    public class func checkFreeDiskSpace(needed minRequiredSpaceInBytes: Int64 = 10_000_000_000)-> Bool {
        let fileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfFileSystem(forPath: FileManager.default.currentDirectoryPath)
            if let freeSize = attributes[.systemFreeSize] as? NSNumber {
                let freeSpaceInBytes = freeSize.int64Value
                return freeSpaceInBytes >= minRequiredSpaceInBytes
            }
        } catch {
            LogUtil.e(tag: TAG, "Error checking free disk space: \(error)")
        }
        return true
    }
}
