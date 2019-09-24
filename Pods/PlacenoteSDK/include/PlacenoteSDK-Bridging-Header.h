//
//  PlacenoteSDK-Bridging-Header.h
//  Shape Dropper (Placenote SDK iOS Sample)
//
//  Created by Prasenjit Mukherjee on 2017-09-01.
//  Copyright © 2017 Vertical AI. All rights reserved.

#ifndef PLACENOTE_SDK_BRIDGE
#define PLACENOTE_SDK_BRIDGE

#include <stdio.h>
#include <stdlib.h>
#include "libPlacenote.h"
#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <SceneKit/SceneKit.h>

enum Status{INVALID, GOOD, BAD, DELETED};

void initializeSDK(const char* apiKey, const char* mapPath, const char* appBasePath, void* swiftContext, result_callback cb)
{
  PNInitParams params;

  params.apiKey = apiKey;
  params.appBasePath = appBasePath;
  params.mapPath = mapPath;

  PNInitialize (&params, cb, swiftContext); 
}


void setIntrinsicsNative(int width, int height, matrix_float3x3 calibMat)
{
  PNCameraInstrinsics intrinsics;
  intrinsics.width = width;
  intrinsics.height = height;
  intrinsics.fx = calibMat.columns[0].x;
  intrinsics.fy = calibMat.columns[1].y;
  intrinsics.cx = calibMat.columns[2].x;
  intrinsics.cy = calibMat.columns[2].y;
  intrinsics.k1 = intrinsics.k2 = intrinsics.p1 = intrinsics.p2 = 0.0f;

  PNSetIntrinsics(&intrinsics);
}


void setFrameNative(CVPixelBufferRef frameBuffer, SCNVector3 position, SCNVector4 rotation)
{
  int yWidth = CVPixelBufferGetWidthOfPlane (frameBuffer, 0);
  int uvWidth = CVPixelBufferGetWidthOfPlane (frameBuffer, 1);
  int yHeight = CVPixelBufferGetHeightOfPlane(frameBuffer,0);
  int uvHeight = CVPixelBufferGetHeightOfPlane(frameBuffer,1);
  int yStride = CVPixelBufferGetBytesPerRowOfPlane (frameBuffer, 0);
  int uvStride = CVPixelBufferGetBytesPerRowOfPlane (frameBuffer, 1);

  unsigned long numBytesY = yStride * yHeight;
  unsigned long numBytesUV = uvStride * uvHeight;

  uint8_t* yPixelBytes = (uint8_t*)malloc(numBytesY);
  uint8_t* uvPixelBytes = (uint8_t*)malloc(numBytesUV);

  CVPixelBufferLockBaseAddress(frameBuffer, kCVPixelBufferLock_ReadOnly);

  unsigned long numBytes = CVPixelBufferGetBytesPerRowOfPlane (frameBuffer, 0) * CVPixelBufferGetHeightOfPlane(frameBuffer,0);
  void* baseAddressY = CVPixelBufferGetBaseAddressOfPlane(frameBuffer,0);
  memcpy(yPixelBytes, baseAddressY, numBytesY);
  void* baseAddressUV = CVPixelBufferGetBaseAddressOfPlane(frameBuffer,1);
  memcpy(uvPixelBytes, baseAddressUV, numBytesUV);
  CVPixelBufferUnlockBaseAddress(frameBuffer, 0);

  PNImagePlane yPlane, vuPlane;
  yPlane.buf = yPixelBytes;
  yPlane.width = yWidth;
  yPlane.height = yHeight;
  yPlane.stride = yStride;

  vuPlane.buf = uvPixelBytes;
  vuPlane.width = uvWidth;
  vuPlane.height = uvHeight;
  vuPlane.stride = uvStride;

  PNTransform arkitPose;
  arkitPose.position.x = position.x;
  arkitPose.position.y = position.y;
  arkitPose.position.z = position.z;
  arkitPose.rotation.x = rotation.x;
  arkitPose.rotation.y = rotation.y;
  arkitPose.rotation.z = rotation.z;
  arkitPose.rotation.w = rotation.w;

  PNSetFrame(&yPlane, &vuPlane, &arkitPose);
  free(yPixelBytes);
  free(uvPixelBytes);
}


PNTransform getPoseNative() {
  PNTransform pose;
  PNGetPose(&pose);
  return pose;
}


#endif  // PLACENOTE_SDK_BRIDGE


