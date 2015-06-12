#ifndef __CRITICAL_SECTION_H__
#define __CRITICAL_SECTION_H__

/* Error Codes */
extern const int SUCCESS;
extern const int BUSY;
extern const int RESOURCES;

/* Container for critical section internal data */
typedef int CriticalSection_t;

/*
    Setup a critical seciton for later use

    @param cs Critical section container
    @return 0 Critical section is ready for use
    return non-zero An error code
*/
int CreateCriticalSection(CriticalSection_t cs);

/*
    Clean up resources used by the critical section

    @param cs Critical section container
    @return 0 Critical section deleted
    @return non-zero An error code
*/
int DeleteCriticalSection(CriticalSection_t cs);

/*
    Take the critical section for this thread. If it is not available then
    block until it is.
    This may be entered multiple times within the same thread.
    The critical section will not be released until the
    corresponding number of LeaveCriticalSection() calls have
    been made within the same thread.
    
    @param cs Critical section container
    @return 0 Critical section was taken
    @return non-zero An error code
*/
int EnterCriticalSection(CriticalSection_t cs);

/*
    Release the critical section for this thread.

    @param cs Critical section container
    @return 0 Critical section was released
    @return non-zero An error code
*/
int LeaveCriticalSection(CriticalSection_t cs);

/*
    Take the critical section for this thread if it is available.
    The call will return immediately if critical section is unavailable
    with the error code BUSY
    
    @param cs Critical section container
    @return 0 Critical section was taken
    @return BUSY Critical section is held by another thread
    @return non-zero An error code
*/
int QueryEnterCriticalSection(CriticalSection_t cs);

#endif //__CRITICAL_SECTION_H__
