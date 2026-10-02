# dominoise: Parsimonious Noise Perturbation for Magnitude Tables

Protects magnitude tables, such as tables of enterprise turnover, by
multiplying each total by a Gaussian noise combining a dominance-driven
component and a general-purpose one, governed by three parameters only.
Information loss and disclosure risks for three attack scenarios
(external inference, internal inference and differencing) are available
in closed form, so that calibration requires neither simulation nor
recalibration on the data. The package guides that calibration step by
step, from the differencing noise to the dominance parameters, with
decision tables and risk-utility plots, applies the mechanism to an
aggregated table using SHA-512 hashed random keys for consistency over
time, and reports the risk and utility actually achieved. The method is
described in Jamme (2027) [doi:
10.1007/978-3-032-37883-5_9](https://doi.org/%2010.1007/978-3-032-37883-5_9)
.

## References

Jamme, J. (2027). Parsimonious Perturbation Mechanism for Magnitude
Tables with Analytical Risk-Utility Metrics. In: Domingo-Ferrer, J.,
González-Yero, I. (eds) *Privacy in Statistical Databases. PSD 2026*.
Lecture Notes in Computer Science, vol 16925, pp. 130–146. Springer,
Cham.
[doi:10.1007/978-3-032-37883-5_9](https://doi.org/10.1007/978-3-032-37883-5_9)

## See also

Useful links:

- <https://github.com/InseeFrLab/dominoise>

- <https://inseefrlab.github.io/dominoise/>

- Report bugs at <https://github.com/InseeFrLab/dominoise/issues>

## Author

**Maintainer**: Julien Jamme <julien.jamme@insee.fr>
([ORCID](https://orcid.org/0009-0009-9054-7053))

Authors:

- Julien Jamme <julien.jamme@insee.fr>
  ([ORCID](https://orcid.org/0009-0009-9054-7053))

Other contributors:

- Institut national de la statistique et des études économiques
  \[copyright holder\]
