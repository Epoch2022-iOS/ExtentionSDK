//
//  BKBKCommonTool.swift
//  ExtentionSDK
//
//  Created by 清风徐来 on 2023/5/15.
//

import Foundation
import UIKit

struct BKCommonTool {
    
    /// 拨打电话
    /// - Parameters:
    ///   - number: 电话号码
    ///   - errorBlock: 错误的回调
    static func call(_ number: String, _ errorBlock: ((_ errDes: String) -> Void)?) {
        if number.isEmpty {
            errorBlock?("号码不能为空")
            return
        }
        let tel = "tel://" + number
        guard let url = URL(string: tel.removeAllSpace) else { return }
        self.openURL(url) {
            errorBlock?("你的设备不支持打电话")
            return
        }
    }
    
    
    /// 打开链接
    /// - Parameters:
    ///   - url: 链接地址
    ///   - errBlock: 错误回调
    static func openURL(_ url: URL, errBlock: (() -> Void)? = nil) {
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            errBlock?()
        }
    }
    
    /// 跳转App系统设置
    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        self.openURL(url)
    }
    
}

// MARK: - 获取自定义Bundle路径
extension BKCommonTool {
    
    enum BundleName: String {
        case Lottie
        case Gif
    }
    
    /// 获取自定义Bundle路径
    /// - name: 自定义bundle的名称
    /// - Returns: 自定义Bundle路径
    static func getCustomBundle(name: BundleName) -> Bundle {
        guard let path = Bundle.main.path(forResource: name.rawValue, ofType: "bundle") else { return Bundle.main }
        let _bundle = Bundle(path: path)
        return _bundle ?? Bundle.main
    }
    
}

// MARK: - Utils for Dictionary
extension BKCommonTool {
    
    /// 替换源字典的key
    /// - Parameter dic: 源字典 [String: Any]
    /// - Parameter mapArray: 数组 [[oldkey : newKey]]
    static func replaceDictionaryKeys(_ dic: [String: Any], by mapArray: [[String: String]]) -> [String: Any] {
        var newDic = dic
        // 遍历mapArray
        mapArray.forEach { (mapDic) in
            
            mapDic.forEach { (mapKey, mapValue) in
                // mapKey: 将被替换的key, mapValue: 新key
                // 遍历源字典
                dic.forEach { (dKey, dValue) in
                    if mapKey == dKey {
                        newDic[mapValue as String] = dValue
                        newDic.removeValue(forKey: dKey)
                    }
                }
            }
        }
        return newDic
    }
    
}


// MARK: - Utils for Clean Cache
extension BKCommonTool {
    
    /// 获取缓存大小
    /// - Parameter completionHandler: 结果回调
    static func fileSizeOfCache(completionHandler: @escaping (_ size: String) -> Void) {
        
        // 取出cache文件夹目录 缓存文件都在这个目录下
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
        // 取出文件夹下所有文件数组
        guard let fileArr = FileManager.default.subpaths(atPath: cachePath) else { return }
        
        let manager = FileManager.default
        
        // 开启子线程
        DispatchQueue.global().async {
            
            // 快速枚举出所有文件名 计算文件大小
            var size = 0
            for file in fileArr {
                // 把文件名拼接到路径中
                let path = cachePath + "/\(file)"
                // 取出文件属性
                let floder = try! manager.attributesOfItem(atPath: path)
                
                // 用元组取出文件大小属性
                for (key, value) in floder {
                    // 累加文件大小
                    if key == FileAttributeKey.size {
                        size += (value as AnyObject).integerValue
                    }
                }
            }
            
            // 换算
            var str: String = ""
            var realSize: Int = size
            if realSize < 1024 {
                str = str.appendingFormat("%dB", realSize)
            } else if size >= 1024 && size < 1024 * 1024 {
                realSize = realSize / 1024
                str = str.appendingFormat("%dKB", realSize)
            } else if size >= 1024 * 1024 && size < 1024 * 1024 * 1024 {
                realSize = realSize / 1024 / 1024
                str = str.appendingFormat("%dM", realSize)
            }
            
            DispatchQueue.main.async {
                completionHandler(str)
            }
        }
        
    }
    
    /// 清空缓存
    /// - Parameter completionHandler: 结果回调
    static func clearCache(completionHandler: @escaping () -> Void) {
        
        // 取出cache文件夹目录 缓存文件都在这个目录下
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
        // 取出文件夹下所有文件数组
        guard let fileArr = FileManager.default.subpaths(atPath: cachePath) else { return }
        
        let manager = FileManager.default
        // 开启子线程
        DispatchQueue.global().async {
            
            for file in fileArr {
                let path = cachePath + "/\(file)"
                if manager.fileExists(atPath: path) {
                    do {
                        try manager.removeItem(atPath: path)
                    } catch {
                        
                    }
                }
            }
            
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    
}
