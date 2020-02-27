/*==========================================================
 * MgPoissrndGpu.cpp
 *
 * Generate Poisson random numbers based on Gpu
 *
 * The calling syntax is:
 *
 *      // lambda is a number or array (double), seed is optional
 *		resultArray = MgPoissrndGpu(lambda, (seed))		
 * or
 *      // lambda is a number (double), seed is optional.
 *      // The second parameter [M, N, ...] should have at least
 *      // two numbers.
 *      resultArray = MgPoissrndGpu(lambda, [M,N,...], (seed))
 *
 * This is a MEX-file for MATLAB.
 * Author: Mango Feng
 * Date: 2019-07-31
 *
 *========================================================*/

#include "mex.h"
#include "time.h"
#include "MgGeneratePoisson.h"

 /* The gateway function */
 // nlhs: Number of expected mxArray output arguments, specified as an integer.
 // plhs: Array of pointers to the expected mxArray output arguments.
 // nrhs: Number of input mxArrays, specified as an integer.
 // prhs: Array of pointers to the mxArray input arguments. 
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
	/* check for proper number of arguments */
	if (nrhs < 1 || nrhs > 3)
		mexErrMsgTxt("Invalid number of inputs.");
	
	if (nlhs > 1)
		mexErrMsgTxt("Too many output arguments.");

	unsigned long long seed;

	// if lambda is a scalar and double, the output dimension should be specified
	if (mxIsDouble(prhs[0]) && mxIsScalar(prhs[0]))
	{
		if (nrhs < 2)
			mexErrMsgTxt("You need to specify output dimension for a scalar lambda.");
		
		if (!mxIsDouble(prhs[1]) || mxIsScalar(prhs[1]))
			mexErrMsgTxt("The dimension should be specified with at least two dimension array of double precision.");

		// determine whether seed is given
		if (nrhs == 3)
		{
			// seed is specified
			if (!mxIsNumeric(prhs[2]) || !mxIsScalar(prhs[2]))
				mexErrMsgTxt("Seed should be a number.");
			
			double* tmp = (double*)mxGetData(prhs[2]);
			seed = (unsigned long long)tmp[0];
		}
		else
		{
			// seed is not specified, use current time as seed
			seed = (unsigned long long)time(NULL);
		}

		// get lambda
		double* tmp2 = (double*)mxGetData(prhs[0]);
		double lambda = tmp2[0];

		// get the result array size
		size_t resultSize = 1;
		size_t dimCount = mxGetNumberOfElements(prhs[1]);
		double* tmp = (double*)mxGetData(prhs[1]);
		mwSize* dims = new mwSize[dimCount];

		for (size_t i = 0; i < dimCount; i++)
		{
			resultSize *= (size_t)tmp[i];
			dims[i] = (mwSize)tmp[i];
		}

		// create result array 
		plhs[0] = mxCreateNumericArray(dimCount, dims, mxDOUBLE_CLASS, mxREAL);
		delete[] dims;
		double* resultArray = (double*)mxGetData(plhs[0]);

		// generate random number
		MgGeneratePoissonSameLambda(resultArray, resultSize, lambda, seed);
	}
	// if the lambda is an array, the output array has the same size as lambda
	else if(mxIsDouble(prhs[0]) && !mxIsScalar(prhs[0]))
	{
		// Only need at most two arguemnts
		if (nrhs > 2)
			mexErrMsgTxt("Invalid number of arguments for an array lambda. You just need at most 2 arguments.");
		
		// determine whether seed is given
		if (nrhs == 2)
		{
			// seed is specified
			if (!mxIsNumeric(prhs[1]) || !mxIsScalar(prhs[1]))
				mexErrMsgTxt("Seed should be a number.");

			double* tmp = (double*)mxGetData(prhs[1]);
			seed = (unsigned long long)tmp[0];
		}
		else
		{
			// seed is not specified, use current time as seed
			seed = (unsigned long long)time(NULL);
		}

		// get lambda array
		double* lambda = (double*)mxGetData(prhs[0]);

		// get dimension of lambda array
		size_t dim = mxGetNumberOfDimensions(prhs[0]);
		const mwSize* ndim = mxGetDimensions(prhs[0]);
		// total result size
		size_t resultSize = 1;

		for (size_t i = 0; i < dim; i++)
		{
			resultSize *= ndim[i];
		}

		// create result array 
		plhs[0] = mxCreateNumericArray(dim, ndim, mxDOUBLE_CLASS, mxREAL);
		double* resultArray = (double*)mxGetData(plhs[0]);

		// generate random number
		MgGeneratePoissonVariousLambda(resultArray, lambda, resultSize, seed);

	}
	// invalid input of lambda
	else
	{
		mexErrMsgTxt("Invalid input of lambda. Lambda should be a doulbe array or number.");
	}

}