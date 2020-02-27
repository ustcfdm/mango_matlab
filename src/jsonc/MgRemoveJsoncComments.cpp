/*==========================================================
 * MgRemoveJsoncComments.cpp
 *
 * Remove comments of a json string.
 * Tail comma can also be removed.
 *
 * The calling syntax is:
 *
 *		outString = MgRemoveJsoncComments(inString)
 *
 * This is a MEX-file for MATLAB.
 * Author: Mango Feng 
 * Date: 2019-04-17
 *
 *========================================================*/

#include "mex.h"
#include "rapidjson/document.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"


char* MgRemoveJsoncComments(const char* inputString)
{
	namespace js = rapidjson;

	js::Document document;
	document.Parse<js::kParseCommentsFlag | js::kParseTrailingCommasFlag>(inputString);

	js::StringBuffer output;
	js::Writer<js::StringBuffer> writer(output);
	document.Accept(writer);

	auto len = output.GetSize();

	char* outputString = (char*)malloc(len+1);
	strcpy_s(outputString, len+1, output.GetString());

	return outputString;
}

/* The gateway function */
// nlhs: Number of expected mxArray output arguments, specified as an integer.
// plhs: Array of pointers to the expected mxArray output arguments.
// nrhs: Number of input mxArrays, specified as an integer.
// prhs: Array of pointers to the mxArray input arguments. 
void mexFunction(int nlhs, mxArray *plhs[],	int nrhs, const mxArray *prhs[])
{
	char* inputString;				// input string
	char* outputString;				// output string
	size_t strLen;					// input string length

	/* check for proper number of arguments */
	if (nrhs != 1) {
		mexErrMsgIdAndTxt("MyToolbox:MgRemoveJsoncComments:nrhs", "One inputs required.");
	}
	if (nlhs > 1) {
		mexErrMsgIdAndTxt("MyToolbox:MgRemoveJsoncComments:nlhs", "Too many output arguments.");
	}
	/* input must be a string */
	if (!mxIsChar(prhs[0])) {
		mexErrMsgIdAndTxt("MyToolbox:MgRemoveJsoncComments:inputNotString", "Input must be a character array.");
	}
	/* input must be a row vector */
	if (mxGetM(prhs[0]) != 1)
		mexErrMsgIdAndTxt("MATLAB:MgRemoveJsoncComments:inputNotVector", "Input must be a row vector.");

	/* copy the string data from prhs[0] into a C string inputString.    */
	inputString = mxArrayToString(prhs[0]);

	/* call the C subroutine 
	*  and
	*  set C-style string outputString to MATLAB mexFunction output
	*/
	outputString = MgRemoveJsoncComments(inputString);
	plhs[0] = mxCreateString(outputString);

	free(outputString);
	mxFree(inputString);
	return;
}
