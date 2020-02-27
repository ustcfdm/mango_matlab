#ifndef _MG_GENERATE_POISSON_H_
#define _MG_GENERATE_POISSON_H_

extern "C" void MgGeneratePoissonSameLambda(double* resultArray, size_t resultSize, double lambda, unsigned long long seed);

extern "C" void MgGeneratePoissonVariousLambda(double* resultArray, double* lambda, size_t resultSize, unsigned long long seed);

#endif // !_MG_GENERATE_POISSON_H_


