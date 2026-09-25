## Migration from sparse-ir/SparseIR.jl version 1 to version 2

Version 2 has changed the internal implementation to C++, but most of the interfaces remain unchanged.
The following points have changed as exceptions:

### The domain of the basis functions $U(\tau)$
This has been extended from $[0, \beta]$ to $[-\beta, \beta]$.
- The fermionic basis functions are anti-periodic, while the bosonic basis functions are periodic. If you use the logistic kernel (default), the fermionic and bosonic basis functions are identical in $(0, \beta)$, while they have opposite signs in $(-\beta, 0)$. To keep consistency with the previous version, $U_l(\beta)$ and $U_l(-\beta)$ evaluate to the values at $\beta^-$ and $(-\beta)^+$, respectively. The value at $0^-$ is obtained by passing `-0.0` (`u(-0.0)`), while `u(0.0)` gives the value at $0^+$.

### The domain of the $\tau$ sampling points
The default $\tau$ sampling points lie in $(0, \beta)$, as in version 1 (`use_positive_taus=True` is the default of `TauSampling` and `FiniteTempBasisSet`). Reversing the array of the sampling points maps $\tau$ to $\beta-\tau$. This is useful in some diagrammatic calculations, e.g., second order perturbation theory, which needs $G(\tau)G(\beta-\tau)$. See the following example code:

```Python
# G(tau) * G(beta-tau) on the default sampling points
gtau * gtau[::-1]
```

Setting `use_positive_taus=False` when initializing a `TauSampling` object or a `FiniteTempBasisSet` object places the sampling points in $(-\beta/2, \beta/2]$ instead. This option has been introduced for preparing a future introduction of zero-temperature basis functions. These points are symmetric with respect to $0$ only when their number is even: for an odd number, $\beta/2$ is a sampling point but $-\beta/2$ is not. Reversing the array therefore does not map $\tau$ to $-\tau$ in general.