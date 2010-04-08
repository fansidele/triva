#include "Triva3DFrame.h"
#include <GL/gl.h>

Triva3DFrame::Triva3DFrame()
{

}

Triva3DFrame::Triva3DFrame(wxWindow *parent, wxWindowID id,
                        const wxPoint &pos,
                        const wxSize &size,
                        long style,
                        const wxValidator &validator) :
	wxOgreRenderWindow(parent,id,pos,size,style,validator)
{
	createRenderWindow ();

	mRoot = Ogre::Root::getSingletonPtr ();	

	mSceneMgr = mRoot->createSceneManager(Ogre::ST_EXTERIOR_CLOSE,
				"VisuSceneManager");

}

void Triva3DFrame::takeScreenshot ()
{
	std::cout << mRenderWindow << std::endl;


  static int i = 0;
   std::cout << mRenderWindow << std::endl;
   int width = mRenderWindow->getWidth();
   int height = mRenderWindow->getHeight();
   std::cout << width << " " << height << std::endl;


   unsigned char *pixels,buf;
   FILE *shot;
   char name[20];

   sprintf(name,"screenshot%i.tga",i++);

   if((shot=fopen(name, "wb"))==NULL)
      return;

   pixels = new unsigned char[width*height*4];

   glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pixels);

   for (int x = 0; x < ((width)*(height)*4)-5; x++)
   {
      buf = pixels[x];
      pixels[x] = pixels[x+2];
      pixels[x+2] = buf;
      x++;
   }

   unsigned char TGAheader[12]={0,0,2,0,0,0,0,0,0,0,0,0};
   unsigned char header[6] = {width%256,width/256,height%256,height/256,32,0};

   fwrite(TGAheader, sizeof(unsigned char), 12, shot);
   fwrite(header, sizeof(unsigned char), 6, shot);
   fwrite(pixels, sizeof(unsigned char), width*height*4, shot);
   fclose(shot);

   delete [] pixels;

   return;



	mRenderWindow->writeContentsToFile (Ogre::String("triva.png"));
}
