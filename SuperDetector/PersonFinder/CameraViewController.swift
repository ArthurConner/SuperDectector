import UIKit
import AVKit
import AVFoundation
import Vision

class CameraViewController:UIViewController {
    
    @IBOutlet var  previewView:PreviewView!
    
  
    var session: AVCaptureSession?
    var videoOutput : AVCaptureVideoDataOutput?
    let videoQueue = DispatchQueue(label: "videoQueue")
    
    var heroIndex:Int = -1
    var faceViews:[DetectedFaceView] = []
    var isFront = true
    
    var handler:VNImageRequestHandler?
    
    lazy var frontCamera:AVCaptureDevice? = {
        let cams = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        return cams.devices.first
        
    }()
    
    lazy var backCamera:AVCaptureDevice? = {
        let cams = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        return cams.devices.first
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = AVCaptureSession()
        toggle()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(toggle))
        session?.startRunning()
        
    }
    
    @objc func toggle(){
        
        guard let _ = session?.inputs.first else {
            configure(position: .front)
            return
        }
        
        if isFront {
            configure(position: .back)
        } else {
            configure(position: .front)
        }
        
        isFront = !isFront
    }
    
    func configure(position: AVCaptureDevice.Position){
        
        guard let session = session else { return }
        
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.photo
        videoOutput = AVCaptureVideoDataOutput()
        guard let videoOutput = videoOutput else {
            print("stillImageOutput should be non null")
            return
        }
        
        var camera:AVCaptureDevice?
        if position == .front {
            camera = frontCamera ?? backCamera
        } else {
            camera = backCamera ?? frontCamera
        }
        
        guard let  device = camera else {
            print("no camera")
            return
        }
        
        for x in session.inputs{
            if x != camera {
                session.removeInput(x)
            } else {
                return
            }
        }
        
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.outputs.isEmpty && session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        session.commitConfiguration()
        previewView.session = session
        
    }
    
    lazy var faceRequest:VNDetectFaceLandmarksRequest = {
        return VNDetectFaceLandmarksRequest(completionHandler: self.handleFaces)
    }()
    
    
    func handleFaces(request: VNRequest, error: Error?) {
        
        guard let observations = request.results as? [VNFaceObservation]
            else { fatalError("unexpected result type from VNDetectRectanglesRequest") }
        
        guard !(observations.isEmpty) else {
            
            DispatchQueue.main.async {
                for view in self.faceViews{
                    view.disable()
                }
            }
            self.handler = nil
            return
            
        }
        
        DispatchQueue.main.async {
            for view in self.faceViews{
                view.disable()
            }
            
            for i in 0..<observations.count {
                
                let detectedRectangle = observations[i]
                
                if i >= self.faceViews.count {
                    let v = DetectedFaceView(frame: CGRect(x: 1, y: 1, width: 0, height: 0))
                    v.load(index:self.heroIndex)
                    self.previewView.addSubview(v)
                    self.faceViews.append(v)
                    
                }
                
                let v = self.faceViews[i]
                v.enable(detected: detectedRectangle)
                
            }
            
            self.handler = nil
        }
        
    }
    
}

extension CameraViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func imageFrom(buffer:CVPixelBuffer)->CIImage {
        let attachments: [String : Any]?  = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, buffer, kCMAttachmentMode_ShouldPropagate) as! [String : Any]?
        let ciImage = CIImage(cvImageBuffer: buffer, options: attachments ).oriented(.right)
        if !(isFront) {
            return ciImage
        }
        
        return ciImage.transformed(by: CGAffineTransform(scaleX: -1,y: 1)).transformed(by: CGAffineTransform(translationX: ciImage.extent.size.width,y: 0))
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        
        guard self.handler == nil else {
            return
        }
        
        if let pixelBuffer : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            
            let ciImage = imageFrom(buffer:pixelBuffer)
            /*
            DispatchQueue.main.async {
                self.pipView.image = UIImage(ciImage: ciImage)
            }
 */
            
            let opt:[VNImageOption:Any] = [:]
            let h = VNImageRequestHandler(ciImage: ciImage, options: opt)
            self.handler = h

            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try h.perform([self.faceRequest])
                } catch {
                    print(error)
                }
            }
            
        } else {
            print("no buffer")
        }
    }
}



