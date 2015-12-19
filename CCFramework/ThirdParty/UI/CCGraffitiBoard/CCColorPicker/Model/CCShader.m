//
//  CCShader.m
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


#import "CCShader.h"

@implementation CCShader

-
(NSString *)keyValue:(NSString *)key
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"#ifdef GL_ES\nprecision highp float;\n#endif\n\nuniform mat4 modelViewProjectionMatrix;\n\n#if __VERSION__ >= 140\nin vec4  inPosition;  \nin vec2  inTexcoord;\nout vec2 varTexcoord;\n#else\nattribute vec4 inPosition;  \nattribute vec2 inTexcoord;\nvarying vec2 varTexcoord;\n#endif\n\nvoid main (void) \n{\n\tgl_Position\t= modelViewProjectionMatrix * inPosition;\n    varTexcoord = inTexcoord;\n}\n" forKey:@"blit"];
    [dic setObject:@"#ifdef GL_ES \nprecision highp float; \n#endif\n#if __VERSION__ >= 140\nin vec2      varTexcoord;\nout vec4     fragColor;\n#else\nvarying vec2 varTexcoord;\n#endif\nuniform float hue;\nvec3 HSLtoRGB(float h, float s, float v)\n{\nvec3 rgb;\nif (s == 0.0) {\nrgb = vec3(v);\n} else {\nfloat   f,p,q,t;\nint     i;\nh = mod(h * 6.0, 6.0);\nf = fract(h);\ni = int(h);\np = v * (1.0 - s);\nq = v * (1.0 - s * f);\nt = v * (1.0 - (s * (1.0 - f)));\nif (i == 0) {\nrgb = vec3(v,t,p);\n} else if (i == 1) {\nrgb = vec3(q,v,p);\n} else if (i == 2) {\nrgb = vec3(p,v,t);\n} else if (i == 3) {\nrgb = vec3(p,q,v);\n} else if (i == 4) {\nrgb = vec3(t,p,v);\n} else {\nrgb = vec3(v,p,q);\n}\n}\nreturn rgb;\n}\nvoid main (void)\n{\ngl_FragColor.rgb = HSLtoRGB(hue, varTexcoord.s, varTexcoord.t);\ngl_FragColor.a = 1.0;\n}" forKey:@"colorPicker"];
    
    return [dic objectForKey:key];
}


+ (CCShader *)shaderWithVertexShader:(NSString *)vertexShader
                      fragmentShader:(NSString *)fragmentShader
                     attributesNames:(NSArray *)attributeNames
                        uniformNames:(NSArray *)uniformNames
{
    CCShader *shader = [[CCShader alloc] initWithVertexShader:vertexShader
                                               fragmentShader:fragmentShader
                                              attributesNames:attributeNames
                                                 uniformNames:uniformNames];
    
    return shader;
}

- (id)initWithVertexShader:(NSString *)vertexShader
            fragmentShader:(NSString *)fragmentShader
           attributesNames:(NSArray *)attributeNames
              uniformNames:(NSArray *)uniformNames
{
    if (self = [super init]) {
        
        GLuint vertShader = 0, fragShader = 0;
        NSString *vertShaderPathname, *fragShaderPathname;
        
        // create shader program
        _program = glCreateProgram();
        
        // create and compile vertex shader
        //        vertShaderPathname = [[NSBundle mainBundle] pathForResource:vertexShader ofType:@"vsh"];
        vertShaderPathname = [self keyValue:vertexShader];
        if (!compileShader(&vertShader, GL_VERTEX_SHADER, 1, vertShaderPathname)) {
            destroyShaders(vertShader, fragShader, _program);
            return nil;
        }
        
        // create and compile fragment shader
        //        fragShaderPathname = [[NSBundle mainBundle] pathForResource:fragmentShader ofType:@"fsh"];
        fragShaderPathname = [self keyValue:fragmentShader];
        if (!compileShader(&fragShader, GL_FRAGMENT_SHADER, 1, fragShaderPathname)) {
            destroyShaders(vertShader, fragShader, _program);
            return nil;
        }
        
        // attach vertex shader to program
        glAttachShader(_program, vertShader);
        
        // attach fragment shader to program
        glAttachShader(_program, fragShader);
        
        // bind attribute locations; this needs to be done prior to linking
        [attributeNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            glBindAttribLocation(_program, (GLuint) idx, [obj cStringUsingEncoding:NSUTF8StringEncoding]);
        }];
        
        // link program
        if (!linkProgram(_program)) {
            destroyShaders(vertShader, fragShader, _program);
            return nil;
        }
        
        NSMutableDictionary *uniformMap = [[NSMutableDictionary alloc] initWithCapacity:uniformNames.count];
        for (NSString *uniformName in uniformNames) {
            GLuint location = glGetUniformLocation(_program, [uniformName cStringUsingEncoding:NSUTF8StringEncoding]);
            uniformMap[uniformName] = @(location);
        }
        _uniforms = uniformMap;
        
        // release vertex and fragment shaders
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
    }
    return self;
}

- (void)freeGLResources
{
    glDeleteProgram(_program);
}

- (void)dealloc
{
    glDeleteProgram(_program);
}

- (GLuint)locationForUniform:(NSString *)uniform
{
    NSNumber *number = _uniforms[uniform];
    return [number unsignedIntValue];
}

@end
