import CVips
import Foundation
import VipsWrapper

public struct VipsError: Error {
    public let message: String
}

public class Vips {
    private(set) static var started = false
    public static func initialize() {
        if !started {
            vips_init([])
        }
        started = true
    }
    public static func shutdown() {
        if started {
            vips_shutdown()
        }
    }
    
    public static var leakCheck = false {
        didSet {
            vips_leak_set(leakCheck ? 1 : 0)
        }
    }
    
    public static var maxCacheMem: Int {
        set {
            vips_cache_set_max_mem(newValue)
        }
        get {
            vips_cache_get_max_mem()
        }
    }
    
    public static var maxCacheSize: Int32 {
        set {
            vips_cache_set_max(newValue)
        }
        get {
            vips_cache_get_max()
        }
    }
    
    public static var version: String {
        let major = Int(vips_version(0))
        let minor = Int(vips_version(1))
        let patch = Int(vips_version(2))
        return "\(major).\(minor).\(patch)"
    }
    
    public static var trackedAllocs: Int32 {
        return vips_tracked_get_allocs()
    }
    
    public static var trackedMem: Int {
        return vips_tracked_get_mem()
    }
}


public class VImage {
    
    private var imagePtr: UnsafeMutablePointer<VipsImage>
    private var image: VipsImage {
        return imagePtr.pointee
    }
    private var premultiplicationBand: VipsBandFormat? = nil
    
    
    public var width: Int32 {
        return image.Xsize
    }
    
    public var height: Int32 {
        return image.Ysize
    }
    
    public var hasAlphaChannel: Bool {
        return vips_image_hasalpha(imagePtr) != 0
    }
    
    deinit {
        g_object_unref(imagePtr)
    }
    
    public init(from data: Data) throws {
        if !Vips.started {
            Vips.initialize()
        }
        let out = try data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> UnsafeMutablePointer<VipsImage>? in
            guard let baseAddress = bytes.baseAddress else {
                throw VipsError(message: "Failed to get pointer to underlying data")
            }
            return vips_image_new_from_buffer_wrapper(baseAddress, data.count, nil)
        }
        
        guard let img = out else {
            throw VipsError(message: "Failed to dereference image data")
        }
        self.imagePtr = img
    }
    
    func setImage(_ newImage: UnsafeMutablePointer<VipsImage>) {
        g_object_unref(imagePtr)
        imagePtr = newImage
    }
    
    public func resize(scale: Double) throws {
        
        try premultiplyAlpha()
        
        var outputImagePtr: UnsafeMutablePointer<VipsImage>?

        if vips_resize_wrapper(imagePtr, &outputImagePtr, scale) != 0 {
            throw VipsError(message: "Failed to resize image")
        }
        
        if let outImage = outputImagePtr {
            setImage(outImage)
        }
        
        try unpremultiplyAlpha()
    }
    
    public func premultiplyAlpha() throws {
        if premultiplicationBand != nil || !hasAlphaChannel {
            return
        }
        var outputImagePtr: UnsafeMutablePointer<VipsImage>?
        premultiplicationBand = image.BandFmt
        
        if vips_premultiply_wrapper(imagePtr, &outputImagePtr) != 0 {
            throw VipsError(message: "Failed to premultiply")
        }
        
        if let outImage = outputImagePtr {
            setImage(outImage)
        }
    }
    
    public func unpremultiplyAlpha() throws {
        guard let premultiplicationBand = premultiplicationBand else {
            return
        }
        var outputImagePtr: UnsafeMutablePointer<VipsImage>?
        
        if vips_unpremultiply_wrapper(imagePtr, &outputImagePtr) != 0 {
            throw VipsError(message: "Failed to unpremultiply")
        }
        
        var finalOut: UnsafeMutablePointer<VipsImage>?
        if vips_cast_wrapper(outputImagePtr, &finalOut, premultiplicationBand) != 0 {
            throw VipsError(message: "Failed cast")
        }
        
        g_object_unref(outputImagePtr)
        
        if let outImage = finalOut {
            self.premultiplicationBand = nil
            setImage(outImage)
        }
    }
    
    public func toJpeg(quality: Int32 = 100) throws -> Data {
        var outBuffer: UnsafeMutableRawPointer? = nil
        var outBufferSize = 0
        
        guard vips_jpegsave_buffer_wrapper(imagePtr, &outBuffer, &outBufferSize, quality) == 0 else {
            throw VipsError(message: "Failed to convert to jpeg")
        }
        
        
        if let buffer = outBuffer, outBufferSize > 0 {
            let data = Data(bytesNoCopy: buffer,
                            count: outBufferSize,
                            deallocator: .custom({ (ptr, _) in
                g_free(ptr)
            }))
            return data
        } else {
            throw VipsError(message: "Buffer was empty or 0")
        }
    }
    
    public func toPng(compression: Int32 = 0) throws -> Data {
        if compression > 9 {
            throw VipsError(message: "Compression must be in the ragne 0...9")
        }
        var outBuffer: UnsafeMutableRawPointer? = nil
        var outBufferSize = 0
        
        guard vips_pngsave_buffer_wrapper(imagePtr, &outBuffer, &outBufferSize, compression) == 0 else {
            throw VipsError(message: "Failed to convert to png")
        }
        
        
        if let buffer = outBuffer, outBufferSize > 0 {
            let data = Data(bytesNoCopy: buffer,
                            count: outBufferSize,
                            deallocator: .custom({ (ptr, _) in
                g_free(ptr)
            }))
            return data
        } else {
            throw VipsError(message: "Buffer was empty or 0")
        }
    }
}
    
