//
//  EAGLView.m
//  StringExample
//
//  Created by Patrick Guffey on 10/26/13.
//  Copyright (c) 2013 Patrick Guffey. All rights reserved.
//

#import "EAGLView.h"
@interface EAGLView ()
@property (nonatomic, assign) GLuint defaultFrameBuffer;
@property (nonatomic, assign) GLuint colorRenderbuffer;
@property (nonatomic, assign) GLuint depthBuffer;
@end

@implementation EAGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    //here, we are overwriting layerClass, in order to ensure our new layer is OpenGL enabled.
    CAEAGLLayer *layer = (CAEAGLLayer *)[self layer];
    [layer setOpaque:YES];
    [layer setDrawableProperties:@{kEAGLDrawablePropertyRetainedBacking:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8}];
}

- (void) setContext:(EAGLContext *)context
{
    if(_context != context)
    {
        [self deleteFrameBuffer];
        _context = context;
        [EAGLContext setCurrentContext:nil];
    }
}

- (void) deleteFrameBuffer
{
    //this has to be called every time a new context is set.  This following code clears the buffers
    if(_context)
    {
        [EAGLContext setCurrentContext:_context];
        
        if(_defaultFrameBuffer)
        {
            glDeleteFramebuffers(1,&_defaultFrameBuffer);
            _defaultFrameBuffer = 0;
        }
        if(_colorRenderbuffer)
        {
            glDeleteRenderbuffers(1, &_colorRenderbuffer);
            _colorRenderbuffer = 0;
        }
        if(_depthBuffer)
        {
            glDeleteRenderbuffers(1, &_depthBuffer);
            _depthBuffer = 0;
        }
        
    }
}

- (void) createFrameBuffer
{
    if(_context && !_defaultFrameBuffer)
    {
        if([self respondsToSelector:@selector(setContentScaleFactor:)])
        {
            float screenScale = [UIScreen mainScreen].scale;
            [self setContentScaleFactor:screenScale];
        }
        
        glGenFramebuffers(1,&_defaultFrameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFrameBuffer);
        
        glGenRenderbuffers(1, &_colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)[self layer]];
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
        
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_frameBufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_frameBufferHeight);
        
        glGenRenderbuffers(1, &_depthBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _depthBuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _frameBufferWidth, _frameBufferHeight);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthBuffer);
        
        
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER)!=GL_FRAMEBUFFER_COMPLETE)
        {
            NSLog(@"Failed to make complete framebuffer Object %x",glCheckFramebufferStatus(GL_FRAMEBUFFER));
        }
        
        
    }
}

- (void) setFrameBuffer
{
    if(_context)
    {
        [EAGLContext setCurrentContext:_context];
        
        if(!_defaultFrameBuffer)
        {
            [self createFrameBuffer];
        }
        
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFrameBuffer);
        glViewport(0, 0, _frameBufferWidth, _frameBufferHeight);
        
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
