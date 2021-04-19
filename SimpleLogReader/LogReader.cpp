//
//  logReader.cpp
//  SimpleLogReader
//
//  Created by Vladislav Garifulin on 19/02/2019.
//  Copyright © 2019 Vladislav Garifulin. All rights reserved.
//

#include "LogReader.hpp"

CLogReader::CLogReader(const char *filter) {
    mask = NULL;
    SetFilter(filter);
    buffer = NULL;
    size = 0;
    buffer_size = 0;
}

void CLogReader::Clear() {
    for(int i = 0; i < matched_strings.size(); i++)
        free(matched_strings[i]);
    
    matched_strings.clear();
}

CLogReader::~CLogReader() {
    Clear();
    free(mask);
    free(buffer);
}

bool CLogReader::SetFilter(const char *filter) {  // установка фильтра строк
    if (filter == NULL) return false;
    
    free(mask);
    mask = (char *)malloc(strlen(filter) + 1);
    assert(mask != NULL);
    
    int mask_size = 0;
    if ((mask) && (strlen(filter) > 0)) {
        //небольшая оптимизация (формируем маску из фильтра удаляя дублирующиеся *)
        bool star = false;
        for(int i = 0; i < strlen(filter); i++) {
            if ((filter[i] != '*') || (!star))
                mask[mask_size++] = filter[i];
            
            star = (filter[i] == '*');
        }
    }
    
    mask[mask_size] = 0;
    
    return true;
}

//проверка строки на совпадение с маской (рекурсивный вариант, использовался для написания основого варианта)
bool r_matched(const char *s, const char *m) {
    //cимвол '*' - последовательность любых символов неограниченной длины;
    //cимвол "?" - один любой символ;
    while (*s) {
        if (*m == '*') {
            m++;
            
            if (!*m)
                return true;
            
            while (*s)
                if (r_matched(s++, m))
                    return true;
            
            return false;
        }else
        if ((*s == *m) || (*m == '?')) {
            s++; m++;
        }else
            return false;
    }
    
    if (*m == '*')
        m++;

    return (!*m);
}

//проверка строки на совпадение с маской
bool matched(const char *s, const char *m) {
    //cимвол '*' - последовательность любых символов неограниченной длины;
    //cимвол "?" - один любой символ;
    //Что то типа недетерминированного КА
    bool star = false;
    const char *ss = s, *mm = m;
    while (*ss) {
        if (*mm == '*') {
            if (!*++mm)
                return true;
            
            s = ss;
            m = mm;
            star = true;
        }else
        if ((*ss == *mm) || (*mm == '?')) {
            ss++; mm++;
        }else
        if (star) {
            ss = ++s;
            mm = m;
        }else
            return false;
    }
    
    if (*mm == '*')
        mm++;
    
    return (!*mm);
}

bool CLogReader::MatchedString(const char *s) {
    if ((mask == NULL) || (strlen(mask) == 0)) return true; //маска пустая, любая строка ей удовлетворяет
    
    return matched(s, mask);
}

void CLogReader::Parse(bool to_end_line) {
    Clear();
    
    int start = 0; char *s; bool eol;
    for(int i = 0; i < size; i++) {
        eol = (buffer[i] == '\n') || (buffer[i] == '\r');
        
        if ((eol) || ((i == (size - 1)) && (!to_end_line))) {
            if ((i > start) || (!eol)) {
                //нашли строку
                s = (char *)calloc(i - start + 1 + (eol?0:1), 1);
                assert(s != NULL);
                memcpy(s, &buffer[start], i - start + (eol?0:1));
                s[i - start + (eol?0:1)] = 0;
                
                if (MatchedString(s))
                    matched_strings.push_back(s);   //чистить будем при удалении вектора
                else
                    free(s);
                }
            
                start = i + 1;  //начало следующей строки
            }
        }
    
    if (start < size)
        memcpy(buffer, &buffer[start], size - start);   //нужно сохранить не проанализированную часть блока
    
    size -= start;
}

bool CLogReader::AddSourceBlock(const char *block, const size_t block_size) {
    if ((block == NULL) || (block_size == 0)) return false;
    
    size_t new_size = size + block_size;
    
    if (buffer_size < new_size) {
        buffer = (char *)realloc(buffer, new_size);
        assert(buffer != NULL);
        
        buffer_size = new_size;
    }
    
    memcpy(&buffer[size], block, block_size);
    size = new_size;
    
    Parse(true);
    
    return true;
}

std::vector <char *> CLogReader::MatchedStrings() {
    return matched_strings;
}
