import dill
from sympy import *

rx_1_1 = Symbol('rx_1_1', real=False)
rx_1_2 = Symbol('rx_1_2', real=False)
rz_1_1 = Symbol('rz_1_1', real=False)
rz_1_2 = Symbol('rz_1_2', real=False)
symbols = [rx_1_1, rx_1_2, rz_1_1, rz_1_2]

testRanges = {'real: rx_1_1': list(np.arange(-1,1,1)),
                'real: rx_1_2': list(np.arange(-1,1,1)),
                'real: rz_1_1': list(np.arange(-1,1,1)),
                'real: rz_1_2': list(np.arange(-1,1,1)),
                'imag: rx_1_1': list(np.arange(-1,1,1)),
                'imag: rx_1_2': list(np.arange(-1,1,1)),
                'imag: rz_1_1': list(np.arange(-1,1,1)),
                'imag: rz_1_2': list(np.arange(-1,1,1))
            }

sm = dill.load(open("expression.pickle","rb"))

with evaluate(False):
    spExpr = sm
