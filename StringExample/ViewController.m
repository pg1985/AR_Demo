//
//  ViewController.m
//  StringExample
//
//  Created by Patrick Guffey on 10/26/13.
//  Copyright (c) 2013 Patrick Guffey. All rights reserved.
//

#import "ViewController.h"
#import "StringOGL.h"
#import "EAGLView.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface ViewController () <StringOGLDelegate> {
    float _projectionMatrix[16];
}
@property (nonatomic,strong) StringOGL * stringOGL;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    EAGLContext *aContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES1];
    if(!aContext)
    {
        NSLog(@"Failed to create ES Context!");
    }
    else if(![EAGLContext setCurrentContext:aContext])
    {
        NSLog(@"Failed to set ES context current!");
    }
    
    EAGLView *eaglView = (EAGLView *)[self view];
    [eaglView setContext:aContext];
    [eaglView setFrameBuffer];
    
    int viewport[4] = {0,0,[eaglView frameBufferWidth],[eaglView frameBufferHeight]};
    viewport[1] = ([eaglView frameBufferHeight] - viewport[3])/2;
    glViewport(viewport[0], viewport[1], viewport[2],viewport[3]);
    
    float aspectRatio = viewport[2] / (float)viewport[3];
    [self createProjectionMatrix:_projectionMatrix verticalFOV:47.22f aspectRatio:aspectRatio nearClip:0.1f farClip:100.f];
    
    _stringOGL = [[StringOGL alloc] initWithDelegate:self context:aContext frameBuffer:[eaglView defaultFrameBuffer] leftHanded:NO];
    
    [_stringOGL setProjectionMatrix:_projectionMatrix viewport:viewport orientation:[self interfaceOrientation] reorientIPhoneSplash:YES];

    [_stringOGL loadImageMarker:@"Marker" ofType:@"png"];
        
}

- (void) createProjectionMatrix:(float *)matrix verticalFOV:(float)verticalFOV aspectRatio:(float)aspectRatio nearClip:(float)nearClip farClip:(float)farClip
{
    memset(matrix,0,sizeof(* matrix) * 16);
    float tan = tanf(verticalFOV * M_PI/360.f);
    matrix[0] = 1.f/(tan * aspectRatio);
    matrix[5] = 1.f/tan;
    matrix[10] = (farClip + nearClip)/(nearClip - farClip);
    matrix[11] = -1.f;
    matrix[14] = (2.f * farClip * nearClip)/(nearClip - farClip);
}

- (void) render {} //only needs to exist for implementation, doesn't need to actually do anything here.

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
