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

- (void) render {
    
    static const GLfloat cubeVertices[] = {
        0.5f, -0.5f, -0.5f,
        0.5f, 0.5f, -0.5f,
        0.5f, -0.5f, 0.5f,
        0.5f, -0.5f, 0.5f,
        0.5f, 0.5f, -0.5f,
        0.5f, 0.5f, 0.5f,
        
        0.5f, 0.5f, -0.5f,
        -0.5f, 0.5f, -0.5f,
        0.5f, 0.5f, 0.5f,
        0.5f, 0.5f, 0.5f,
        -0.5f, 0.5f, -0.5f,
        -0.5f, 0.5f, 0.5f,
        
        -0.5f, 0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, 0.5f, 0.5f,
        -0.5f, 0.5f, 0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f, 0.5f,
        
        -0.5f, -0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f, 0.5f,
        -0.5f, -0.5f, 0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f, 0.5f,
        
        0.5f, 0.5f, 0.5f,
        -0.5f, 0.5f, 0.5f,
        0.5f, -0.5f, 0.5f,
        0.5f, -0.5f, 0.5f,
        -0.5f, 0.5f, 0.5f,
        -0.5f, -0.5f, 0.5f,
        
        0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        0.5f, 0.5f, -0.5f,
        0.5f, 0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, 0.5f, -0.5f,
    };
    
    static const GLubyte squareColors[] =
    {
     255,255,0,255,0,255,255,255,0,0,0,0,255,0,255,255,
    };
    
    //1 is used for maxMarkerCount because the demo we're using can only track one marker anyway.  This loop loop will run once per marker
    const int maxMarkerCount = 1;
    struct MarkerInfoMatrixBased markerInfo[1];
    int markerCount = [_stringOGL getMarkerInfoMatrixBased:markerInfo maxMarkerCount:maxMarkerCount];
    
    for(int i=0;i<markerCount;i++)
    {
     
    
        glMatrixMode(GL_PROJECTION);
        glLoadMatrixf(_projectionMatrix);
    
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
    
        glVertexPointer(3, GL_FLOAT, 0, cubeVertices);
        glEnableClientState(GL_VERTEX_ARRAY);
    
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
        glEnableClientState(GL_COLOR_ARRAY);
    
        glTranslatef(0.0, 0.0, -5);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 36);
    }
} //only needs to exist for implementation, doesn't need to actually do anything here, at least until later.

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startAnimation];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopAnimation];
}

- (void) startAnimation
{
    [_stringOGL resume];
}

- (void) stopAnimation
{
    [_stringOGL pause];
}

- (BOOL) shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
