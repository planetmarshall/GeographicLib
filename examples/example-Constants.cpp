// Example of using the GeographicLib::Constants class
// $Id: c32f14d43abd9e969043dd0506b00c2458763419 $

#include <iostream>
#include <exception>
#include <GeographicLib/Constants.hpp>

using namespace std;
using namespace GeographicLib;

int main() {
  try {
    cout << Constants::WGS84_a() << " 1/" << 1/Constants::WGS84_f() << "\n";
  }
  catch (const exception& e) {
    cerr << "Caught exception: " << e.what() << "\n";
    return 1;
  }
  return 0;
}