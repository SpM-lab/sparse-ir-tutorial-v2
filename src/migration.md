## Migration from sparse-ir/SparseIR.jl version 1 to version 2

Version 2 has changed the internal implementation to C++, but most of the interfaces remain unchanged.
The following points have changed as exceptions:

- The domain of the basis functions $U(\tau)$ have been extended from $[0, \beta]$ to $[-\beta, \beta]$ instead of $[0, \beta]$. The fermionic basis functions are anti-periodic, while the bosonic basis functions are periodic. If you use the logistic kernel (default), the fermionic and bosonic basis functions are identical in $(0, \beta)$, while they have opposite signs in $(-\beta, 0)$. To keep consistency with the previous version, $U_l(\beta)$ and $U_l(-\beta)$ evaluate to the values at $\beta-0$ and $-\beta+0$, respectively. The value at $-0$ can be evaluated by $U_l(-0)$. See the following example code.

- The $\tau$ sampling points are now defined in $[-\beta/2, \beta/2]$ instead of $[0, \beta]$. The distribution of the sampling points is symmetric with respect to $0$. This change has been introduced for preparing a future introduction of zero-temperature basis functions. You can switch to the previous behavior by setting `use_positive_taus=True` when initializing a `TauSampling` object or a `FiniteTempBasisSet` object. This will affect some diagrammatic calculations, e.g., second order perturbation theory: $G(\tau)G(\beta-\tau) = - G(\tau)G(-\tau)$. See the following example code:

```Python
# Version 1: G(tau) * G(beta-tau)
gtau * gtau[::-1]

# Version 2: G(tau) * G(-tau)
-gtau * gtau[::-1]
```