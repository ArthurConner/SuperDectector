### AVFoundation

AVFoundation is the framework that lets you access the video camera, `AVCaptureVideoDataOutput`, and display the results, `AVCaptureVideoDataOutput`, on the screen, `AVCaptureVideoPreviewLayer`. In between is the glue called `AVSession` which can hook up these inputs and outputs

The basic initialization process is to create a session, set the presets such as image quality, create the inputs and outputs, and then add them to the session. Starting the session will send the images to the screen which is cool. Most of the time you want to intercept these images and the way to do that is by setting an object,`CameraViewController` to be the `AVCaptureVideoDataOutputSampleBufferDelegate` for the session. Now this object will get sample buffers to process for the video feed.

The advantage of this architecture is that different inputs and outputs can be swapped in. For instance the front camera is different than back and can be exchanged. Also instead of showing to the screen you can write to a file.

The framework has been in several versions prior to iOS 11, and while some of the apis have changed the basics remain the same.
