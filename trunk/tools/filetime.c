#include <windows.h>
#include <stdio.h>

/* FILETIME reference point is January 1, 1601 UTC
 * POSIX reference point is January 1, 1970 UTC
 *
 * Get the FILETIME representation of the POSIX epoch to convert a FILETIME to
 * a POSIX time.
 */
SYSTEMTIME epoch = {
	1970, /* Year */
	1,    /* Month */
	0,    /* Day of Week */
	1,    /* Day */
	0,    /* Hour */
    0,    /* Minutes */
    0,    /* Seconds */
    0,    /* Milliseconds */
};

int main() {
	FILETIME ftepoch;
	BOOL ret = SystemTimeToFileTime(&epoch, &ftepoch);
	if (ret) {
		printf("High: 0x%08x\nLow: 0x%08x\n",
			 ftepoch.dwHighDateTime, ftepoch.dwLowDateTime);
		return 0;
	} else {
		fprintf(stderr, "Error getting the epoch filetime.\n");
		return 1;
	}
	return 2;
}
