/*
    This file is part of Triva.

    Triva is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Triva is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Triva.  If not, see <http://www.gnu.org/licenses/>.
*/
#ifndef __TrivaFFT_h_
#define __TrivaFFT_h_
#include <Foundation/Foundation.h>
#include <Triva/TrivaComposition.h>
#include <math.h>
#include <gsl/gsl_errno.h>
#include <gsl/gsl_fft_complex.h>
#include <gsl/gsl_fft_real.h>
#include <gsl/gsl_fft_halfcomplex.h>

@interface TrivaFFT : TrivaComposition
{
/*  NSArray *objects;

  double tmin, tmax;
  double vmin, vmax;

  double sliceSize;
  double valueSize;
*/
  NSString *var;
  int n;
  double delta;
  double *spec;
  double ymin, ymax;
}
@end

#endif