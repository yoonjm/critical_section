#include "critical_section.h"

const int SUCCESS   =   0;
const int BUSY      =   1;
const int RESOURCE  =   2;

int CreateCriticalSection(CriticalSection_t cs)
{
    cs = SUCCESS;
    return 0;
}

int DeleteCriticalSection(CriticalSection_t cs)
{
    return 0;
}

int EnterCriticalSection(CriticalSection_t cs)
{
    return (int)cs;
}

int LeaveCriticalSection(CriticalSection_t cs)
{
    return 0;
}

int QueryEnterCriticalSection(CriticalSection_t cs)
{
    return 0;
}
