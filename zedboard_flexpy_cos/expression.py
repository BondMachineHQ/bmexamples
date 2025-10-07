from sympy import *
x = Symbol('x', real=True)
symbols = [x]
testRanges = {'real: x': list(np.arange(-5,5,0.1)),
    'imag: x': list(np.arange(-5,5,2)),
    }
with evaluate(False):
    spExpr = cos(x) 
