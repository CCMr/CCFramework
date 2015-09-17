//
//  Evaluate.h
//  Evaluate
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


#import "Evaluate.h"

@implementation BezierEvaluator

- (id)initWithFirst:(double)newFirst second:(double)newSecond
{
	self = [super init];
	if (self != nil)
	{
		firstControlPoint = newFirst;
		secondControlPoint = newSecond;
	}
	return self;
}

- (double)evaluateAt:(double)position
{
	return
		// (1 - position) * (1 - position) * (1 - position) * 0.0 +
		3 * position * (1 - position) * (1 - position) * firstControlPoint +
		3 * position * position * (1 - position) * secondControlPoint +
		position * position * position * 1.0;
}

@end

@implementation ExponentialDecayEvaluator

- (id)initWithCoefficient:(double)newCoeff
{
	self = [super init];
	if (self != nil)
	{
		coeff = newCoeff;
		offset = exp(-coeff);
		scale = 1.0 / (1.0 - offset);
	}
	return self;
}

- (double)evaluateAt:(double)position
{
	return 1.0 - scale * (exp(position * -coeff) - offset);
}

@end

@implementation SecondOrderResponseEvaluator

- (id)initWithOmega:(double)newOmega zeta:(double)newZeta
{
	self = [super init];
	if (self != nil)
	{
		omega = newOmega;
		zeta = newZeta;
	}
	return self;
}

- (double)evaluateAt:(double)position
{
	double beta = sqrt(1 - zeta * zeta);
	double phi = atan(beta / zeta);
	double result = 1.0 + -1.0 / beta * exp(-zeta * omega * position) * sin(beta * omega * position + phi);
	return result; 
}

@end

