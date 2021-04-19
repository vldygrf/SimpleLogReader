//
//  logReader.hpp
//  SimpleLogReader
//
//  Created by Vladislav Garifulin on 19/02/2019.
//  Copyright © 2019 Vladislav Garifulin. All rights reserved.
//

#ifndef logReader_hpp
#define logReader_hpp

#include <cstdlib>
#include <vector>

#endif /* logReader_hpp */

class CLogReader
{
private:
    char *mask;
    char *buffer;
    size_t size;
    size_t buffer_size;
    std::vector <char *> matched_strings;    //удовлетворяющие маске строки
    bool    MatchedString(const char *string);
    void    Clear();
public:
    CLogReader(const char *filter);
    ~CLogReader();
    bool    SetFilter(const char *filter);   // установка фильтра строк, false - ошибка
    bool    AddSourceBlock(const char *block, const size_t block_size); // добавление очередного блока текстового файла
    std::vector <char *> MatchedStrings();   //удовлетворяющие маске строки
    void    Parse(bool to_end_line);    //проанализировать блок текстового файла, to_end_line = true - до окончания строки, false - весь блок
};
