#include <iostream>
#include "../../src/lite/exception/exception_base.hpp"

using namespace lite::exception;

void thirdFunction() {
  throw EXCEPTION_ERR("Test throw!!!");
}

void secondFunction() {
  thirdFunction();
}

void firstFunction() {
  secondFunction();
}

void test() {
  firstFunction();
}

int main(int argc, char *argv[]) {
  try {
    std::cout << "Test ExceptionBase" << std::endl;
    test();
  }
  catch(ExceptionBase &e)
  {
    std::cerr << "Error Message: "  << e.what()     << std::endl;
    std::cerr << "Error Function: " << e.function() << std::endl;
    std::cerr << "Error Line: "     << e.line()     << std::endl;
    std::cerr << "Error File: "     << e.file()     << std::endl;
    std::cerr << "Error Trace: "    << std::endl    
                                    << e.trace()    << std::endl;
  }
  return 0;
}