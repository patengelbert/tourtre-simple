#include "Mesh.h"

#include <iostream>
#include <algorithm>
#if defined(OPT_PARALLEL_SORT) && defined(_OPENMP)
#include "parallel_stable_sort.h"
#endif

#include "seiHelpers.h"

using std::cout;
using std::endl;
using std::sort;





//functor for sorting
class AscendingOrder 
{
	Data & data;
	public:
	AscendingOrder( Data & d ) : data(d) {}
	bool operator()(const uint & a, const uint & b) const { 
#ifdef OPT_FAST_SORT
		if (compareEqual(data.data[a], data.data[b])) return a < b;
		else return compareLess(data.data[a], data.data[b]);
#else
		return data.less(a, b);
#endif
	}
};


void Mesh::createGraph(std::vector<size_t> & order) 
{
	order.resize( data.totalSize );
	
	for (uint i = 0; i < order.size(); i++) 
		order[i] = i;
#if defined(OPT_PARALLEL_SORT) && defined(_OPENMP)
	LOG(LOG_DEBUG, "Using parallel sorting");
	pss::parallel_stable_sort(order.begin(), order.end(), AscendingOrder(data));
#else
	LOG(LOG_DEBUG, "Using serial sorting");
	sort( order.begin() , order.end(), AscendingOrder(data) );
#endif
}

#ifdef OPT_VECTOR
size_t Mesh::getNeighbors(size_t i, size_t * n)
#else
void Mesh::getNeighbors(size_t i, std::vector<size_t> & n)
#endif
{
	uint x,y,z;
	data.convertIndex( i, x, y, z );
	if ( (x+y+z)%2 == ODD_TET_PARITY ) {
		return find6Neighbors(x,y,z,n);
	} else {
		return find18Neighbors(x,y,z,n);
	}
}

#ifdef OPT_VECTOR
size_t Mesh::find6Neighbors( uint x, uint y, uint z, size_t * neighbors) 
#else
void Mesh::find6Neighbors(uint x, uint y, uint z, std::vector< size_t > & neighbors)
#endif
{
	uint nx[6], ny[6], nz[6];

	for (uint i = 0; i < 6; i++) {
		nx[i] = x;
		ny[i] = y;
		nz[i] = z;
	}

	//first 6 neighbors
	nx[0] -= 1;
	ny[1] -= 1;
	nz[2] -= 1;
	nx[3] += 1;
	ny[4] += 1;
	nz[5] += 1;

	uint s = 0;
	for (uint i = 0; i < 6; i++) {
		if (nx[i] >= data.size[0]) continue;
		if (ny[i] >= data.size[1]) continue;
		if (nz[i] >= data.size[2]) continue;

#ifdef OPT_VECTOR
		neighbors[s++] = data.convertIndex(nx[i], ny[i], nz[i]);
	}
	return s;
#else
		neighbors.push_back( data.convertIndex(nx[i], ny[i], nz[i]) );
	}
#endif
}

#ifdef OPT_VECTOR
size_t Mesh::find18Neighbors(uint x, uint y, uint z, size_t * neighbors)
#else
void Mesh::find18Neighbors(uint x, uint y, uint z, std::vector< size_t > & neighbors)
#endif
{
	uint nx[18],ny[18],nz[18];
	
	for (uint i = 0; i < 18; i++) {
		nx[i] = x;
		ny[i] = y;
		nz[i] = z;
	}
	
	//first 6 neighbors
	nx[0] -= 1;
	ny[1] -= 1;
	nz[2] -= 1;
	nx[3] += 1;
	ny[4] += 1;
	nz[5] += 1;
	
	//the rest of the 18
	nx[6] -= 1; ny[6]  -= 1;
	nx[7] += 1; ny[7]  -= 1;
	ny[8] -= 1; nz[8]  -= 1;
	ny[9] += 1; nz[9]  -= 1;
	nz[10]-= 1; nx[10] -= 1;
	nz[11]+= 1; nx[11] -= 1;
		
	nx[12] -= 1; ny[12] += 1;
	nx[13] += 1; ny[13] += 1;
	ny[14] -= 1; nz[14] += 1;
	ny[15] += 1; nz[15] += 1;
	nz[16] -= 1; nx[16] += 1;
	nz[17] += 1; nx[17] += 1;
	
	uint s = 0;
	for (uint i = 0; i < 18; i++) {
		
		
		if (nx[i] >= data.size[0]) continue;	
		if (ny[i] >= data.size[1]) continue;	
		if (nz[i] >= data.size[2]) continue;	
	
#ifdef OPT_VECTOR
		neighbors[s++] = data.convertIndex(nx[i], ny[i], nz[i]);
	}
	return s;
#else
		neighbors.push_back(data.convertIndex(nx[i], ny[i], nz[i]));
	}
#endif
}
