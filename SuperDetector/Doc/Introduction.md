
Apple’s  AI architecture is one of abstraction. Their apis in general hide details until you drop a layer down which correspondently hides the layer beneath it. This gives the advantage of working a top level concepts or low level optimizations depending on how you are approaching the problem.

Not everyone structures this way - google’s tensor flow is a labyrinth of tinker toys so much that keras was a welcome addition.

The difficulty of Apple approach is that much is left as black boxes where you know how to use a particular structure but no idea on how it is optimized to perform. For instance with iOS 11 they have released a new face land mark detection model, but there is no mention of how it actually works.

Still the advantage of pealing through the layers is a good way to descend in the Apple AI stack and this piece will look at the top two AVFoundation and Vision in the Superdetector project that can be found [here](https://github.com/ArthurConner/SuperDectector/tree/master).

### AVFoundation

AVFoundation is the framework that lets you access the video camera, `AVCaptureVideoDataOutput`, and display the results, `AVCaptureVideoDataOutput`, on the screen, `AVCaptureVideoPreviewLayer`. In between is the glue called `AVSession` which can hook up these inputs and outputs

The basic initialization process is to create a session, set the presets such as image quality, create the inputs and outputs, and then add them to the session. Starting the session will send the images to the screen which is cool. Most of the time you want to intercept these images and the way to do that is by setting an object,`CameraViewController` to be the `AVCaptureVideoDataOutputSampleBufferDelegate` for the session. Now this object will get sample buffers to process for the video feed.

The advantage of this architecture is that different inputs and outputs can be swapped in. For instance the front camera is different than back and can be exchanged. Also instead of showing to the screen you can write to a file.

The framework has been in several versions prior to iOS 11, and while some of the apis have changed the basics remain the same.

### Vision

Vision is top level of the new iOS 11 machine learning stack. It is the glue that goes between an image and underyling model. It also provides a few prebaked models and in the case of the project `VNDetectFaceLandmarksRequest` is used.

The top level object `VNImageRequestHandler` main function is to send requests like our face landmark request an image. The request has a callback handler which asychnously gives the results back which in our case is a series of points as to where the facial features are.

However configuring this handler wasn't as boilerplate as the foundation case. There were two issues with image orientation. The first is sensibly that you have to give the face detector the correct way up is pointing since it is very bad at determining upside down faces. The second was that you had to flip the image in the case of the front camera since what is shown on screen is actually a mirror image which is what we are used to seeing.

With these two image transforms in place the face detection worked well. But we shall see in the next piece there was a bit of math to make sense of the results.





