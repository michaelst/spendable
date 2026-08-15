// Encodes a directory of PNG frames into an H.264 mp4 with AVFoundation, so no ffmpeg is needed.
// Usage: swift encode.swift <frame-dir> <out.mp4> <fps>
import AVFoundation
import AppKit
import Foundation

let arguments = CommandLine.arguments
guard arguments.count >= 4 else {
  print("usage: encode.swift <frame-dir> <out.mp4> <fps>")
  exit(1)
}

let frameDirectory = arguments[1]
let outputURL = URL(fileURLWithPath: arguments[2])
let framesPerSecond = Int32(arguments[3]) ?? 8

let frameNames = try FileManager.default
  .contentsOfDirectory(atPath: frameDirectory)
  .filter { $0.hasSuffix(".png") }
  .sorted()

guard let firstName = frameNames.first,
      let firstImage = NSImage(contentsOfFile: "\(frameDirectory)/\(firstName)"),
      let firstBitmap = firstImage.representations.first
else {
  print("no readable PNG frames in \(frameDirectory)")
  exit(1)
}

let width = firstBitmap.pixelsWide
let height = firstBitmap.pixelsHigh

try? FileManager.default.removeItem(at: outputURL)

let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
let input = AVAssetWriterInput(
  mediaType: .video,
  outputSettings: [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height
  ]
)
input.expectsMediaDataInRealTime = false

let adaptor = AVAssetWriterInputPixelBufferAdaptor(
  assetWriterInput: input,
  sourcePixelBufferAttributes: [
    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
    kCVPixelBufferWidthKey as String: width,
    kCVPixelBufferHeightKey as String: height
  ]
)

writer.add(input)
writer.startWriting()
writer.startSession(atSourceTime: .zero)

func pixelBuffer(for path: String) -> CVPixelBuffer? {
  guard let image = NSImage(contentsOfFile: path),
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
  else { return nil }

  var buffer: CVPixelBuffer?
  CVPixelBufferCreate(
    kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB,
    [kCVPixelBufferCGImageCompatibilityKey: true, kCVPixelBufferCGBitmapContextCompatibilityKey: true] as CFDictionary,
    &buffer
  )
  guard let buffer else { return nil }

  CVPixelBufferLockBaseAddress(buffer, [])
  let context = CGContext(
    data: CVPixelBufferGetBaseAddress(buffer),
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
  )
  context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
  CVPixelBufferUnlockBaseAddress(buffer, [])
  return buffer
}

var index: Int32 = 0
for name in frameNames {
  while !input.isReadyForMoreMediaData { usleep(5000) }
  guard let buffer = pixelBuffer(for: "\(frameDirectory)/\(name)") else { continue }
  adaptor.append(buffer, withPresentationTime: CMTime(value: CMTimeValue(index), timescale: framesPerSecond))
  index += 1
}

input.markAsFinished()
let done = DispatchSemaphore(value: 0)
writer.finishWriting { done.signal() }
done.wait()

if writer.status == .completed {
  print("WROTE \(outputURL.path) frames=\(index) fps=\(framesPerSecond)")
} else {
  print("FAILED \(writer.error?.localizedDescription ?? "unknown")")
  exit(1)
}
