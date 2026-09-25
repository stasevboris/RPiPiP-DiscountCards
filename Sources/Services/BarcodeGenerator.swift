import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

public protocol BarcodeGenerating {
    func makeBarcodeImage(from code: String, format: BarcodeFormat, targetSize: CGSize) -> UIImage?
}

public struct CoreImageBarcodeGenerator: BarcodeGenerating {
    private let context = CIContext(options: [.useSoftwareRenderer: true])
    
    public init() {}
    
    public func makeBarcodeImage(from code: String, format: BarcodeFormat, targetSize: CGSize) -> UIImage? {
        let clean = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty, let data = clean.data(using: .ascii) else { return nil }
        
        let filter: CIFilter?
        switch format {
        case .code128, .ean13:
            let f = CIFilter.code128BarcodeGenerator()
            f.message = data
            filter = f
        case .qr:
            let f = CIFilter.qrCodeGenerator()
            f.message = data
            f.correctionLevel = "M"
            filter = f
        }
        
        guard let output = filter?.outputImage else { return nil }
        let scaleX = targetSize.width / output.extent.width
        let scaleY = targetSize.height / output.extent.height
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
