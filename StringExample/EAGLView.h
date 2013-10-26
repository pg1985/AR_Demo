//
//  EAGLView.h
//  StringExample
//
//  Created by Patrick Guffey on 10/26/13.
//  Copyright (c) 2013 Patrick Guffey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface EAGLView : UIView
//context is the 'current state' of OpenGL
@property (nonatomic,strong) EAGLContext *context;
@property (nonatomic, assign,readonly) GLuint defaultFrameBuffer;
@property (nonatomic, assign, readonly) GLint frameBufferWidth;
@property (nonatomic,assign,readonly) GLint frameBufferHeight;

- (void) setFrameBuffer;

@end
