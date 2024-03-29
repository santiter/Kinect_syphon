// Point Cloud with Syphon Support - edited from Daniel Shiffman's example:
// Daniel Shiffman
// Kinect Point Cloud example
// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// add syphon library
import codeanticode.syphon.*;

// Kinect Library object
Kinect kinect;
PGraphics canvas;
SyphonServer server;

// Angle for rotation
float a = 0;

// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];

void settings() {
  size(800,600, P3D);
  PJOGL.profile=1;
}

void setup() {
  // Rendering in P3D
  size(800, 600, P3D);
  canvas = createGraphics(800, 600, P3D);
  
  kinect = new Kinect(this);
  kinect.initDepth();
  server = new SyphonServer(this, "Processing Syphon");
  
  // Lookup table for all possible depth values (0 - 2047)
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
}

void draw() {
  canvas.beginDraw();
  canvas.background(0,0,0,0); // This will make a transparent background
  //canvas.background(0); // This will make a black background

  // Get the raw depth as array of integers
  int[] depth = kinect.getRawDepth();

  // We're just going to calculate and draw every 4th pixel (equivalent of 160x120)
  int skip = 4;

  // Translate and rotate
  canvas.translate(width/2, height/2, -50);
  canvas.rotateY(a);

  for (int x = 0; x < kinect.width; x += skip) {
    for (int y = 0; y < kinect.height; y += skip) {
      int offset = x + y*kinect.width;

      // Convert kinect data to world xyz coordinate
      int rawDepth = depth[offset];
      PVector v = depthToWorld(x, y, rawDepth);

      canvas.stroke(255);
      canvas.pushMatrix();
      
      // Scale up by 200
      float factor = 500;
      canvas.translate(v.x*factor, v.y*factor, factor-v.z*factor);
      
      // Draw a point
      canvas.point(0,0);
      canvas.popMatrix();
    }
  }

  // Rotate
  //a += 0.005f; //This  makes the rotation of the canvas
  canvas.endDraw();
  image(canvas, 0, 0);
  server.sendImage(canvas);
}

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector depthToWorld(int x, int y, int depthValue) {

  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
  
}
