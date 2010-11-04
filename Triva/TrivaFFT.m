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
#include "TrivaFFT.h"

#define PLOT_WIDTH 42
#define PLOT_HEIGHT 30

@implementation TrivaFFT
- (id) initWithConfiguration: (NSDictionary*) conf
                withName: (NSString*) na
              forObject: (TrivaGraphNode*) obj
        withDifferences: (NSDictionary*) differences
              withValues: (NSDictionary*) timeSliceValues
              andProvider: (TrivaFilter*) prov
{
  self = [super initWithFilter: prov andConfiguration: conf
                      andSpace: NO andName: na andObject: obj];

  //get only the first value (notice the "break" inside the while)
  NSEnumerator *en2 = [[configuration objectForKey: @"values"]objectEnumerator];
  while ((var = [en2 nextObject])){
    break;
  }
  if (!var){
    return nil;
  }
  return self;
}

- (BOOL) redefineLayoutWithValues: (NSDictionary*) timeSliceValues
{
  //consider only the time slice
  //calculate delta and n
  NSDate *s = [filter selectionStartTime];
  NSDate *e = [filter selectionEndTime];
  double time = [e timeIntervalSinceDate: s];
  delta = time*.005; //0.005 = 0.5% (meio por cento)
  n = time/delta;
  int i;

  //transform to paje terminology
  PajeEntityType *varType = [filter entityTypeWithName: var];
  PajeEntityType *containerType = [filter entityTypeWithName: [node type]];
  PajeContainer *container = [filter containerWithName: [node name]
                                                type: containerType];

  //getting the variable for a given container
  double *d = (double*)malloc(n * sizeof(double));
  for (i = 0; i < n; i++) d[i] = 0.0;
  id entity;
  NSEnumerator *en = [filter enumeratorOfEntitiesTyped: varType
                                         inContainer: container
                                            fromTime: s
                                              toTime: e
                                         minDuration: 0];
  while ((entity = [en nextObject])){
    double ms = [[[filter selectionStartTime] description] doubleValue];
    double start = [[[entity startTime] description] doubleValue];
    double end = [[[entity endTime] description] doubleValue];
    start -= ms;
    end -= ms;
    start /= delta;
    end /= delta;

    int istart = (int)start;
    if (istart < 0) istart = 0;
    int iend = (int)end;
    if (iend > n) iend = n;

    for (i = istart; i < iend; i++){
      d[i] = [[entity value] doubleValue];
    }
  }

  //calculate the fft on data of d
  gsl_fft_real_wavetable *wavetable;
  gsl_fft_real_workspace *workspace;
  wavetable = gsl_fft_real_wavetable_alloc (n);
  workspace = gsl_fft_real_workspace_alloc (n);
  gsl_fft_real_transform (d, 1, n, wavetable, workspace);
  gsl_fft_real_wavetable_free (wavetable);

  //unpack it
  double *cc = (double*)calloc(2*n, sizeof(double));
  gsl_fft_halfcomplex_unpack  (d, cc, 1, n);

  free(d);

  //calculate the spectrum, get ymin, ymax
  free(spec);
  spec = (double*)calloc(n/2, sizeof(double));
  for (i = 0; i<n/2;i++) spec[i] = 0.0;
  ymin = FLT_MAX;
  ymax = 0;
  for (i = 1; i < n/2; i++){ //ignore frequency at 0
    double real = cc[2*i];
    double imag = cc[2*i+1];
    spec[i] = sqrt(real*real + imag*imag);
    if (spec[i] > ymax) ymax = spec[i];
    if (spec[i] < ymin) ymin = spec[i];
  }
  free(cc);
  return NO;
}

- (void) refreshWithinRect: (NSRect) rect
{
  //use only the origin (size from rect is invalid - 0,0)
  bb = NSMakeRect (rect.origin.x,
                   rect.origin.y,
                   PLOT_WIDTH,
                   PLOT_HEIGHT);
}

- (BOOL) draw
{
  //draw a rectangle
  [[NSColor blackColor] set];
  [NSBezierPath strokeRect: bb];

  //draw the name of the composition
  NSString *s = [NSString stringWithFormat: @"%@-%@", name, var];
  [s drawAtPoint: NSMakePoint (bb.origin.x, bb.origin.y + bb.size.height)
        withAttributes: nil];

  double xratio = 2*bb.size.width/n;
  double yratio = bb.size.height/(ymax - ymin);
  int i;
  NSBezierPath *path = [NSBezierPath bezierPath];

  //getting color
  [[filter colorForEntityType:
      [filter entityTypeWithName: var]] set];


  //ignore frequency 0, start at 1
  [path moveToPoint: NSMakePoint (1*xratio, spec[1]*yratio)];
  for (i = 2; i < n/2; i++){
    double x = i*xratio;
    double y = spec[i]*yratio;
    [path lineToPoint: NSMakePoint (x, y)];
  }
  NSAffineTransform *t = [NSAffineTransform transform];
  [t translateXBy: bb.origin.x yBy: bb.origin.y];
  [t concat];
  [path stroke];
  [t invert];
  [t concat];
  return YES;
}

- (void) dealloc
{
  free(spec);
  [super dealloc];
}
@end
