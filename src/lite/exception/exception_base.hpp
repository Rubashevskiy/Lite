#ifndef EXCEPTION_BASE
#define EXCEPTION_BASE

/*Базовый набор*/
#include <cstdio>
#include <cstdlib>
#include <string>
#include <sstream>
/*Для создания trace*/
#include <execinfo.h> // Для backtrace
#include <dlfcn.h>    // Для dladdr
#include <cxxabi.h>   // Для __cxa_demangle

/*!
 * @brief Макрос для создания класса ExceptionBase с предварительным набором данными.
 */
#define EXCEPTION() lite::exception::ExceptionBase(__FILE__, __PRETTY_FUNCTION__, __LINE__);
#define EXCEPTION_ERR(error) lite::exception::ExceptionBase(__FILE__, __PRETTY_FUNCTION__, __LINE__, error);

namespace lite {
namespace exception {


/*! \class ExceptionBase
 * @brief Класс для создания исключения
 */
class ExceptionBase {
public:
  /*!
   * @brief Конструктор
   * @param ex_info  Структура ExceptInfo
   */
  ExceptionBase(std::string file, std::string func, int line, std::string err = std::string{})
          : ex_file(file), ex_fun(func), ex_line(line), ex_msg(err) { createTrace(); }
  ExceptionBase(std::string file, std::string func, int line)
          : ex_file(file), ex_fun(func), ex_line(line), ex_msg("NULL") { createTrace(); }
  /*!
   * @brief Получить имя файла в котором возникло исключение
   * @return string Имя файла
   */
  std::string file()     { return ex_file; };
  
  /*!
   * @brief Получить текст ошибки исключения
   * @return string Текс ошибки
   */
  std::string what()     { return ex_msg; };
  
  /*!
   * @brief Получить имя функции в котором возникло исключение
   * @return string Имя функции
   */
  std::string function() { return ex_fun; };
  
  /*!
   * @brief Получить номер строки в файле в котором возникло исключение
   * @return string Номер строки
   */
  std::string line()     { return std::to_string(ex_line); };
  
  /*!
   * @brief Получить trace
   * @return string trace
   */
  std::string trace()    { return ex_trace; };
private:
  void createTrace() {   // Создание trace
    void *callstack[128];
    const int nMaxFrames = sizeof(callstack) / sizeof(callstack[0]);
    char buf[1024];
    int nFrames = backtrace(callstack, nMaxFrames);
    char **symbols = backtrace_symbols(callstack, nFrames);
    std::ostringstream trace_buf;
    for (int i = 2; i < nFrames; i++) {
      Dl_info info;
      if (dladdr(callstack[i], &info) && info.dli_sname) {
        char *demangled = NULL;
        int status = -1;
        if (info.dli_sname[0] == '_') {
          demangled = abi::__cxa_demangle(info.dli_sname, NULL, 0, &status);
        }
        snprintf(buf, sizeof(buf), "%-3d %*p %s\n",
        i-1, int(2 + sizeof(void*) * 2), callstack[i],
        (status == 0) ? (demangled) : (info.dli_sname == 0) ? (symbols[i]) : (info.dli_sname));
        free(demangled);
      } 
      else {
        snprintf(buf, sizeof(buf), "%-3d %*p %s\n", i-1, int(2 + sizeof(void*) * 2), callstack[i], symbols[i]);
      }
      trace_buf << buf;
    }
    free(symbols);
    ex_trace = trace_buf.str();
  }
private:
  std::string ex_file{};
  std::string ex_fun{};
  std::string ex_msg{};
  std::string ex_trace{};
  int ex_line{};
};

}  //namespace exception
}  //namespace lite

#endif // EXCEPTION_BASE
