#ifndef MESH_H
#define MESH_H

#include <vector>

#include "Global.h"
#include "Data.h"

//abstract mesh class
class Mesh 
{
	public:
	
	Data & data;
	Mesh(Data & d) : data(d) {}
	
	void createGraph(std::vector<size_t> & order);
	uint numVerts();
	
	
#ifdef OPT_VECTOR
	size_t getNeighbors(size_t i, size_t * n);
	size_t find6Neighbors( uint x, uint y, uint z, size_t * neighbors);
	size_t find18Neighbors( uint x, uint y, uint z, size_t * neighbors);
#else
	void getNeighbors(size_t i, std::vector<size_t> & n);
	void find6Neighbors(uint x, uint y, uint z, std::vector< size_t > & neighbors);
	void find18Neighbors(uint x, uint y, uint z, std::vector< size_t > & neighbors);
#endif
	
};

#endif
