//
//  CCColorSquare.m
//  CCFramework
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "CCColorSquare.h"
#import "CCColor.h"
#import "CCColorIndicator.h"
#import "CCInsetView.h"
#import "CCShader.h"
#import "CCUtilities.h"
#import "UIView+Frame.h"
#import "gl_matrix.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>


@interface CCColorSquare ()

@property(nonatomic, assign) GLint backingWidth;
@property(nonatomic, assign) GLint backingHeight;

@property(nonatomic, assign) GLuint colorRenderbuffer;
@property(nonatomic, assign) GLuint defaultFramebuffer;

@property(nonatomic, strong) CCColorIndicator *indicator;

@end

@implementation CCColorSquare

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (instancetype)init
{
    if (self =  [super init]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    // Get the layer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = NO;
    eaglLayer.drawableProperties = @{ kEAGLDrawablePropertyRetainedBacking : @NO,
                                      kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8 };
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!_context || ![EAGLContext setCurrentContext:_context])
        return;
    
    // Create system framebuffer object. The backing will be allocated in -reshapeFramebuffer
    glGenFramebuffersOES(1, &_defaultFramebuffer);
    glGenRenderbuffersOES(1, &_colorRenderbuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _defaultFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
    
    self.multipleTouchEnabled = YES;
    self.contentMode = UIViewContentModeCenter;
    self.exclusiveTouch = YES;
    
    CCInsetView *insetView = [[CCInsetView alloc] initWithFrame:self.bounds];
    [self addSubview:insetView];
    
    _indicator = [[CCColorIndicator alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    _indicator.sharpCenter = CCCenterOfRect(self.bounds);
    _indicator.opaque = NO;
    [self addSubview:_indicator];
}


- (GLuint)quadVAO
{
    if (!_quadVAO) {
        float width = CGRectGetWidth(self.bounds);
        float height = CGRectGetHeight(self.bounds);
        
        CGPoint corners[4];
        corners[0] = CGPointMake(0, 0);
        corners[1] = CGPointMake(width, 0);
        corners[2] = CGPointMake(width, height);
        corners[3] = CGPointMake(0, height);
        
        const GLfloat quadVertices[] = {
            corners[0].x, corners[0].y, 0.0, 0.0,
            corners[1].x, corners[1].y, 1.0, 0.0,
            corners[3].x, corners[3].y, 0.0, 1.0,
            corners[2].x, corners[2].y, 1.0, 1.0,
        };
        
        // create and bind VAO
        glGenVertexArraysOES(1, &_quadVAO);
        glBindVertexArrayOES(_quadVAO);
        
        // create, bind, and populate VBO
        glGenBuffers(1, &_quadVBO);
        glBindBuffer(GL_ARRAY_BUFFER, _quadVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 16, quadVertices, GL_STATIC_DRAW);
        
        // set up attrib pointers
        glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (void *)0);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 4, (void *)8);
        glEnableVertexAttribArray(1);
        
        // unbind buffers
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArrayOES(0);
    }
    
    return _quadVAO;
}

- (CCShader *)colorShader
{
    if (!_colorShader) {
        NSArray *attributes = @[ @"inPosition", @"inTexcoord" ];
        NSArray *uniforms = @[ @"modelViewProjectionMatrix", @"hue" ];
        
        _colorShader = [[CCShader alloc] initWithVertexShader:@"blit" fragmentShader:@"colorPicker"
                                              attributesNames:attributes
                                                 uniformNames:uniforms];
    }
    
    return _colorShader;
}

- (void)drawView
{
    [EAGLContext setCurrentContext:self.context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // handle viewing matrices
    GLfloat proj[16];
    // setup projection matrix (orthographic)
    mat4f_LoadOrtho(0, _backingWidth, 0, _backingHeight, -1.0f, 1.0f, proj);
    
    // use shader program
    CCShader *colorShader = self.colorShader;
    glUseProgram(colorShader.program);
    glUniformMatrix4fv([colorShader locationForUniform:@"modelViewProjectionMatrix"], 1, GL_FALSE, proj);
    glUniform1f([colorShader locationForUniform:@"hue"], self.color.hue);
    
    glBindVertexArrayOES(self.quadVAO);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // unbind VAO
    glBindVertexArrayOES(0);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)reshapeFramebuffer
{
    // Allocate color buffer backing based on the current layer size
    [_context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer *)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, _colorRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &_backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &_backingHeight);
    
    [EAGLContext setCurrentContext:_context];
}

- (void)layoutSubviews
{
    [self reshapeFramebuffer];
    [self drawView];
}

- (void)dealloc
{
    // make sure our context is active before we delete stuff
    [EAGLContext setCurrentContext:_context];
    
    // free buffers
    glDeleteVertexArraysOES(1, &_quadVAO);
    glDeleteBuffers(1, &_quadVBO);
    
    // free shaders
    
    [EAGLContext setCurrentContext:nil];
}

- (CGRect)trackRect
{
    return CGRectInset(self.bounds, 5, 5);
}

- (CGPoint)indicatorPosition
{
    CGPoint result;
    
    result.x = _saturation * CGRectGetWidth(self.trackRect);
    result.y = CGRectGetHeight(self.trackRect) - (_brightness * CGRectGetHeight(self.trackRect));
    
    result = CCAddPoints(result, self.trackRect.origin);
    
    return result;
}

- (void)setColor:(CCColor *)color
{
    BOOL hueChanged = (_color.hue == color.hue) ? NO : YES;
    
    _color = color;
    _saturation = color.saturation;
    _brightness = color.brightness;
    _indicator.color = color;
    
    _indicator.sharpCenter = [self indicatorPosition];
    
    if (hueChanged) {
        // redraw once at the end of the run loop
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(drawView) withObject:nil afterDelay:0];
    }
}

- (void)computeValueForTouch:(UITouch *)touch
{
    CGPoint pt = [touch locationInView:self];
    
    pt.x = CCClamp(CGRectGetMinX(self.trackRect), CGRectGetMaxX(self.trackRect), pt.x);
    pt.y = CCClamp(CGRectGetMinY(self.trackRect), CGRectGetMaxY(self.trackRect), pt.y);
    
    _saturation = (pt.x - CGRectGetMinX(self.trackRect)) / CGRectGetWidth(self.trackRect);
    _brightness = (pt.y - CGRectGetMinY(self.trackRect)) / CGRectGetHeight(self.trackRect);
    _brightness = 1.0f - _brightness; // flip brightness
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self computeValueForTouch:touch];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    _indicator.sharpCenter = [self indicatorPosition];
    [UIView commitAnimations];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self computeValueForTouch:touch];
    _indicator.sharpCenter = [self indicatorPosition];
    
    return [super continueTrackingWithTouch:touch withEvent:event];
}


@end
