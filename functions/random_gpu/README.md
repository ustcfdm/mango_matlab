Generate Poisson random numbers with GPU. Note: When you use current time as seed, if the function is called twice within the same second, they will generate same random numbers.

Examples of usage:
```matlab
%-----------------------------------------
% Same lambda
%-----------------------------------------
lambda = 30;
sz = [1000 1000 10];
% use current time as seed
r1 = MgPoissrndGpu(lambda, sz);
% specify seed
seed = 1;
r2 = MgPoissrndGpu(lambda, sz, seed);

%-----------------------------------------
% Various lambda
%-----------------------------------------
lambda = magic(1000);
% use corrent time as seed
r3 = MgPoissrndGpu(lambda);
% specify seed
r4 = MgPoissrndGpu(lambda, seed);

```