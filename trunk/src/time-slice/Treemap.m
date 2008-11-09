#include "Treemap.h"

#define BIGFLOAT 1000000

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

- (float) depth
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

- (void) setDepth: (float) d
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
        x = w/2;
        y = h/2;
        depth = 0;
        [self calculateWithWidth: w height: h factor: factor depth: depth];
}

- (void) calculateWithWidth: (float) W
              height: (float) H
              factor: (float) factor
                depth: (float) d
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
        Worig = W;
        Horig = H;
        //para achar o centro dos quadrados
        Want = Hant = 0;
        while (i < inputSize){
                child = [children objectAtIndex: i];
                float aux2 = SCALE([child value]);
                if (aux2 == 0){
                        i++; // do not consider it
                        continue;
                }
                aux += SCALE([child value]);

                float nw, nh;
                if (W > H){
                        nw = aux/H;
                        for (k = j; k <= i; k++){
                                child = [children objectAtIndex: k];

                                wvec[k] = nw;
                                hvec[k] = SCALE([child value])/nw;

                                [child setWidth: wvec[k]];
                                [child setHeight: hvec[k]];
                                [child setDepth: depth+1];
                        }
                }else{
                        nh = aux/W;
                        for (k = j; k <= i; k++){
                                child = [children objectAtIndex: k];
                                wvec[k] = SCALE([child value])/nh;
                                hvec[k] = nh;
                                [child setWidth: wvec[k]];
                                [child setHeight: hvec[k]];
                                [child setDepth: depth+1];
                        }
                }
                //calcular ratio do quadrado i
                float nratio = fmax (hvec[i]/wvec[i], wvec[i]/hvec[i]);
                if (nratio < ratio){
                        ratio = nratio;

                        xvec[i] = (Want + wvec[i]/2) - Worig/2;
                        yvec[i] = (Hant + hvec[i]/2) - Horig/2;

                        child = [children objectAtIndex: i];
                        [child setX: xvec[i]];
                        [child setY: yvec[i]];
                        [child setDepth: depth+1];

                        i++;
                }else{
                        if (W > H){
                                child = [children objectAtIndex: i];
                                //retornando sem o quadrado i
                                aux -= SCALE([child value]);
                                nw = aux/H;
                                ycum = 0;
                                for (k = j; k <= i; k++){
                                        child = [children objectAtIndex: k];
                                        wvec[k] = nw;
                                        hvec[k] = SCALE([child value])/nw;

                                        xvec[k] = (Want + wvec[k]/2) - Worig/2;
                                        yvec[k] = (Hant + ycum + hvec[k]/2) - Horig/2;

                                        ycum += hvec[k];

                                        [child setWidth: wvec[k]];
                                        [child setHeight: hvec[k]];
                                        [child setX: xvec[k]];
                                        [child setY: yvec[k]];
                                        [child setDepth: depth+1];
                                }
                                //atualizando W
                                W = W - wvec[i-1];
                                Want += wvec[i-1];
                        }else{
                                child = [children objectAtIndex: i];
                                //retornando sem o quadrado i
                                aux -= SCALE([child value]);
                                nh = aux/W;
                                xcum = 0;
                                for (k = j; k <= i; k++){
                                        child = [children objectAtIndex: k];
                                        wvec[k] = SCALE([child value])/nh;
                                        hvec[k] = nh;

                                        xvec[k] = (Want + xcum + wvec[k]/2) - Worig/2;
                                        yvec[k] = (Hant + hvec[k]/2) - Horig/2;

                                        xcum += wvec[k];

                                        [child setWidth: wvec[k]];
                                        [child setHeight: hvec[k]];
                                        [child setX: xvec[k]];
                                        [child setY: yvec[k]];
                                        [child setDepth: depth+1];
                                }
                                //atualizando H 
                                H = H - hvec[i-1];
                                Hant += hvec[i-1];
                        }
                       //avancando
                        aux = 0;
                        j = i;
                        ratio = BIGFLOAT;
                }
        }
        for (i = 0; i < inputSize; i++){
                child = [children objectAtIndex: i];
                [child calculateWithWidth: [child width] height: [child height]
                        factor: factor depth: depth+1];
        }

        free (wvec);
        free (hvec);
        free (xvec);
        free (yvec);
#undef SCALE
}
@end
