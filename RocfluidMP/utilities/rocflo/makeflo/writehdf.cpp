/* *******************************************************************
 * Illinois Open Source License                                      *
 *                                                                   *
 * University of Illinois/NCSA                                       * 
 * Open Source License                                               *
 *                                                                   *
 * Copyright@2008, University of Illinois.  All rights reserved.     *
 *                                                                   *
 *  Developed by:                                                    *
 *                                                                   *
 *     Center for Simulation of Advanced Rockets                     *
 *                                                                   *
 *     University of Illinois                                        *
 *                                                                   *
 *     www.csar.uiuc.edu                                             *
 *                                                                   *
 * Permission is hereby granted, free of charge, to any person       *
 * obtaining a copy of this software and associated documentation    *
 * files (the "Software"), to deal with the Software without         *
 * restriction, including without limitation the rights to use,      *
 * copy, modify, merge, publish, distribute, sublicense, and/or      *
 * sell copies of the Software, and to permit persons to whom the    *
 * Software is furnished to do so, subject to the following          *
 * conditions:                                                       *
 *                                                                   *
 *                                                                   *
 * @ Redistributions of source code must retain the above copyright  * 
 *   notice, this list of conditions and the following disclaimers.  *
 *                                                                   * 
 * @ Redistributions in binary form must reproduce the above         *
 *   copyright notice, this list of conditions and the following     *
 *   disclaimers in the documentation and/or other materials         *
 *   provided with the distribution.                                 *
 *                                                                   *
 * @ Neither the names of the Center for Simulation of Advanced      *
 *   Rockets, the University of Illinois, nor the names of its       *
 *   contributors may be used to endorse or promote products derived * 
 *   from this Software without specific prior written permission.   *
 *                                                                   *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,   *
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES   *
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND          *
 * NONINFRINGEMENT.  IN NO EVENT SHALL THE CONTRIBUTORS OR           *
 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       * 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   *
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE    *
 * USE OR OTHER DEALINGS WITH THE SOFTWARE.                          *
 *********************************************************************
 * Please acknowledge The University of Illinois Center for          *
 * Simulation of Advanced Rockets in works and publications          *
 * resulting from this software or its derivatives.                  *
 *********************************************************************/
/*
Writes out a CSAR rocket .hdf output file, an HDF4 format.

Orion Sky Lawlor, olawlor@acm.org, 6/8/2001
*/
#include <stdio.h>
#include "gridutil.h"

/*HDF4 include file*/
#include "mfhdf.h"

//HDF data type
typedef double REAL;

#define chk(x) checkHDFerr(x,__FILE__,__LINE__)
static int checkHDFerr(int errCode,const char *fName,int lineNo) {
	if (errCode==-1) {
		fprintf(stderr,"HDF I/O Error in (%s:%d)\n",
			fName,lineNo);
		exit(23);
	}
	return errCode;
}

const char *write_hdf(const blockDim &dim,const vector3d *locs,
	const char *filename)
{
	const int dataType=6;//double precision float
	REAL time=0.0;
	int32 timeLen=1;
	chk(DFSDsetdims(1,&timeLen));
	chk(DFSDsetNT(dataType));
	chk(DFSDputdata(filename, 1, &timeLen, &time));

	//Copy the data from C++ array to C arrays
	int len=dim.getSize();
	REAL *x=new REAL[len];
	REAL *y=new REAL[len];
	REAL *z=new REAL[len];
	blockLoc i;
	for (i[2]=0; i[2]<dim[2]; i[2]++)
	for (i[1]=0; i[1]<dim[1]; i[1]++)
	for (i[0]=0; i[0]<dim[0]; i[0]++) 
	{ //Copy data into separate, coordinate-wise arrays
		int c_i=dim[i], f_i=dim[i];
		x[f_i]=locs[c_i].x;
		y[f_i]=locs[c_i].y;
		z[f_i]=locs[c_i].z;
	}

	//Send the data off to HDF
	int32 dSize[3]; //Swap dimensions
	dSize[0]=dim[2]; dSize[1]=dim[1]; dSize[2]=dim[0];
	chk(DFSDsetdims(3,dSize));
	chk(DFSDsetNT(dataType));
	chk(DFSDadddata(filename, 3, dSize, x));
	chk(DFSDadddata(filename, 3, dSize, y));
	chk(DFSDadddata(filename, 3, dSize, z));

	//Clean up output arrays
	delete[] x; delete[] y; delete[] z;

	return NULL;
}


