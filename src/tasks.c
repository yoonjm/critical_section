#include "lpc2378.h"
#include "print.h"
#include "critical_section.h"

//
// hello_world with timer reset
//
void hello_world(void)
{
	WRITEREG32(T0IR, 0xFF);         // Reset timer
	printString("Hello world!\n");
}

//
// taskOne counts up from 0.
// Never exits.
//
void taskOne(CriticalSection_t cs)
{
	int count = 0;
	while(1)
	{
        int ret = EnterCriticalSection(cs);
        if ( ret == 0 )
            printString("\n ENTER 0\n\n");
        else if ( ret == 1 )
            printString("\n ENTER 1\n\n");

		printString("task one: ");
		print_uint32(count++);
		printString("\n");
		int i;
		for(i=0;i<10000;i++);    // delay
        LeaveCriticalSection(cs);
	}
}

//
// taskTwo counts down from 0xFFFFFFFF
// Never exits.
//
void taskTwo(CriticalSection_t cs)
{
	int count = 0xFFFFFFFF;
	while(1)
	{
        int ret = EnterCriticalSection(cs);
        if ( ret == 0 )
            printString("\n ENTER 0\n\n");
        else if ( ret == 1 )
            printString("\n ENTER 1\n\n");

		printString("task two: ");
		print_uint32(count--);
		printString("\n");
		int i;
		for(i=0;i<10000;i++);    // delay
        LeaveCriticalSection(cs);
	}
}
