.. _integration-s3p:

ONAP Maturity Testing Notes
---------------------------

Historically integration team used to execute specific stability and resilience
tests on target release. For frankfurt a stability test was executed.
Openlab, based on  Frankfurt RC0 dockers was also observed a long duration
period to evaluate the overall stability.
Finally the CI daily chain created at Frankfurt RC0 was also a precious indicator
to estimate the solution stability.

No resilience or stress tests have been executed due to a lack of resources
and late availability of the release. The testing strategy shall be amended in
Guilin, several requirements have been created to improve the S3P testing domain.

Stability
=========

TODO


Methodology
~~~~~~~~~~~


CI results
==========

A daily Guilin CI chain has been created after RC0.

The evolution of the full healthcheck test suite can be described as follows:

|image1|



Resilience
==========


.. |image1| image:: files/s3p/daily_frankfurt1.png
      :width: 6.5in
