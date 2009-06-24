#include "Treemap.h"
#include <float.h>

#define BIGFLOAT FLT_MAX

@implementation Treemap
- (float) width
{
        return width;
}

- (float) height
{
        return height;
}

- (float) x
{
        return x;
}

- (float) y
{
        return y;
}

- (int) depth
{
        return depth;
}

- (void) setWidth: (float) w
{
        width = w;
}

- (void) setHeight: (float) h
{
        height = h;
}

- (void) setX: (float) xp
{
        x = xp;
}

- (void) setY: (float) yp
{
        y = yp;
}

- (void) setDepth: (int) d
{
        depth = d;
}

- (void) calculateWithWidth: (float) w andHeight: (float) h
{
	[self recalculateValues];
        if (value == 0){
                //nothing to calculate
                return;
        }
        float area = w * h;
        float factor = area/value;
        width = w;
        height = h;
        x = 0;
        y = 0;
        depth = 0;
        [self calculateWithWidth: w height: h factor: factor depth: depth];
}

- (void) calculateWithWidth: (float) W
              height: (float) H
              factor: (float) factor
                depth: (int) d
{
        if (children == nil){
                return;
        }

#define SCALE(val) (val*factor)
        //create children size
        int inputSize = [children count];

        float *wvec = (float *)malloc (inputSize * sizeof(float));
        float *hvec = (float *)malloc (inputSize * sizeof(float));
        float *xvec = (float *)malloc (inputSize * sizeof(float));
        float *yvec = (float *)malloc (inputSize * sizeof(float));

        //algorithm start       
        float ratio = BIGFLOAT;
        float aux = 0;
        int i, j, k;
        float Want, Hant, Worig, Horig;
        float xcum, ycum;
        Treemap *child;


        i = 0;
        //j e aux andam juntos. quando aux = 0, j = i
        j = i;
        aux = 0;
        //salvando o W e H originais, pra relacionar os centros ao centro do
        //quadrado original
        Worig = x;
        Horig = y;
        //para achar o centro dos quadrados
        Want = Hant = 0;
        while (i < inputSize){
		/* REMEMBER: we will calculate the child at position **i** */
                child = [children objectAtIndex: i];

		/* if child value is zero, do not consider it */
                if ([child val] <= 0 || SCALE([child val]) <= 0){
                        i++;
                        continue;
                }

		/* if there is NO more space available */
                if (W < 0 || H < 0){
                        break;
                }

		/* ok, seems that this child worth some calculations */

                aux += SCALE([child val]); /* aux = value of children already calculated */

                float nw, nh;
                if (W > H){
                        nw = aux/H;
			
			/* updating previous children attributes */
                        for (k = j; k <= i; k++){
                                child = [children objectAtIndex: k];

                                wvec[k] = nw;
                                hvec[k] = SCALE([child val])/nw;

                                [child setWidth: wvec[k]];
                                [child setHeight: hvec[k]];
                                [child setDepth: d+1];
                        }
                }else{
                        nh = aux/W;

			/* updating previous children attributes */
                        for (k = j; k <= i; k++){
                                child = [children objectAtIndex: k];
                                wvec[k] = SCALE([child val])/nh;
                                hvec[k] = nh;
                                [child setWidth: wvec[k]];
                                [child setHeight: hvec[k]];
                                [child setDepth: d+1];
                        }
                }
                //calcular ratio do quadrado i
                float nratio = fmax (hvec[i]/wvec[i], wvec[i]/hvec[i]);
                if (nratio < ratio){
			/* Ratio got better, update & move on to the next **i** child */
                        ratio = nratio;

			xvec[i] = (Want) + Worig;
                        yvec[i] = (Hant) + Horig;

                        child = [children objectAtIndex: i];
                        [child setX: xvec[i]];
                        [child setY: yvec[i]];
                        [child setDepth: d+1];

                        i++;
                }else{
			/* Worst Ratio! */
                        if (W > H){
                                child = [children objectAtIndex: i];
                                //retornando sem o quadrado i
                                aux -= SCALE([child val]);
                                nw = aux/H;
                                ycum = 0;
                                for (k = j; k <= i; k++){
                                        child = [children objectAtIndex: k];
                                        wvec[k] = nw;
                                        hvec[k] = SCALE([child val])/nw;

                                        xvec[k] = (Want) + Worig;
                                        yvec[k] = (Hant + ycum) + Horig;

                                        ycum += hvec[k];

                                        [child setWidth: wvec[k]];
                                        [child setHeight: hvec[k]];
                                        [child setX: xvec[k]];
                                        [child setY: yvec[k]];
                                        [child setDepth: d+1];
                                }
                                /* updating W */
                                W = W - wvec[i-1];
                                Want += wvec[i-1];
                        }else{
                                child = [children objectAtIndex: i];
                                //retornando sem o quadrado i
                                aux -= SCALE([child val]);
                                nh = aux/W;
                                xcum = 0;
                                for (k = j; k <= i; k++){
                                        child = [children objectAtIndex: k];
                                        wvec[k] = SCALE([child val])/nh;
                                        hvec[k] = nh;

                                        xvec[k] = (Want + xcum) + Worig;
                                        yvec[k] = (Hant) + Horig;

                                        xcum += wvec[k];

                                        [child setWidth: wvec[k]];
                                        [child setHeight: hvec[k]];
                                        [child setX: xvec[k]];
                                        [child setY: yvec[k]];
                                        [child setDepth: d+1];
                                }
                                /* updating H */
                                H = H - hvec[i-1];
                                Hant += hvec[i-1];
                        }
                       //avancando
                        aux = 0;
                        j = i;
                        ratio = BIGFLOAT;
                }
        }
        for (j = 0; j < i; j++){
                child = [children objectAtIndex: j];
		float nfactor = [child width]*[child height]/[child val];
                [child calculateWithWidth: [child width] height: [child height]
                        factor: nfactor depth: d+1];
        }

        free (wvec);
        free (hvec);
        free (xvec);
        free (yvec);
#undef SCALE
}

- (int) maxDepth
{
	if ([children count] == 0){
		return depth;
	}

	int max = 0;
	int i;
	for (i = 0; i < [children count]; i++){
		int d = [[children objectAtIndex: i] maxDepth];
		if (d > max){
			max = d;
		}
	}
	return max;
}

- (void) setPajeEntity: (id) entity
{
	pajeEntity = entity; //not retained
}

- (id) pajeEntity
{
	return pajeEntity;
}
@end
