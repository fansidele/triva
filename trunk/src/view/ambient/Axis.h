#ifndef __AXIS_H
#define __AXIS_H

class Axis
{
protected:
	double size;
	double scale;

public:
	void setSize (double s) { size = s; };
	void setScale (double s) { scale = s; };
	Axis (double si, double sc) { size = si; scale = sc; };
	Axis () {};
	~Axis () {};
};

#endif
