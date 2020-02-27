#include "MgGeneratePoisson.h"
#include <cuda.h>
#include <curand.h>
#include <curand_kernel.h>

#define BLOCKSIZE 1024

__global__ void ConvertUnsigedToDouble(double* arrayDouble, unsigned* arrayUnsigned, size_t N)
{
	size_t id = threadIdx.x + blockDim.x * blockIdx.x;

	if (id < N)
	{
		arrayDouble[id] = (double)arrayUnsigned[id];
	}
}

// Same lambda, use host API
void MgGeneratePoissonSameLambda(double* resultArray, size_t resultSize, double lambda, unsigned long long seed)
{
	// generate Poisson random number of unsigned type
	unsigned* resultArrayUint_dev;
	double* resultArrayDouble_dev;

	cudaMalloc(&resultArrayUint_dev, sizeof(unsigned) * resultSize);
	cudaMalloc(&resultArrayDouble_dev, sizeof(double) * resultSize);

	curandGenerator_t gen;

	curandCreateGenerator(&gen, CURAND_RNG_PSEUDO_DEFAULT);

	curandSetPseudoRandomGeneratorSeed(gen, seed);

	curandGeneratePoisson(gen, resultArrayUint_dev, resultSize, lambda);

	curandDestroyGenerator(gen);

	cudaDeviceSynchronize();

	// convert unsigend type into double type
	ConvertUnsigedToDouble << <(resultSize + BLOCKSIZE - 1) / BLOCKSIZE, BLOCKSIZE >> > (resultArrayDouble_dev, resultArrayUint_dev, resultSize);
	cudaDeviceSynchronize();

	// copy result back to hose
	cudaMemcpy(resultArray, resultArrayDouble_dev, resultSize * sizeof(double), cudaMemcpyDeviceToHost);

	cudaFree(resultArrayUint_dev);
	cudaFree(resultArrayDouble_dev);
}


__global__ void InitializeState(curandState* state, size_t N, unsigned long long seed)
{
	size_t id = threadIdx.x + blockDim.x * blockIdx.x;

	if (id < N)
	{
		curand_init(seed, id, 0, &state[id]);
	}
}

__global__ void GiveRandomNumbersToVariousLambda(double* resultArrayDev, double* lambdaDev, size_t N, curandState* state)
{
	curandState localState = state[threadIdx.x];

	int loops = (N + BLOCKSIZE - 1) / BLOCKSIZE;
	int id;
	for (int k = 0; k < loops; k++)
	{
		id = threadIdx.x + BLOCKSIZE * k;
		if(id < N)
			resultArrayDev[id] = (double)curand_poisson(&localState, lambdaDev[id]);
	}
}

// Various lambda, use device API
void MgGeneratePoissonVariousLambda(double* resultArray, double* lambda, size_t resultSize, unsigned long long seed)
{
	double* resultArray_dev;
	cudaMalloc((void**)& resultArray_dev, resultSize * sizeof(double));

	// initialize state
	curandState* devState;
	cudaMalloc((void**)& devState, BLOCKSIZE * sizeof(curandState));
	InitializeState <<<1, BLOCKSIZE>>> (devState, BLOCKSIZE, seed);
	cudaDeviceSynchronize();

	// copy data of lamda to device
	double* lambda_dev;
	cudaMalloc((void**)& lambda_dev, resultSize * sizeof(double));
	cudaMemcpy(lambda_dev, lambda, resultSize * sizeof(double), cudaMemcpyHostToDevice);
	cudaDeviceSynchronize();

	// get random numbers
	GiveRandomNumbersToVariousLambda <<<1, BLOCKSIZE >>> (resultArray_dev, lambda_dev, resultSize, devState);
	cudaDeviceSynchronize();

	cudaMemcpy(resultArray, resultArray_dev, resultSize * sizeof(double), cudaMemcpyDeviceToHost);
	cudaDeviceSynchronize();

	cudaFree(lambda_dev);
	cudaFree(devState);
	cudaFree(resultArray_dev);
}