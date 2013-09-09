These Matlab scripts compute your heart rate over time from a video of your fingertip captured with your smartphone. To get good results, you must press the camera lens gently. Make sure that your fingertip covers the lens completely. If your phone has a torch next to the lens, turn it on so it illuminates your fingertip and makes the image brighter (without causing a white image because of sensor saturation).

These are the sources accompanying the blog post ["Measuring heart rate with a smartphone camera"](http://www.ignaciomellado.es/blog/Measuring-heart-rate-with-a-smartphone-camera) at [uavster.com](http://uavster.com). For further information on how the code works, please read the article.

**How to use the Matlab scripts**

Compute the brightness signal from a video:
brightness = acquire('path to the video file');

Then, process the signal:
process(brightness);

A plot will open and you will see an animation of the estimated heart rate over time.
