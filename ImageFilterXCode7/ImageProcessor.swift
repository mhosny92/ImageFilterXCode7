//
//  ImageProcessor.swift
//  ImageFilter
//
//  Created by Mahmoud Hosny on 11/26/17.
//  Copyright © 2017 Mahmoud Hosny. All rights reserved.
//

import Foundation
import UIKit

class ImageProcessor {
    
    static let shared = ImageProcessor()
    
    private init(){
        avgRed = 0
        avgGreen = 0
        avgBlue = 0
    }
    
    
    var avgRed: Int
    var avgBlue: Int
    var avgGreen: Int
    private var imgWidth: Int?
    private var imgHeight: Int?
    
    var image: UIImage?
    
    func prepareImageForProcessing(image: UIImage){
        self.image = image
        setAvgValuesForImage()
    }
    
    private func setAvgValuesForImage() {
        let imgRGBA = RGBAImage(image: self.image!)!
        self.imgWidth = imgRGBA.width
        self.imgHeight = imgRGBA.height
        
        var totalRed = 0
        var totalBlue = 0
        var totalGreen = 0
        
        for i in 0..<imgRGBA.width{
            for j in 0..<imgRGBA.height{
                let index = i * imgRGBA.height + j
                totalRed += Int(imgRGBA.pixels[index].red)
                totalBlue += Int(imgRGBA.pixels[index].blue)
                totalGreen += Int(imgRGBA.pixels[index].green)
                
            }
        }
        
        let totalPixels = imgRGBA.width * imgRGBA.height
        self.avgRed = Int(totalRed/totalPixels)
        self.avgBlue = Int(totalBlue/totalPixels)
        self.avgGreen = Int(totalGreen/totalPixels)
        
    }
    func modifyRedishValue(alpha: Int=5)->UIImage?{
        if let img = self.image {
            var imgRGBA = RGBAImage(image: img)!
            var pixel = imgRGBA.pixels
            for i in 0..<imgRGBA.height*imgRGBA.width{
                let redDiff: Int = Int(pixel[i].red)-self.avgRed
                let val: Int = Int(self.avgRed)+redDiff*alpha
                if redDiff < 0{
                    pixel[i].red = UInt8(max(0,min(255,val)))
                }
            }
            imgRGBA.pixels = pixel
            return imgRGBA.toUIImage()
        }
        return nil
    }
    
    func addGhostyToImage(x: Int=300, y: Int=300)->UIImage?{
        if let img = self.image where x > 0 && x < self.imgWidth && y > 0 && y < self.imgHeight {
            var imgRGBA = RGBAImage(image: img)!
            let ghosty = UIImage(named: "ghost_tiny")!
            let ghostyRGBA = RGBAImage(image: ghosty)!
            var imgRGBAPixels = imgRGBA.pixels
            var ghostyPixels = ghostyRGBA.pixels
            var imgRGBAIndexToAddGhosty: Int = x * 75 + y
            
            for i in 0..<ghostyRGBA.height{
                for j in 0..<ghostyRGBA.width{
                    var ghostyPixel = ghostyPixels[i*ghostyRGBA.height+j]
                    var imgRGBAPixel = imgRGBAPixels[imgRGBAIndexToAddGhosty+j]
                    
                    let ghostyAlpha = 0.5 * (Double(ghostyPixel.alpha) / 255.0)
                    var newRed = Double(imgRGBAPixel.red) * (1.0-ghostyAlpha) + Double(ghostyPixel.red) * ghostyAlpha
                    var newBlue = Double(imgRGBAPixel.blue) * (1.0-ghostyAlpha) + Double(ghostyPixel.blue) * ghostyAlpha
                    var newGreen = Double(imgRGBAPixel.green) * (1.0-ghostyAlpha) + Double(ghostyPixel.green) * ghostyAlpha
                    
                    newRed = max(0,min(255, newRed));
                    newGreen = max(0,min(255, newGreen));
                    newBlue = max(0,min(255, newBlue));
                    imgRGBAPixel.red = UInt8(newRed)
                    imgRGBAPixel.green = UInt8(newGreen)
                    imgRGBAPixel.blue = UInt8(newBlue)
                    
                    imgRGBAPixels[imgRGBAIndexToAddGhosty+j] = imgRGBAPixel
                }
                imgRGBAIndexToAddGhosty+=75
                
            }
            imgRGBA.pixels = imgRGBAPixels
            return imgRGBA.toUIImage()
            
        }
        return nil
    }
    
    func turnToGrayColor()->UIImage?{
        if let img = self.image {
            var imgRGBA = RGBAImage(image: img)!
            var pixels = imgRGBA.pixels
            for i in 0..<imgRGBA.height*imgRGBA.width{
                let avg = UInt8((Double(pixels[i].red)+Double(pixels[i].blue)+Double(pixels[i].green))/3.0)
                pixels[i].red = avg; pixels[i].blue = avg; pixels[i].green = avg
            }
            imgRGBA.pixels = pixels
            return imgRGBA.toUIImage()
        }
        return nil
    }
    
    func adjustBrightness(by value: Int8=50)->UIImage?{
        if let img = self.image {
            var imgRGBA = RGBAImage(image: img)!
            var pixels = imgRGBA.pixels
            for i in 0..<imgRGBA.height*imgRGBA.width{
                
                pixels[i].red = UInt8(max(0, min(255,Int(pixels[i].red)+Int(value))))
                pixels[i].blue = UInt8(max(0, min(255,Int(pixels[i].blue)+Int(value))))
                pixels[i].green = UInt8(max(0, min(255,Int(pixels[i].green)+Int(value))))
            }
            imgRGBA.pixels = pixels
            return imgRGBA.toUIImage()
        }
        return nil
    }
    
    func adjustContrast(by value: UInt8=200)->UIImage?{
        if let img = self.image {
            var imgRGBA = RGBAImage(image: img)!
            var pixels = imgRGBA.pixels
            for i in 0..<imgRGBA.height*imgRGBA.width{
                if pixels[i].red > value{
                    pixels[i].red = value
                }
                if pixels[i].blue > value{
                    pixels[i].blue = value
                }
                if pixels[i].green > value{
                    pixels[i].green = value
                }
            }
            imgRGBA.pixels = pixels
            return imgRGBA.toUIImage()
        }
        return nil
    }
}
